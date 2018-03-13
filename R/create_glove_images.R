
# 
# readPreTrainedWordVectors = function (file)
# {
#   word.lines = readr::read_lines(file = word.vector.file)
#   
#   words = lapply(X = word.lines, FUN = function (line) {
#     strsplit(line, " ")[[1]][1]
#   })
#   vectors = lapply(X = word.lines, FUN = function (line) {
#     as.numeric(strsplit(line, " ")[[1]][-1])
#   })
#   
#   word.vectors = t(as.matrix(as.data.frame(vectors)))
#   row.names(word.vectors) = words
#   
#   return (word.vectors)
# }

gloveImage = function (word.vectors, text, nmax = 100, ...)
{
  available.words = rownames(word.vectors)
  
  special.chars = c("[.]", ",", "?", "!", as.character(0:9), "'", "?", "\\$",
    "%", "/", "\\(", "\\)", "=", "'", "-", "?", ";", ":")
  
  selection = text
  
  for (char in special.chars) {
    selection = gsub(char, "", selection)
  }
  
  words = tolower(unlist(strsplit(x = selection, split = " ")))
  
  idx.words = match(words, available.words)
  
  if (sum(is.na(idx.words)) > 0) {
    warning ("The following words are not available as word vectors: ",
      paste(words[is.na(idx.words)], collapse = ", "), "\n")
  }
  
  if (length(na.omit(idx.words)) > nmax) {
    warning ("Cutting after ", nmax, " words")
    idx.words = na.omit(idx.words)[1:nmax]
  } else {
    idx.words = na.omit(idx.words)
  }
  
  word.matrix = t(word.vectors[idx.words, ])
  
  # Fill up with zeros:
  if (ncol(word.matrix) < nmax) {
    nuisance.mat = matrix(0, nrow = nrow(word.matrix), ncol = nmax - ncol(word.matrix))
    word.matrix = cbind(word.matrix, nuisance.mat)
  }
  
  # Scale matrix:
  range.wm    = abs(max(word.vectors) - min(word.vectors))
  word.matrix = ( word.matrix - min(word.vectors) ) / range.wm
  
  image(
    z = t(word.matrix),
    xlab = "Word Index", 
    ylab = "Dimension", 
    axes = FALSE,
    col.lab = "white",
    col.main = "white",
    ...
  )
  axis(
    side   = 1, 
    at     = seq(0, 1, length.out = 11), 
    labels = round(seq(1, nmax, length.out = 11)),
    col       = "white", 
    col.ticks = "white", 
    col.axis  = "white"
  )
  axis(
    side   = 2, 
    at     = seq(0, 1, length.out = 11), 
    labels = round(seq(nrow(word.matrix), 1, length.out = 11)), 
    las    = 2,
    col       = "white", 
    col.ticks = "white", 
    col.axis  = "white"
  )
}








# word.vector.file = "C:/Users/schal/Desktop/glove_images/glove.6B.300d.txt"
# 
# word.vectors = readPreTrainedWordVectors(word.vector.file)
# 
# test.text = list(
#   principia.mathematica.naturalis  = list(title = "Principia Mathematica Naturalis", intro = "The mathematical logic which occupies Part I of the present work has been constructed under the guidance of three different purposes. In the first place, it aims at effecting the greatest possible analysis of the ideas with which it deals and of the processes by which it conducts demonstrations, and at diminishing to the utmost the number of the undefined ideas and undemonstrated propositions (called respectively primitive ideas and primitive propositions) from which it starts. In the second place, it is framed with a view to the perfectly precise expression, in its symbols, of mathematical propositions: to secure such expression, and to secure it in the simplest and most convenient notation possible, is the chief motive in the choice of topics. In the third place, the system is specially framed to solve the paradoxes which, in recent years, have troubled students of symbolic logic and the theory of aggregates; it is believed that the theory of types, as set forth in what follows, leads both to the avoidance of contradictions, and to the detection of the precise fallacy which has given rise to them."),
#   elements.of.statistical.learning = list(title = "Elements of Statistical Learning", intro = "The field of Statistics is constantly challenged by the problems that science and industry brings to its door. In the early days, these problems often came from agricultural and industrial experiments and were relatively small in scope. With the advent of computers and the information age, statistical problems have exploded both in size and complexity. Challenges in the areas of data storage, organization and searching have led to the new field of data mining; statistical and computational problems in biology and medicine have created bioinformatics. Vast amounts of data are being generated in many fields, and the statistician's job is to make sense of it all: to extract important patterns and trends, and understand what the data says. We call this learning from data."),
#   sonnet18.shakespeare = list(title = "Sonnet 18 by William Shakespeare", intro = "Shall I compare thee to a summer's day? Thou art more lovely and more temperate: ough winds do shake the darling buds of May,  And summer's lease hath all too short a date: Sometime too hot the eye of heaven shines, And often is his gold complexion dimm'd; And every fair from fair sometime declines, By chance, or nature's changing course, untrimm'd;  But thy eternal summer shall not fade Nor lose possession of that fair thou ow'st; Nor shall Death brag thou wander'st in his shade, When in eternal lines to time thou grow'st; o long as men can breathe or eyes can see, So long lives this, and this gives life to thee.")
# )
# 
# cairo_pdf(filename = "text_images.pdf", width = 10, height = 4, pointsize = 14, 
#   family = "Century Gothic", bg = NA)
# 
# par (mfrow = c(1,3))
# for (i in seq_along(test.text)) {
#   gloveImage(
#     word.vectors = word.vectors, 
#     text = test.text[[i]]$intro, 
#     nmax = 150, 
#     main = test.text[[i]]$title
#   )
# }
# par (mfrow = c(1,1))
# 
# dev.off()
