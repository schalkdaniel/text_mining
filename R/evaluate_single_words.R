# ============================================================================ #
#                                                                              #
#                             Evaluate single Words                            #
#               Using custom defined distances (cosine and euclidean)          #
#                                                                              #
# ============================================================================ ##


if (exists("word.vectors")) {
  
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
        return (crossprod(y, x) / ( norm(y) * norm(x) ))
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
      if (method == "cosine") {
        print(head(sort(dists, decreasing = TRUE), print.words))
      } 
      if (method == "euclidean") {
        print(head(sort(dists, decreasing = FALSE), print.words))
      }
    }
    return (invisible(dists))
  }
  
  cat("\n\n>> Using cosine similarity <<\n")
  
  # Find nearest words:
  evaluateGloveOwn(word.vectors, a = "frog")
  evaluateGloveOwn(word.vectors, a = "sister")
  
  # Find word which behaves to c like b to a:
  evaluateGloveOwn(word.vectors, a = "france", b = "paris", c = "germany")
  evaluateGloveOwn(word.vectors, "queen", "women", "king")
  
  cat("\n\n>> Using euclidean distances <<\n")
  
  # Find nearest words:
  evaluateGloveOwn(word.vectors, a = "frog", method = "euclidean")
  evaluateGloveOwn(word.vectors, a = "sister", method = "euclidean")
  
  # Find word which behaves to c like b to a:
  evaluateGloveOwn(word.vectors, a = "france", b = "paris", c = "germany", method = "euclidean")
  evaluateGloveOwn(word.vectors, a = "queen", b = "women", c = "king", method = "euclidean")
} else {
  cat ("No 'word.vectors' in global environment!")
}