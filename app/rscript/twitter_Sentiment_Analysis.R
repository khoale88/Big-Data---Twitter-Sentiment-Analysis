#########################################################################################################
# Script name: twitter_Sentiment_Analysis.R                                                             #
# language: R                                                                                           #
# Subject: CMPE297 - Big Data                                                                           #        
# Purpose: The purpose of this script is to perform analysis on search term which is input from user    #
#          It performs:                                                                                 #
#                       1)  Find top trends worldwide, cleanse them and write to csv file               #
#                       2)  Find tweets related to search term, cleanse and write to a csv file         #
#                       3)  Perform wordcloud on cleased tweets                                         #
#                       4)  Perform sentiment analysis on tweets and plot them geographically           #
#                       5)  Find the percentage of positive, negative and neutral sentiments about a    #
#                           search term                                                                 #
#                                                                                                       #
#########################################################################################################
#                                 Connecting to Twitter API                                             #                
#########################################################################################################

#Configure twitter API
api_key <- "AcJYBgHWc7FhEX0Ls4SsVBTkA"
api_secret <- "r4i8I6kGgm5I0Uyc9R9JHVste4lrGWtajP0CLbZjNif8P3AoFm"
access_token <- "4162930993-QsTezz6yeseB5AxEaxvu6aSz5ha9m1jVL9B2NUG"
access_token_secret <- "4Y71MZrnCI20GSDlWpWPYDYEfstvvWWo2j1TPJvbLsNPY"

#Load Library
library("twitteR")
library(methods)
setup_twitter_oauth(api_key,api_secret, access_token, access_token_secret)


#########################################################################################################
#                                       Input search Term                                               #                
#########################################################################################################


args = commandArgs(trailingOnly=TRUE)
if (length(args) == 4) {
  print ("args = 3")
  searchTerm <- args[1]
  output_path <- args[2]
  file_prefix <- args[3]
  working_dir <- args[4]
  
} else if (length(args) == 1){
  print ("args = 1")
  searchTerm <- args[1]
  output_path <- ""
  working_dir <- ""
  file_prefix <- ""
}else {
  print ("args = 0")
  searchTerm <- "#Bench press"
  output_path <- ""
  working_dir <- ""
  file_prefix <- ""
}
 
num_tweets <- 3 #to define the number of tweets
#Getting tweets
tweets <- searchTwitter(searchTerm, num_tweets, lang='en', resultType="recent") #can remove resultType=recent
tweets #to see the tweets

#to get twitter rate limit - getCurRateLimitInfo()


#########################################################################################################
#                                 Find twitter trends worldwide                                         #                
#########################################################################################################

#output_path="." #Path to store output graphs and csv files

#to get top worldwide trends
world <- getTrends(1) #woeid for world  = 1
#world #to see top worldwide trends
trend <- world$name
trend
trend = gsub("[^0-9A-Za-z#///' ]", "", trend)
len_trend <- length(trend)
#nchar(trend[9])
#trend
j <- 1
trend_new <- NULL
#trend_new <- sapply(trend_new.names,function(x) NULL)
for(i in 1:len_trend) 
{
  if (nchar(trend[i]) > 2) {
    trend_new[j] <- trend[i]
    j <- j+ 1
  }
}

trend_new

#write.csv(trend_new, file='D:/297 Big data/BigDataProject/tweets_topTrend.csv', row.names=F)
topTrend_path <- paste(output_path, file_prefix, ".","tweets_topTrend.csv",sep="")
if(!file.exists(topTrend_path)){
  print(topTrend_path)
  print("does not exist")
  file.create(topTrend_path)
}
write.csv(trend_new, file=file.path(topTrend_path), row.names=F)


#########################################################################################################
#                                   Cleanse Tweets and write to file                                    #                
#########################################################################################################

library("wordcloud") #for for word cloud
library("tm") #textmining package
library(stringr) #to count words

#class(tweets) #to know class of tweets #output = list
tweets_text <- sapply(tweets, function(x) x$getText()) #to get only text
tweets_text

clean_tweet = gsub("&amp", "", tweets_text) #to remove amp
clean_tweet = gsub("\\n", " ", clean_tweet) #to remove newline character
clean_tweet = gsub("[[:digit:]]", "", clean_tweet) #removes digits
clean_tweet = gsub('http\\S+\\s*', '', clean_tweet) #to remove http links
clean_tweet = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", clean_tweet) #to remove handle
clean_tweet = gsub("|", "", clean_tweet) #to remove pipe sign
clean_tweet = gsub("?", "", clean_tweet) #to remove question mark sign
clean_tweet = gsub("[ \t]{2,}", "", clean_tweet) #to remove tabls
clean_tweet = gsub("^\\s+|\\s+$", "", clean_tweet) #to remove space

clean_tweet = gsub("@\\w+", "", clean_tweet) 
clean_tweet = gsub(":", "", clean_tweet)
clean_tweet = gsub("/", "", clean_tweet)
clean_tweet = gsub('\"', "", clean_tweet)
clean_tweet = gsub("[^0-9A-Za-z#///' ]", "", clean_tweet) #Removing any non-english character
clean_tweet #to view cleansed tweet

#write.csv(clean_tweet, file='D:/297 Big data/BigDataProject/tweets_cleansed.csv', row.names=F)
tweetsCleansed_path <- paste(output_path, file_prefix, ".", "tweets_cleansed.csv", sep="")
if(!file.exists(tweetsCleansed_path)){
  file.create(tweetsCleansed_path)
}
write.csv(clean_tweet, file=file.path(tweetsCleansed_path), row.names=F)


#########################################################################################################
#                                   Perform word Cloud on cleased tweets                                #                
#########################################################################################################

#convert to documents
tweet_corpus <- Corpus(VectorSource(clean_tweet))
tweet_corpus #to view document
inspect(tweet_corpus[1]) #to inspect at first document 

#To clean tweets
tweet_clean <- tm_map(tweet_corpus, removePunctuation)
tweet_clean <- tm_map(tweet_clean, content_transformer(tolower))
tweet_clean <- tm_map(tweet_clean, removeWords, stopwords("english"))
tweet_clean <- tm_map(tweet_clean, removeNumbers)
tweet_clean <- tm_map(tweet_clean, stripWhitespace)

words_count <- vapply(strsplit(searchTerm, "\\W+"), length, integer(1))

words_count #to count number of words in search term
search_words <- tolower(searchTerm)

#to find all combinations of search term in order to exclude it from word cloud
if (words_count < 2) {
  print("1 word")
  word1 <- search_words
  print(word1)
  tweet_clean <- tm_map(tweet_clean, removeWords, c(word1))
} else if (words_count < 3) {
  print("2 words")
  word1 <- word(search_words,-2)
  word2 <- word(search_words,-1)
  word3 <- paste(word1,word2, sep = "")
  cat(word1, word2, word3)
  tweet_clean <- tm_map(tweet_clean, removeWords, c(word1, word2, word3))
}else if (words_count < 4) {
  print("3 words")
  word1 <- word(search_words,-3)
  word2 <- word(search_words,-2)
  word3 <- word(search_words,-1)
  word4 <- paste(word1,word2, sep = "")
  word5 <- paste(word2,word3, sep = "")
  cat(word1, word2, word3, word4, word5)
  tweet_clean <- tm_map(tweet_clean, removeWords, c(word1, word2, word3, word4, word5))
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
  tweet_clean <- tm_map(tweet_clean, removeWords, c(word1, word2, word3, word4, word5, word6, word7))
}

#png(filename="D:/297 Big data/BigDataProject/wordCloud.png")
png(paste(output_path, file_prefix, ".", "wordCloud.png", sep=""), width=800, height = 600)
wordcloud(tweet_clean, random.order = F, max.words = 40, scale=c(3,0.5), colors = rainbow(50))
dev.off()


#########################################################################################################
#               Positive and Negative Sentiment analysis on a search term                               #                
#########################################################################################################

library(streamR)
library(RCurl)
library(RJSONIO)
library(devtools)
library(maptools)
library(maps)

library('ggplot2')
library('XML')
library('data.table')
library('mapproj')
library("ggmap")

positive_words = paste(working_dir,'positive-words.txt', sep = "")
pos <- scan(positive_words, what='character', comment.char=';') #folder with positive dictionary
negative_words = paste(working_dir,'negative-words.txt', sep = "")
neg <- scan(negative_words, what='character', comment.char=';') #folder with negative dictionary
pos.words <- c(pos, 'upgrade')
neg.words <- c(neg, 'wtf', 'wait', 'waiting', 'epicfail')

score.sentiment <- function(sentences, pos.words, neg.words, .progress='none'){
  require(plyr)
  require(stringr)
  scores <- laply(sentences, function(sentence, pos.words, neg.words){
    sentence <- gsub('[[:punct:]]', "", sentence)
    sentence <- gsub('[[:cntrl:]]', "", sentence)
    sentence <- gsub('\\d+', "", sentence)
    sentence <- str_replace_all(sentence,"[^[:graph:]]", " ")
    sentence <- tolower(sentence)
    word.list <- str_split(sentence, '\\s+')
    words <- unlist(word.list)
    pos.matches <- match(words, pos.words)
    neg.matches <- match(words, neg.words)
    pos.matches <- !is.na(pos.matches)
    neg.matches <- !is.na(neg.matches)
    score <- sum(pos.matches) - sum(neg.matches)
    return(score)
  }, pos.words, neg.words, .progress=.progress)
  scores.df <- data.frame(score=scores, text=sentences)
  return(scores.df)
}

tweetFrame <- twListToDF(tweets)  # Convert to a nice dF
tweetText <- tweetFrame$text
userInfo <- lookupUsers(tweetFrame$screenName)  # Batch lookup of user info
userFrame <- twListToDF(userInfo)  # Convert to a nice dF
locations <- geocode(userFrame$location[!userFrame$location %in% ""])
tweet.x <- locations$lon
tweet.y <- locations$lat
tweetScores <- score.sentiment(tweetText, pos.words, neg.words, .progress='text')
tweetScores <- mutate(tweetScores, sentiment=ifelse(tweetScores$score > 0, 'positive', ifelse(tweetScores$score < 0, 'negative', 'neutral')))
tweet.sentiment <- tweetScores$sentiment
tweetFrame <- cbind(tweetFrame$screenName, tweet.sentiment)
tweetFrame

sapply(locations, class)
#evaluation tweets function
tweet.x <- na.omit(tweet.x)
tweet.y <- na.omit(tweet.y)
tweet.sentiment <- as.factor(tweet.sentiment)
tweet.sentiment <- na.omit(tweet.sentiment)
tweet.sentiment

#Now Layer the cities on top
tweetData <- cbind(tweet.x,tweet.y,tweet.sentiment)
tweetData <- data.frame(tweetData)
tweetData <- mutate(tweetData, sentiment=ifelse(tweetData$tweet.sentiment > 0, 'positive', ifelse(tweetData$tweet.sentiment < 0, 'negative', 'neutral')))
tweetData

map("world", fill=TRUE, col="white", bg="lightblue", ylim=c(-60, 90), mar=c(0,0,0,0))
points(tweet.y,tweet.x, col="red", pch=16)
mp <- NULL
mapWorld <- borders("world", colour="gray50", fill="gray50") # create a layer of borders
mp <- ggplot() +   mapWorld

mp <- mp + geom_point(aes(x=tweetData$tweet.x, y=tweetData$tweet.y, colour=factor(tweetScores$sentiment)), size=3) 
mp <- mp + labs(colour = "Sentiment")

png(paste(output_path, file_prefix, ".", "loc.png", sep=""), width=800, height = 600)
mp
dev.off()

bar <- ggplot(data=tweetScores, aes(x = factor(1), fill = factor(tweet.sentiment))) + geom_bar(width = 1)
pie <- bar + coord_polar(theta = "y")
pie <- pie + labs(fill="Sentiment") +  theme(axis.text = element_blank(),
                                             axis.ticks = element_blank(),
                                             axis.title.x= element_blank(),
                                             axis.title.y= element_blank(),
                                             panel.grid  = element_blank())


png(paste(output_path, file_prefix, ".", "pie.png", sep=""), width=800, height = 600)
pie
dev.off()
