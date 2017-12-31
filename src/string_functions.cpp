#include <Rcpp.h>
#include <string>
#include <vector>
#include <fstream>

// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
bool substringInString (std::string& str, const std::string& substring)
{
  return str.find(substring) != std::string::npos;
}

// [[Rcpp::export]]
std::string replaceAll (std::string& str, const std::string& from, const std::string& to) 
{
  size_t start_pos = 0;
  while ((start_pos = str.find(from, start_pos)) != std::string::npos) {
    str.replace(start_pos, from.length(), to);
    start_pos += to.length();
  }
  return str;
}

// [[Rcpp::export]]
std::string stringBetween (const std::string& s, const std::string& start_delim,
                           const std::string& stop_delim)
{
  std::string out = s;
  
  if ((s.find(start_delim) != std::string::npos) && (s.find(stop_delim) != std::string::npos)) {
    unsigned first_delim_pos = s.find(start_delim);
    unsigned end_pos_of_first_delim = first_delim_pos + start_delim.length();
    unsigned last_delim_pos = s.find(stop_delim);
    
    out = s.substr(end_pos_of_first_delim, last_delim_pos - end_pos_of_first_delim);
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
void getLinesBetweenTextTags (std::string& connection)
{
  std::ifstream infile(connection);
  
  // Needs to be compiled with -std=c++11 flag! 
  std::ofstream mynewfile;
  mynewfile.open("extraction.txt");
  
  bool write_to_stream = false;
  
  std::string line;
  
  while (std::getline(infile, line))
  {
    if (substringInString(line, "</text>")) {
      write_to_stream = false;
    }
    if (write_to_stream) {
      std::istringstream iss(line);
      mynewfile << line << std::endl;
    }
    if (substringInString(line, "<text")) {
      write_to_stream = true;
    }
  }
  mynewfile.close();
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