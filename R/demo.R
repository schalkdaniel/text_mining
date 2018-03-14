# ============================================================================ #
#                                                                              #
#                            Text Mining: GloVe                                #
#                                Demo Script                                   #
#                                                                              #
# ============================================================================ #


library(text2vec)
library(magrittr)

# Helper Functions:
# -------------------------------

# For evaluation of single words:
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

# For preparing word vectors for word similarity task:
prepareOwn = function (questions_file_path, vocab_terms) 
{
  require (futile.logger)
  
  lines = readLines(questions_file_path) %>% 
    tolower %>% 
    strsplit(split = " ", fixed = TRUE)
  
  section_name_ind = which(sapply(lines, length) != 4)
  section_start_ind = section_name_ind + 1
  section_end_ind = c(section_name_ind[-1] - 1, length(lines))
  
  q = Map(
    function(i1, i2, quetsions) quetsions[i1:i2] %>% 
      (function(x) do.call(rbind, x)) %>% match(vocab_terms) %>% 
      matrix(ncol = 4) %>% 
      (function(x) {
        any_na_ind = apply(x, 1, anyNA)
        x[!any_na_ind, ]
      }), section_start_ind, section_end_ind, MoreArgs = list(quetsions = lines))
  
  questions_number = sum(sapply(q, nrow))
  flog.info("%s full questions found out of %s total", 
    questions_number, length(lines) - length(section_name_ind))
  stats::setNames(q, sapply(lines[section_name_ind], .subset2, 
    2))
}


# ---------------------------------------------------------------------------- #
# Example: word-word co-occurenece Matrix                                      #
# ---------------------------------------------------------------------------- #

plain.text = "A D C E A D E B A C E D"

# Create vocabulary out of the corpus:
it    = text2vec::itoken(plain.text)
vocab = text2vec::create_vocabulary(it)

# Create word-word co-occurenece matrix:
vectorizer = text2vec::vocab_vectorizer(vocab)
tcm = text2vec::create_tcm(it, vectorizer, skip_grams_window = 2L, 
  skip_grams_window_context = "symmetric", weights = c(1,1))

# Convert sparse format to full matrix:
as.matrix(tcm)[LETTERS[1:5], LETTERS[1:5]] + 
  t(as.matrix(tcm)[LETTERS[1:5], LETTERS[1:5]]) - 
  diag(diag(t(as.matrix(tcm)[LETTERS[1:5], LETTERS[1:5]])))


# ---------------------------------------------------------------------------- #
# Real Example:                                                                #
# ---------------------------------------------------------------------------- #

# Create vocabulary:
# ------------------

# Read simple wiki (already pre processed):
plain.text = readr::read_lines(file = "extraction_simplewiki.txt")

# Create vocabulary:
it    = text2vec::itoken(plain.text, progressbar = TRUE)
vocab = text2vec::create_vocabulary(it)

# Prune vocabulary (just take words which occur more often than 10 times):
pruned.vocab = text2vec::prune_vocabulary(
  vocabulary     = vocab, 
  term_count_min = 10
)

# Create word-word co-occurence matrix:
# -------------------------------------

# Use filtered vocabulary:
vectorizer = text2vec::vocab_vectorizer(pruned.vocab)

# use window of 20 for context words:
tcm = text2vec::create_tcm(it, vectorizer, skip_grams_window = 5L)


# Train GloVe:
# ------------

glove = text2vec::GlobalVectors$new(
  word_vectors_size = 100, 
  vocabulary        = pruned.vocab, 
  x_max             = 100, 
  alpha             = 0.75,
  learning_rate     = 0.05, 
  shuffle           = 42L
)

# glove$fit doesn't work. Use fit_transform instead:
glove$fit_transform(
  x               = tcm, 
  n_iter          = 10L, 
  n_threads       = parallel::detectCores()
)

# Extract word vectors (the later test expect word vectors as rows not 
# columns):
word.vectors = t(glove$components)

# Evaluate single words:
# ----------------------

## Cosine Similarity:

# Find nearest words:
evaluateGloveOwn(word.vectors, a = "frog")
evaluateGloveOwn(word.vectors, a = "sister")

# Find word which behaves to c like b to a:
evaluateGloveOwn(word.vectors, a = "france", b = "paris", c = "germany")
evaluateGloveOwn(word.vectors, "queen", "women", "king")

## Euclidean Distance:

# Find nearest words:
evaluateGloveOwn(word.vectors, a = "frog", method = "euclidean")
evaluateGloveOwn(word.vectors, a = "sister", method = "euclidean")

# Find word which behaves to c like b to a:
evaluateGloveOwn(word.vectors, a = "france", b = "paris", c = "germany", method = "euclidean")
evaluateGloveOwn(word.vectors, a = "queen", b = "women", c = "king", method = "euclidean")

# Evaluate with word similarity task:
# -----------------------------------

question.words.file = "additional_stuff/questions_words.txt"

# Prepare for test:
question.list = prepareOwn(
  questions_file_path = question.words.file, 
  vocab_terms = rownames(word.vectors)
)

res = text2vec::check_analogy_accuracy(question.list, word.vectors)
