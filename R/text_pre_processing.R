# ============================================================================ #
#                                                                              #
#                           Text Pre Processing                                #
#                      Designed for wikipedia xml dump                         #
#                                                                              #
# ============================================================================ #

# Basically, the following steps can be done for any txt document.

if (exists("mywiki.file") && exists("out.file")) {
  
  # Load required cpp function:
  # ---------------------------
  
  if (file.exists("src/string_functions.cpp")) {
    Rcpp::sourceCpp(file = "src/string_functions.cpp")
  }
  
  # Get lines of xml file:
  # ----------------------
  
  check.lines = TRUE
  
  if (check.lines) {
    if (file.exists(mywiki.file)) {
      file.lines = countLinesOfExternalFile(mywiki.file)
    }
    cat("\nUsed wiki has ", file.lines, " lines!\n\n")
  }
  
  rm (check.lines)
  
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
  
  # Extract all text between text tags:
  extractTextBetweenTextTags(
    connection  = mywiki.file, 
    out_file    = out.file, 
    expressions = expressions.to.delete, 
    n           = -1
  )
  
  rm (expressions.to.delete)
  
  # Some assumptions/drawbacks:
  
  #   - links are pasted to one sting (could deleted by selecting 
  #     counts > 5 or 10)
  # 
  #   - Not all expressions are catched, there are too much
  
  # Read extracted file:
  # --------------------
  
  plain.text = readr::read_lines(out.file)
  
  # Remove stopwords:
  # -----------------
  
  # Helper function:
  removeWords = function (str, stopwords) {
    x = unlist(strsplit(str, " "))
    return (paste(x[!x %in% stopwords], collapse = " "))
  }
  
  # Get stopwords:
  if (file.exists("R/extract_stopwords.R")) {
    source (file = "R/extract_stopwords.R")
  } else {
    stop ("Couldn't find 'R/extract_stopwords.R'!")
  }  
  
  plain.text = unlist(
    lapply(
      X         = plain.text, 
      FUN       = removeWords, 
      stopwords = stopwords
    )
  )
  
  rm (removeWords, stopwords)
  
  writeLines(text = plain.text, con = out.file)
  
} else {
  stop ("Couldn't file 'mywiki.file' object!")
}