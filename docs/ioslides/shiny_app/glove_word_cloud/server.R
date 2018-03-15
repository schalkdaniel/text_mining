evaluateGloveOwn = function (word.vectors, a, b = NA, c = NA, norm, 
  print.words = 5L, print.sentence = TRUE, method = "cosine")
{
  if (missing(norm)) {
    norm = function (x) 
    {
      return (sqrt(sum(x^2)))
    }
  }
  
  # Cosine similarity (https://en.wikipedia.org/wiki/Cosine_similarity)
  if (method == "cosine") {
    distOwn = function (x, y) {
      return (1 - crossprod(y, x) / ( norm(y) * norm(x) ))
    }
  }
  if (method == "euclidean") {
    distOwn = function (x, y) {
      return (norm(x - y) / ( norm(y) * norm(x) ))
    }
  }
  
  # Check if all words are within the occured words:
  if (! a %in% rownames(word.vectors)) {
    stop ("Word ", a, " doesn't occur as a word vector!")
  }
  if ( (! b %in% rownames(word.vectors)) && (! is.na(b)) ) {
    stop ("Word ", b, " doesn't occur as a word vector!")
  }
  if ( (! c %in% rownames(word.vectors)) && (! is.na(c)) ) {
    stop ("Word ", c, " doesn't occur as a word vector!")
  }
  
  if (is.na(b) || is.na(c)) {
    # Find next words to word a:
    compare = word.vectors[a, ]
  } else {
    # Find word which behaves to c like a to b
    compare = word.vectors[b, ] - word.vectors[a, ] + word.vectors[c, ]
  }
  
  dists = apply(X = word.vectors, MARGIN = 1, FUN = function (x) {
    distOwn(x, compare)
  })
  
  if (print.sentence) {
    if (is.na(b) || is.na(c)) {
      cat("\nNearest words to", a, ":\n\n")
    } else {
      cat(paste0("\n", a), "behaves to", b, "like", c, "to ...\n\n") 
    }
  }
  if (is.numeric(print.words)) {
    
    print(head(sort(dists, decreasing = FALSE), print.words))
  }
  return (invisible(head(sort(dists, decreasing = FALSE), print.words)))
}

load("C:/Users/schal/Downloads/glove.6B/wv_test.RData")

n.words = 30L
cols = rgb(
  red   = seq(from = 240, to = 255 , length.out = n.words),
  green = seq(from = 230, to = 140 , length.out = n.words),
  blue  = seq(from = 140, to = 0 ,   length.out = n.words),
  alpha = 200,
  maxColorValue = 255
)

library(wordcloud)

library(Cairo)
options(shiny.usecairo = TRUE)

function(input, output, session) {
  # Define a reactive expression for the document term matrix
  # word = reactive({
  #   
  #   input$isolate
  #   
  #   # ...but not for anything else
  #   isolate({
  #     withProgress({
  #       setProgress(message = "Processing ...")
  #       input$my.word
  #     })
  #   })
  # })
  
  # Make the wordcloud drawing predictable during a session
  
  output$plot <- renderPlot(expr = {
    
    my.word = input$my.word
    
    mywords = evaluateGloveOwn(word.vectors, a = my.word, print.words = n.words + 1)[-1]
    diff = max(mywords) - min(mywords)
    mywords = 1 - ( mywords - min(mywords) ) / diff
    
    wordcloud(
      words  = names(mywords), 
      freq   = mywords, 
      colors = cols
    )
  }, width = 620, height = 420, bg = "transparent")
}