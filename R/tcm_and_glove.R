# ============================================================================ #
#                                                                              #
#                             Create Term Count Matrix                         #
#                                       and                                    #
#                            Train GloVe + Word Vectors                        #
#                                                                              #
# ============================================================================ #

if (vocab.was.created) {
  
  # Train GloVe:
  # ------------
  
  # Use filtered vocabulary:
  vectorizer = text2vec::vocab_vectorizer(pruned.vocab)
  
  # use window of 20 for context words:
  tcm = text2vec::create_tcm(it, vectorizer, skip_grams_window = 20L)
  
  glove = text2vec::GlobalVectors$new(
    word_vectors_size = 300, 
    vocabulary        = pruned.vocab, 
    x_max             = 100, 
    learning_rate     = 0.05, 
    shuffle           = 42L
  )
  
  # glove$fit doesn't work. Use fit_transform instead:
  glove$fit_transform(
    x               = tcm, 
    n_iter          = 50, 
    n_threads       = parallel::detectCores()
  )
  
  # Extract word vectors (the later test expect word vectors as rows not 
  # columns):
  word.vectors = t(glove$components)
  
} else {
  stop ("No vocabulary! Run 'create_corpus.R' first!")
}