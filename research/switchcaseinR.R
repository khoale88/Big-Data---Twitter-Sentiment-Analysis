library(stringr)
searchTerm <- "Climate March love"
words_count <- sapply(gregexpr("\\W+", searchTerm), length) + 1
words_count
search_words <- tolower(searchTerm)
if (words_count < 2) {
  print("1 word")
  word1 <- search_words
  print(word1)
} else if (words_count < 3) {
  print("2 words")
  word1 <- word(search_words,-2)
  word2 <- word(search_words,-1)
  word3 <- paste(word1,word2, sep = "")
  cat(word1, word2, word3)
}else if (words_count < 4) {
  print("3 words")
  word1 <- word(search_words,-3)
  word2 <- word(search_words,-2)
  word3 <- word(search_words,-1)
  word4 <- paste(word1,word2, sep = "")
  word5 <- paste(word2,word3, sep = "")
  cat(word1, word2, word3, word4, word5)
} else {
  print("3 words")
  word1 <- word(search_words,-4)
  word2 <- word(search_words,-3)
  word3 <- word(search_words,-2)
  word4 <- word(search_words,-1)
  word5 <- paste(word1,word2, sep = "")
  word6 <- paste(word2,word3, sep = "")
  word7 <- paste(word3,word4, sep = "")
  cat(word1, word2, word3, word4, word5, word6, word7)
}
  

