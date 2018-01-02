# ============================================================================ #
#                                                                              #
#                    Test Model with questions-words file                      #
#          Use file from https://github.com/nicholas-leonard/word2vec          #
#                                                                              #
# ============================================================================ #

# text2vec::prepare_analogy_questions wrapper, function can't be used with the
# given question-words file:

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
  questions_file_path = "additional_stuff/questions_words.txt", 
  vocab_terms = colnames(word_vectors)
)

# Run test:
res = text2vec::check_analogy_accuracy(question.list, word_vectors)
