# ============================================================================ #
#                                                                              #
#                        Extract stopwords for GloVe                           #
#                  Use stopwords from: http://snowballstem.org                 #
#                                                                              #
# ============================================================================ #

# Load Words:
# -----------

stopwords = try (
  suppressWarnings(
    readLines(con = "http://snowball.tartarus.org/algorithms/english/stop.txt")
  ),
  silent = TRUE
)
if (class(stopwords) == "try-error") {
  if (file.exists("additional_stuff/stopwords.txt")) {
    stopwords = readLines(con = "additional_stuff/stopwords.txt")
  }
}

# extract stopwords: 
# ------------------

# Therefore delete comments and do some string stuff:

if (is.character(stopwords)) {
  
  stopwords = paste0(stopwords, "//]]")
  stopwords = lapply(stopwords, function (word) {
    deleteStringBetween(word, "|", "//]]")
  })
  stopwords = unlist(
    lapply(stopwords, function (word) {
      replaceAll(replaceAll(word, "//]]", ""), " ", "")
    })
  )
  stopwords = unique(unlist(strsplit(stopwords, "'")))
} else {
  stop ("Neither the link nor the local file exists!")
}
