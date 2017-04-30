#Configure twitter API
api_key <- "AcJYBgHWc7FhEX0Ls4SsVBTkA"
api_secret <- "r4i8I6kGgm5I0Uyc9R9JHVste4lrGWtajP0CLbZjNif8P3AoFm"
access_token <- "4162930993-QsTezz6yeseB5AxEaxvu6aSz5ha9m1jVL9B2NUG"
access_token_secret <- "4Y71MZrnCI20GSDlWpWPYDYEfstvvWWo2j1TPJvbLsNPY"

#install.prackages("tm") #textmining package
#install.packages("wordcloud") #for visuals
#to get twitter rate limit - getCurRateLimitInfo()

library("wordcloud")
library("tm")
library(stringr) #to count words

#Load Library
library("twitteR")
setup_twitter_oauth(api_key,api_secret, access_token, access_token_secret)

#searchTerm <- "Climate March"
args = commandArgs(trailingOnly=TRUE)
searchTerm <- "Climate March"
if (length(args)!=0) {
  # default output file
  searchTerm <- args[1]
}
no_tweets <- 100
#Getting tweets
tweets <- searchTwitter(searchTerm, no_tweets, lang='en', resultType="recent") #can remove resultType=recent
tweets #to see the tweets

#class(tweets) #to know class of tweets #output = list
tweets_text <- sapply(tweets, function(x) x$getText()) #to get only text

#convert to documents
tweet_corpus <- Corpus(VectorSource(tweets_text))
tweet_corpus

inspect(tweet_corpus[1]) #to look at first document 

#To clean tweets
tweet_clean <- tm_map(tweet_corpus, removePunctuation)
tweet_clean <- tm_map(tweet_clean, content_transformer(tolower))
tweet_clean <- tm_map(tweet_clean, removeWords, stopwords("english"))
tweet_clean <- tm_map(tweet_clean, removeNumbers)
tweet_clean <- tm_map(tweet_clean, stripWhitespace)

words_count <- sapply(gregexpr("\\W+", searchTerm), length) + 1
words_count
search_words <- tolower(searchTerm)
if (words_count < 2) {
  print("1 word")
  word1 <- search_words
  print(word1)
  tweet_clean <- tm_map(tweet_clean, removeWords, c("amp", word1))
} else if (words_count < 3) {
  print("2 words")
  word1 <- word(search_words,-2)
  word2 <- word(search_words,-1)
  word3 <- paste(word1,word2, sep = "")
  cat(word1, word2, word3)
  tweet_clean <- tm_map(tweet_clean, removeWords, c("amp", word1, word2, word3))
}else if (words_count < 4) {
  print("3 words")
  word1 <- word(search_words,-3)
  word2 <- word(search_words,-2)
  word3 <- word(search_words,-1)
  word4 <- paste(word1,word2, sep = "")
  word5 <- paste(word2,word3, sep = "")
  cat(word1, word2, word3, word4, word5)
  tweet_clean <- tm_map(tweet_clean, removeWords, c("amp", word1, word2, word3, word4, word5))
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
  tweet_clean <- tm_map(tweet_clean, removeWords, c("amp", word1, word2, word3, word4, word5, word6, word7))
}


#tweet_clean <- tm_map(tweet_clean, removeWords, c("climate", "march", "climatemarch", "amp"))

png(filename="/Users/Kandarp/Desktop/wordCloud.png")

#wordCloud
wordcloud(tweet_clean, random.order = F, max.words = 40, scale=c(3,0.5), colors = rainbow(50))

dev.off()
