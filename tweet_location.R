# Install and Activate Packages
library(sparklyr)
sc <- spark_connect(master = "local")
library(SparkR)
library(streamR)
library(RCurl)
library(RJSONIO)
library(stringr)
library('dismo')
library(devtools)
library(twitteR)
library('maps')
library('ggplot2')
library('XML')
library('data.table')
library("RJSONIO")
library('maps')
library('mapproj')
library("ggmap")
library(maptools)
library(maps)
setwd("/users/suejanehan/desktop/bigdata/twitter/big-data---twitter-sentiment-analysis")
setup_twitter_oauth('bROy3QOsXzlIEA46VERbsEC0Q', 'trzN0KCB4bPUxgUSAYu5VF1RuwNEQuv4Blvw4ur7DRIIB99h3Q', access_token=NULL, access_secret=NULL)
pos <- scan('positive-words.txt', what='character', comment.char=';') #folder with positive dictionary
neg <- scan('negative-words.txt', what='character', comment.char=';') #folder with negative dictionary
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



searchTerm <- "#Gucci"
searchResults <- searchTwitter(searchTerm, n = 50)  # Gather Tweets



tweetFrame <- twListToDF(searchResults)  # Convert to a nice dF
tweetFrame_tbl <- copy_to(sc, tweetFrame)
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
#if(tweet.sentiment=="positive") {
 # mp = mp + geom_point(aes(x=tweet.x, y=tweet.y), colour = "blue", size=3)
#} else if(tweet.sentiment=="neutral") {
#  mp = mp + geom_point(aes(x=tweet.x, y=tweet.y), colour = "grey90", size=3)
#} else {
#  mp = mp + geom_point(aes(x=tweet.x, y=tweet.y), colour = "darkorange1", size=3)
#}
map("world", fill=TRUE, col="white", bg="lightblue", ylim=c(-60, 90), mar=c(0,0,0,0))
points(tweet.y,tweet.x, col="red", pch=16)
mp <- NULL
mapWorld <- borders("world", colour="gray50", fill="gray50") # create a layer of borders
mp <- ggplot() +   mapWorld

mp <- mp + geom_point(aes(x=tweetData$tweet.x, y=tweetData$tweet.y, colour=factor(tweetScores$sentiment)), size=3) 
mp <- mp + labs(colour = "Sentiment")
png("image.png", width = 800, height = 600)
mp
dev.off()

bar <- ggplot(data=tweetScores, aes(x = factor(1), fill = factor(tweet.sentiment))) + geom_bar(width = 1)
pie <- bar + coord_polar(theta = "y")
pie <- pie + labs(fill="Sentiment") +  theme(axis.text = element_blank(),
                                             axis.ticks = element_blank(),
                                             axis.title.x= element_blank(),
                                             axis.title.y= element_blank(),
                                             panel.grid  = element_blank())
png("pie.png" , width=800, height = 600)
pie
dev.off()
