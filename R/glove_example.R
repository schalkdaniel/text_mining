library(text2vec)

text8_file = "text8"
if (! file.exists(text8_file)) {
  download.file("http://mattmahoney.net/dc/text8.zip", "~/text8.zip")
  unzip ("~/text8.zip")
}
wiki = readr::read_lines("text8")

# Create iterator over tokens
tokens = space_tokenizer(wiki)

# Create vocabulary. Terms will be unigrams (simple words):
it = itoken(tokens, progressbar = TRUE)
vocab = create_vocabulary(it)

vocab = prune_vocabulary(vocab, term_count_min = 5L)

# Use filtered vocabulary:
vectorizer = vocab_vectorizer(vocab)

# use window of 20 for context words:
tcm = create_tcm(it, vectorizer, skip_grams_window = 20L)

glove = GlobalVectors$new(
  word_vectors_size = 300, 
  vocabulary        = vocab, 
  learning_rate     = 0.03,
  x_max             = 100
)

# glove$fit doesn't work. Use fit_transform instead:
glove$fit_transform(tcm, n_iter = 20)

word_vectors = glove$components

# berlin <- word_vectors[, "paris", drop = FALSE] - 
#   word_vectors[, "france", drop = FALSE] + 
#   word_vectors[, "germany", drop = FALSE]
# 
# # Doesn't work as in the tutorial:
# sim2(x = word_vectors, y = berlin)

evaluateGloveOwn = function (word_vectors, a, b = NA, c = NA, norm, print.words = 5L)
{
  if (missing(norm)) {
    norm = function (x) 
    {
      return (sqrt(sum(x^2)))
    }
  }
  
  # Check if all words are within the occured words:
  if (! a %in% colnames(word_vectors)) {
    stop ("Word ", a, " doesn't occur as a word vector!")
  }
  if ( (! b %in% colnames(word_vectors)) && (! is.na(b)) ) {
    stop ("Word ", b, " doesn't occur as a word vector!")
  }
  if ( (! c %in% colnames(word_vectors)) && (! is.na(c)) ) {
    stop ("Word ", c, " doesn't occur as a word vector!")
  }
  
  if (is.na(b) || is.na(c)) {
    # Find next words to word a:
    compare = word_vectors[, a]
  } else {
    # Find word which behaves to c like a to b
    compare = word_vectors[, b] - word_vectors[, a] + word_vectors[, c]
  }
  
  dists = apply(X = word_vectors, MARGIN = 2, FUN = function (x) {
    # Cosine similarity (https://en.wikipedia.org/wiki/Cosine_similarity)
    crossprod(compare, x) / ( norm(compare) * norm(x) )
    # norm(x - compare)
  })
  
  if (is.numeric(print.words)) {
    print(head(sort(dists, decreasing = TRUE), print.words))
  }
  return (invisible(dists))
}

# Find nearest words:
evaluateGloveOwn(word_vectors, a = "frog")
evaluateGloveOwn(word_vectors, a = "sister")

# Find word which behaves to c like b to a:
evaluateGloveOwn(word_vectors, a = "france", b = "paris", c = "germany")
evaluateGloveOwn(word_vectors, "queen", "women", "king")
