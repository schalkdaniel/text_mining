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
glove.dim = 300
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

# Create Image for text classification:
# -----------------------------------------

source("R/create_glove_images.R")

# Use Intro from 'Elements of Statistical Learning' with first 500 words:
my.txt = "The field of Statistics is constantly challenged by the problems that science
and industry brings to its door. In the early days, these problems often came
from agricultural and industrial experiments and were relatively small in
scope. With the advent of computers and the information age, statistical
problems have exploded both in size and complexity. Challenges in the
areas of data storage, organization and searching have led to the new field
of “data mining”; statistical and computational problems in biology and
medicine have created “bioinformatics.” Vast amounts of data are being
generated in many fields, and the statistician’s job is to make sense of it
all: to extract important patterns and trends, and understand “what the
data says.” We call this learning from data.
The challenges in learning from data have led to a revolution in the statistical
sciences. Since computation plays such a key role, it is not surprising
that much of this new development has been done by researchers in other
fields such as computer science and engineering.
The learning problems that we consider can be roughly categorized as
either supervised or unsupervised. In supervised learning, the goal is to predict
the value of an outcome measure based on a number of input measures;
in unsupervised learning, there is no outcome measure, and the goal is to
describe the associations and patterns among a set of input measures.
xii Preface to the First Edition
This book is our attempt to bring together many of the important new
ideas in learning, and explain them in a statistical framework. While some
mathematical details are needed, we emphasize the methods and their conceptual
underpinnings rather than their theoretical properties. As a result,
we hope that this book will appeal not just to statisticians but also to
researchers and practitioners in a wide variety of fields.
Just as we have learned a great deal from researchers outside of the field
of statistics, our statistical viewpoint may help others to better understand
different aspects of learning:
There is no true interpretation of anything; interpretation is a
vehicle in the service of human comprehension. The value of
interpretation is in enabling others to fruitfully think about an
idea.
–Andreas Buja
We would like to acknowledge the contribution of many people to the
conception and completion of this book. David Andrews, Leo Breiman,
Andreas Buja, John Chambers, Bradley Efron, Geoffrey Hinton, Werner
Stuetzle, and John Tukey have greatly influenced our careers. Balasubramanian
Narasimhan gave us advice and help on many computational
problems, and maintained an excellent computing environment. Shin-Ho
Bang helped in the production of a number of the figures. Lee Wilkinson
gave valuable tips on color production. Ilana Belitskaya, Eva Cantoni, Maya
Gupta, Michael Jordan, Shanti Gopatam, Radford Neal, Jorge Picazo, Bogdan
Popescu, Olivier Renaud, Saharon Rosset, John Storey, Ji Zhu, Mu
Zhu, two reviewers and many students read parts of the manuscript and
offered helpful suggestions. John Kimmel was supportive, patient and helpful
at every phase; MaryAnn Brickner and Frank Ganz headed a superb
production team at Springer. Trevor Hastie would like to thank the statistics
department at the University of Cape Town for their hospitality during
the final stages of this book. We gratefully acknowledge NSF and NIH for
their support of this work. Finally, we would like to thank our families and
our parents for their love and support."



gloveImage(word.vectors = word.vectors, text = my.txt, nmax = 300L)

