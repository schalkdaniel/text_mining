# Load required cpp function:
# ---------------------------

if (file.exists("src/string_functions.cpp")) {
  Rcpp::sourceCpp(file = "src/string_functions.cpp")
}

# Wiki xml sources:
# -----------------

simple.wiki = "E:/Multimedia/Datensätze/wikipedia_articles/simplewiki.xml"
full.wiki   = "E:/Multimedia/Datensätze/wikipedia_articles/fullwiki_en.xml"

# Get lines of xml files:
# -----------------------

check.lines = FALSE

if (check.lines) {
  
  if (file.exists(small.wiki) && file.exists(full.wiki)) {
    
    # Lines of the simple wiki (~ 1 GB = 17963603 lines):
    lines.simplewiki = countLinesOfExternalFile(simple.wiki)
    
    # Lines of full wiki (~ 63 GB = 1005283137 lines):
    lines.fullwiki   = countLinesOfExternalFile(full.wiki)
  }
}

# # Examples for some text manipulation functions:
# string = "<text>I am a wikipedia article!</text>"
# 
# substringInString(string, "<text>")
# stringBetween(string, "<text>", "</text>")
# replaceAll(string, "a wikipedia", "an")
# deleteStrings(string, c("<text>", "I", "article", "!"))
# 
# string = "In [[common year|common years]], ]]April| [[starts| on the same day of [[the week|the weeks]] as"
# ( string = deleteStrings(replaceAll(deleteStringBetween(string, "[[", "|"), "  ", " "), c("[[", "|", "]]")) )
# deleteStringBetween(string, "[[", "|")

# Extract plain text:
# -------------------

# Some expression to delete priori:
expressions.to.delete = c(
  # This character are included within the extractLetters function:
  # "." ,",", ":", "(", ")", "[", "]", "{", "}", "0", "1", "2", "3", "4", "5",
  # "6", "7", "8", "9", "'", "&", ";", "?", "!", "#", "%", "_", "|", "=", "-", 
  # "/", "$",
  "gt", "lt", "EN"
)

out.file.full   = "E:/Multimedia/Datensätze/wikipedia_articles/extraction_fullwiki.txt"
out.file.simple = "E:/Multimedia/Datensätze/wikipedia_articles/extraction_simplewiki.txt"

# time.full = proc.time()
# extractTextBetweenTextTags(
#   connection  = full.wiki, 
#   out_file    = out.file.full, 
#   expressions = expressions.to.delete, 
#   n           = -1
# )
# time.full = proc.time() - time.full

time.simple = proc.time()
extractTextBetweenTextTags(
  connection  = simple.wiki, 
  out_file    = out.file.simple, 
  expressions = expressions.to.delete, 
  n           = -1
)
time.simple = proc.time() - time.simple

# Some assumptions/drawbacks:

#   - links are pasted to one sting (could deleted by selecting 
#     counts > 5 or 10)
# 
#   - Not all expressions are catched, there are way too much



# Read extracted file:
# --------------------

plain.text = readr::read_lines(out.file.simple)

# Remove stopwords:
# -----------------

# Helper function:
removeWords = function (str, stopwords) {
  x = unlist(strsplit(str, " "))
  return (paste(x[!x %in% stopwords], collapse = " "))
}

# Get stopwords:
source (file = "R/extract_stopwords.R")

plain.text = unlist(
  lapply(
    X         = plain.text, 
    FUN       = removeWords, 
    stopwords = stopwords
  )
)

# Create vocabulary. Terms will be unigrams (simple words):
# ---------------------------------------------------------

# Create iterator over tokens
tokens = text2vec::space_tokenizer(plain.text)

it    = text2vec::itoken(tokens, progressbar = TRUE)
vocab = text2vec::create_vocabulary(it)

pruned.vocab = text2vec::prune_vocabulary(
  vocabulary         = vocab, 
  doc_proportion_max = 0.3, 
  vocab_term_max     = 30000
)

# Train GloVe:
# ------------

# Use filtered vocabulary:
vectorizer = text2vec::vocab_vectorizer(pruned.vocab)

# use window of 20 for context words:
tcm = text2vec::create_tcm(it, vectorizer, skip_grams_window = 10L)

glove = text2vec::GlobalVectors$new(
  word_vectors_size = 300, 
  vocabulary        = pruned.vocab, 
  x_max             = 100, 
  learning_rate     = 0.03, 
  shuffle           = 42L
)

# glove$fit doesn't work. Use fit_transform instead:
glove$fit_transform(
  x               = tcm, 
  n_iter          = 20, 
  n_threads       = parallel::detectCores()
)

# Evaluate the trained model:
# ---------------------------

# Extract word vectors:
word_vectors = glove$components

# Helper function:
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

# Test fitted model:
# ------------------

source (file = "R/model_test.R")
