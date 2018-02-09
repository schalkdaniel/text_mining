# ============================================================================ #
#                                                                              #
#                 Evaluate Word Vectors using word analogy task                #
#          Use file from https://github.com/nicholas-leonard/word2vec          #
#                                                                              #
# ============================================================================ #

# text2vec::prepare_analogy_questions wrapper, function can't be used with the
# given question-words file:
if (exists("word.vectors")) {
  
  if (file.exists(question.words.file)) {
    
    # Function arguments are the same as in text2vec::prepare_analogy_questions:
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
    
    # Prepare for test:
    question.list = prepareOwn(
      questions_file_path = question.words.file, 
      vocab_terms = rownames(word.vectors)
    )
    
    res = text2vec::check_analogy_accuracy(question.list, word.vectors)
    
  } else {
    stop ("Couldn't find question words file!")
  }
} else {
  stop("No 'word.vector' object in environment! Use own one or download from: https://nlp.stanford.edu/projects/glove/")
}

# # Run test:
# # For own trained vectors:
# res = text2vec::check_analogy_accuracy(question.list, t(word.vectors))
# 
# # For pre trained vectors:
# 
