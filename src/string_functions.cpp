#include <Rcpp.h>
#include <string>
#include <vector>
#include <fstream>
#include <ctype.h>

// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
bool substringInString (std::string& str, const std::string& substring)
{
  // std::string::npos is just the same which is returned if 
  // find doesn't find a substring:
  return str.find(substring) != std::string::npos;
}

// [[Rcpp::export]]
std::string replaceAll (std::string& str, const std::string& from, const std::string& to) 
{
  // Define the start position for the search of the string which we want to
  // replace:
  size_t start_pos = 0;
  
  // Iterate as long as from is a substring of the start_pos-th character 
  // to the end of str:
  while ((start_pos = str.find(from, start_pos)) != std::string::npos) {
    
    // Replace from with to:
    str.replace(start_pos, from.length(), to);
    
    // Update start_pos to search for the next substring to replace:
    start_pos += to.length();
  }
  
  // Return the new str:
  return str;
}

// [[Rcpp::export]]
std::string stringBetween (const std::string& str, const std::string& start_delim,
  const std::string& stop_delim)
{
  // Temporary string which stores input string str:
  std::string out = str;
  
  // If none of the start and end delimeter exists return just str:
  if ((str.find(start_delim) != std::string::npos) && (str.find(stop_delim) != std::string::npos)) {
    
    // Get very first position of the start delimeter and add the length of 
    // the string to get the first character which we wanna have:
    unsigned first_delim_pos = str.find(start_delim);
    unsigned end_pos_of_first_delim = first_delim_pos + start_delim.length();
    
    // Get position of first character of the end delimeter:
    unsigned last_delim_pos = str.find(stop_delim);
    
    // The substring is then the string from first_delim_pos with the length
    // of last_delim_pos - end_pos_of_first_delim:
    out = str.substr(end_pos_of_first_delim, last_delim_pos - end_pos_of_first_delim);
  }
  return out;
}

// [[Rcpp::export]]
std::string deleteStringBetween (const std::string& str, const std::string& start_delim,
  const std::string& stop_delim)
{
  // Temporary strings:
  std::string out = str;
  std::string between;
  
  // Define the start position for the search of the string which we want to
  // replace:
  size_t start_pos = 0;
  
  while ( ((out.find(start_delim, start_pos)) != std::string::npos) && 
          ((start_pos = out.find(stop_delim, start_pos)) != std::string::npos) ) {
    
    // Get very first position of the start delimeter and add the length of 
    // the string to get the first character which we wanna have:
    unsigned first_delim_pos = out.find(start_delim);
    unsigned end_pos_of_first_delim = first_delim_pos + start_delim.length();
    
    if (start_pos - end_pos_of_first_delim > 0) {
      // The substring is then the string from first_delim_pos with the length
      // of last_delim_pos - end_pos_of_first_delim:
      between = out.substr(end_pos_of_first_delim, start_pos - end_pos_of_first_delim);
      
      // Delete substring with delimeter:
      std::string remove = start_delim + between + stop_delim;
      out = replaceAll(out, remove, "");
      
      start_pos += remove.length();
    } else {
      start_pos += 1;
    }
  }
  return out;
}

// [[Rcpp::export]]
unsigned int countLinesOfExternalFile (std::string& connection)
{
  // Needs to be compiled with -std=c++11 flag! 
  std::ifstream myfile(connection);
  
  // new lines will be skipped unless we stop it from happening:    
  myfile.unsetf(std::ios_base::skipws);
  
  // count the newlines with an algorithm specialized for counting:
  unsigned int line_count = std::count(
    std::istream_iterator<char>(myfile),
    std::istream_iterator<char>(), 
    '\n');
  
  return line_count;
}

// [[Rcpp::export]]
std::string deleteStrings (std::string& str, std::vector<std::string>& vec)
{
  std::string temp = str;
  
  for(std::vector<std::string>::iterator it = vec.begin(); it != vec.end(); ++it) {
    temp = replaceAll(temp, *it, "");
  }
  return temp;
}

// [[Rcpp::export]]
std::string extractLetters (std::string test)
{
  std::string input = test;
  std::string letters;
  
  std::copy_if(input.begin(), input.end(), back_inserter(letters), [](const char i) { 
    return (std::isalpha(i) || std::isblank(i)) && __isascii(i); 
  });
  
  return letters;
}

// [[Rcpp::export]]
void extractTextBetweenTextTags (std::string& connection, std::string& out_file,
  std::vector<std::string> expressions, const int n)
{
  // Open file from connection:
  std::ifstream infile(connection);
  
  // Needs to be compiled with -std=c++11 flag! 
  std::ofstream mynewfile;
  
  // Open new txt file, the text wil go in there:
  mynewfile.open(out_file);
  
  // Logical if the actual line is between text tags:
  bool write_to_stream = false;
  
  // Temporary variable which stores the actual line:
  std::string line;
  
  // Define counter for the number of lines:
  int k = 1;
  
  // Now iterate over all lines from connection:
  while (std::getline(infile, line) && (k <= n))
  {
    // If the line includes the end tag of text, then stop writing to
    // the stream:
    if (substringInString(line, "</text>")) {
      write_to_stream = false;
    }
    // If the text is between the text tags, write to stream:
    if (write_to_stream) {
      
      // Now set the rules to select plain text!
      
      // Just keep lines with more than 250 characters:
      if (line.length() >= 250) {
        
        // Delete some strings between braces which illustrates Images or other
        // stuff:
        line = deleteStringBetween(line, "[[", "|");
        line = deleteStringBetween(line, "[http", "]");
        
        // Delete regulare expressions and special strings given via parameter:
        line = deleteStrings(line, expressions);
        
        // Extract letters which are encoded as ascii (english language):
        line = extractLetters(line);
        
        // To lowercase:
        std::transform(line.begin(), line.end(), line.begin(), ::tolower);
        
        // Replace "  " with " ":
        line = replaceAll(line, "  ", " ");
        
        std::istringstream iss(line);
        mynewfile << line << std::endl;
        
        // increment k if line was written to file:
        k += 1;
      }

    } // end if (write_to_stream)
    
    // If the line includes the opening text tag, then start writing to 
    // the stream:
    if (substringInString(line, "<text")) {
      write_to_stream = true;
    }
  }
  // Close output stream:
  mynewfile.close();
}
