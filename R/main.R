# ============================================================================ #
#                                                                              #
#                                Main script                                   #
#           Fitting and testing GloVe from the corpus to evaluation            #
#                                                                              #
# ============================================================================ #

# This script is intended to guide through the single steps which are necessary
# to create and evaluate own word vectors using GloVe. This file should be as
# clean as possible which means, that the single parts are just sourced. You 
# can go into detail by looking at the sourced files. 

# The following steps are done for the simple wiki (not the full wiki) due to
# memory and time. The following steps can then be done on the most PCs and
# laptops.

# Packages:
# =====================================

library(text2vec)
library(magrittr)

# Get Some Text:
# =====================================

mywiki.file = "E:/Multimedia/Datensätze/wikipedia_articles/simplewiki.xml"
out.file    = "E:/Multimedia/Datensätze/wikipedia_articles/my_plain_text.txt"

# This script creates just a character vector containing the plain text of the
# specified file above:

source ("R/text_pre_processing.R")

# Prepare Corpus (create vocabulary):
# =====================================

source ("R/create_vocabulary.R")

# Fitting GloVe:
# =====================================

# The following script creates the term count matrix and trains GloVe:

source ("R/tcm_and_glove.R")


# Test Word Vectors:
# =====================================

# NOTE: Testing needs a lot of memory. The following tests was made on AWS.

# Evaluating the word analogy task of Mikolov et al.:
#
#            >> https://arxiv.org/pdf/1301.3781.pdf <<
#
# Path to question-words file:
question.words.file = "additional_stuff/questions_words.txt"

# Own Word Vectors:
# ---------------------------

# Evaluate some words:
source ("R/evaluate_single_words.R")

# Evaluate the analogy task:
source ("R/word_analogy_task.R")

# Pre-Trained Word Vectors:
# ---------------------------

# Exemplary done for Wikipedia 2014 + Gigaword 5 (6B tokens, 400K vocab, 
# uncased, 50d) wich can be downloaded from:
#
#          >> https://nlp.stanford.edu/projects/glove/ <<
# 
# There are much more pre-trained word vectors. But to keep memory usage as
# small as possible I have used the smallest corpus + smalles dimension.
# The results for other pre-trained word vectors are stored in:
#
#       >> additional_stuff/pre_trained_word_vectors_log.txt <<
#

# Adjust this path to your word vector:
word.vector.file = "glove.6B/glove.6B.50d.txt"

# Prepare pre-trained word vectors:
source ("R/prepare_pre_trained_vectors.R")

# Evaluate some words:
source ("R/evaluate_single_words.R")

# Evaluate the analogy task:
source ("R/word_analogy_task.R")
