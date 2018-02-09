# ============================================================================ #
#                                                                              #
#                           Use trained word vectors                           #
#            Download from: https://nlp.stanford.edu/projects/glove/           #
#                                                                              #
# ============================================================================ ##

# Read every line as character:
if (file.exists(word.vector.file)) {
  
  word.lines = readr::read_lines(file = word.vector.file)
  
  getWordVectorMatrix = function (word.lines)
  {
    words = lapply(X = word.lines, FUN = function (line) {
      strsplit(line, " ")[[1]][1]
    })
    vectors = lapply(X = word.lines, FUN = function (line) {
      as.numeric(strsplit(line, " ")[[1]][-1])
    })
    
    word.vectors = t(as.matrix(as.data.frame(vectors)))
    row.names(word.vectors) = words
    
    return (word.vectors)
  }
  word.vectors = getWordVectorMatrix(word.lines)
  
  rm (word.lines)
  
} else {
  stop ("Couldn't find word vector file!")
}


