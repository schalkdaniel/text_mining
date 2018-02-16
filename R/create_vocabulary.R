# ============================================================================ #
#                                                                              #
#                             Create Vocabulary                                #
#                                                                              #
# ============================================================================ #


# Create vocabulary. Terms will be unigrams (simple words):
# ---------------------------------------------------------

if (exists("plain.text")) {
  
  # # Create iterator over tokens
  # tokens = text2vec::space_tokenizer(plain.text)
  
  it    = text2vec::itoken(plain.text, progressbar = TRUE)
  vocab = text2vec::create_vocabulary(it)
  
  pruned.vocab = text2vec::prune_vocabulary(
    vocabulary     = vocab, 
    term_count_min = 10
  )
  
  # Just a control object for the training script!
  vocab.was.created = TRUE
  
} else {
  stop ("No 'plain.text' in environment!")
}