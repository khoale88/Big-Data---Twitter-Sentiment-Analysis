# Install and Activate Packages

#get arguments from command line, stop if length of arguments is different than 2
args = commandArgs(trailingOnly=TRUE)
if (length(args) != 2) {
  stop("Need exactly arguments, searchTerm and path to output folder", call.=FALSE)
} else {
  searchTerm <- args[1]
  output_path <- args[2]
  print( paste( "graphs will be stored in:", output_path, sep=" "))
}

#import library
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

setwd(".")
setup_twitter_oauth('AcJYBgHWc7FhEX0Ls4SsVBTkA',
                    'r4i8I6kGgm5I0Uyc9R9JHVste4lrGWtajP0CLbZjNif8P3AoFm',
                    access_token="4162930993-QsTezz6yeseB5AxEaxvu6aSz5ha9m1jVL9B2NUG",
                    access_secret="4Y71MZrnCI20GSDlWpWPYDYEfstvvWWo2j1TPJvbLsNPY")

pos <- scan('rscript/positive-words.txt', what='character', comment.char=';') #folder with positive dictionary
neg <- scan('rscript/negative-words.txt', what='character', comment.char=';') #folder with negative dictionary
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

#searchTerm <- "#Gucci" #we dont need searchTerm here anymore since we import it directly from cmd
searchResults <- searchTwitter(searchTerm, n = 50)  # Gather Tweets 
tweetFrame <- twListToDF(searchResults)  # Convert to a nice dF
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

#draw and export pie graph to output location
mp <- ggplot() +   mapWorld
mp <- mp + geom_point(aes(x=tweetData$tweet.x, y=tweetData$tweet.y, colour=factor(tweetScores$sentiment)), size=3) 
mp <- mp + labs(colour = "Sentiment")
png(paste(output_path,"loc.png"), width=800, height = 600)
mp
dev.off()

#draw and export pie graph to output location
bar <- ggplot(data=tweetScores, aes(x = factor(1), fill = factor(tweet.sentiment))) + geom_bar(width = 1)
png(paste(output_path,"bar.png"), width=800, height = 600)
bar
dev.off()

#draw and export pie graph to output location
pie <- bar + coord_polar(theta = "y")
pie <- pie + labs(fill="Sentiment") +  theme(axis.text = element_blank(),
                                             axis.ticks = element_blank(),
                                             axis.title.x= element_blank(),
                                             axis.title.y= element_blank(),
                                             panel.grid  = element_blank())
png(paste(output_path,"pie.png"), width=800, height = 600)
pie
dev.off()
