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
  "quot",  "gt", "lt", "EN"
)

# The extraction (expected time ~10h, "n = -1" means all lines):
time.full = proc.time()
extractTextBetweenTextTags(
  connection  = full.wiki, 
  out_file    = "E:/Multimedia/Datensätze/wikipedia_articles/extraction_fullwiki.txt", 
  expressions = expressions.to.delete, 
  n           = -1
)
time.full = proc.time() - time.full

# The extraction (expected time ~1h, "n = -1" means all lines):
time.full = proc.time()
extractTextBetweenTextTags(
  connection  = simple.wiki, 
  out_file    = "E:/Multimedia/Datensätze/wikipedia_articles/extraction_simplewiki.txt", 
  expressions = expressions.to.delete, 
  n           = -1
)
time.full = proc.time() - time.full

# Some assumptions/drawbacks:

#   - links are pasted to one sting (could deleted by selecting 
#     counts > 5 or 10)
# 
#   - Not all expressions are catched, there are way too much



# Read extracted file:
# --------------------

plain.text = readr::read_lines("extraction.txt")

# paste everything to one huge string:
# ------------------------------------

plain.text = paste(plain.text, collapse = " ")

# Count words:
sapply(gregexpr("\\W+", plain.text), length) + 1
