library(httr)
library(tm)
library(ggplot2)
library(RColorBrewer)
library(wordcloud)
library(twitteR)
require(tm.plugin.webmining)
library(NLP)
require(rJava)
require(openNLP)
require(qdap)
library(qdapTools)
library(qdapDictionaries)
library(qdapRegex)
library("doBy")
library(plyr)
setup_twitter_oauth('bROy3QOsXzlIEA46VERbsEC0Q', 'trzN0KCB4bPUxgUSAYu5VF1RuwNEQuv4Blvw4ur7DRIIB99h3Q', access_token=NULL, access_secret=NULL)
delta.tweets = searchTwitter('@delta', n=500)
tweet = delta.tweets[[1]]
delta.text = laply(delta.tweets, function(t) t$getText() )
head(delta.text, 5)
delta.text=str_replace_all(delta.text,"[^[:graph:]]", " ")


sjsu.tweets = searchTwitter('@sjsu', n=100)
tweet = sjsu.tweets[[1]]
sjsu.text = laply(sjsu.tweets, function(t) t$getText() )
head(sjsu.text, 5)
pos <- scan('positive-words.txt', what='character', comment.char=';') #folder with positive dictionary
neg <- scan('negative-words.txt', what='character', comment.char=';') #folder with negative dictionary

score.sentiment = function(sentences, pos, neg)
{
  require(plyr)
  require(stringr)
  
  # we got a vector of sentences. plyr will handle a list
  # or a vector as an "l" for us
  # we want a simple array ("a") of scores back, so we use 
  # "l" + "a" + "ply" = "laply":
  scores = laply(sentences, function(sentence, pos, neg) {
    
    # clean up sentences with R's regex-driven global substitute, gsub():
    sentence = gsub('[[:punct:]]', '', sentence)
    sentence = gsub('[[:cntrl:]]', '', sentence)
    sentence = gsub('\\d+', '', sentence)
    # and convert to lower case:
    sentence = tolower(sentence)
    
    # split into words. str_split is in the stringr package
    word.list = str_split(sentence, '\\s+')
    # sometimes a list() is one level of hierarchy too much
    words = unlist(word.list)
    
    # compare our words to the dictionaries of positive & negative terms
    pos.matches = match(words, pos)
    neg.matches = match(words, neg)
    
    # match() returns the position of the matched term or NA
    # we just want a TRUE/FALSE:
    pos.matches = !is.na(pos)
    neg.matches = !is.na(neg)
    
    # and conveniently enough, TRUE/FALSE will be treated as 1/0 by sum():
    score = sum(pos.matches) - sum(neg.matches)
    
    return(score) 
}, pos, neg )
  require(reshape2)

#  sentences$id <- rownames(sentences) 
#  melt(sentences)
  scores.df = data.frame(score=scores,text=sentences)
  return(scores.df)
}
# calculate the scores
delta.scores = score.sentiment(delta.text, pos,neg)

#adding two columns
delta.scores$airline = 'Delta'
delta.scores$code = 'DL'

##plotting
qplot(delta.scores$score)
american.tweets = searchTwitter('@AmericanAir', n=500)
american.text = laply(american.tweets, function(t) t$getText() )
american.text=str_replace_all(american.text,"[^[:graph:]]", " ")


american.scores = score.sentiment(american.text, pos,neg)

american.scores$airline = 'American'
american.scores$code = 'AA'

#@united


united.tweets = searchTwitter('@united', n=500)
united.text = laply(united.tweets, function(t) t$getText() )
united.text=str_replace_all(united.text,"[^[:graph:]]", " ")
united.scores = score.sentiment(united.text, pos,neg)
united.scores$airline = 'United'
united.scores$code = 'UA'



#@JetBlue
jetblue.tweets = searchTwitter('@JetBlue', n=500)
jetblue.text = laply(jetblue.tweets, function(t) t$getText() )
jetblue.text=str_replace_all(jetblue.text,"[^[:graph:]]", " ")
jetblue.scores = score.sentiment(jetblue.text, pos,neg)
jetblue.scores$airline = 'JetBlue'
jetblue.scores$code = 'JB'

#@SouthwestAir

southwest.tweets = searchTwitter('@SouthwestAir', n=500)
southwest.text = laply(southwest.tweets, function(t) t$getText() )
southwest.text=str_replace_all(southwest.text,"[^[:graph:]]", " ")
southwest.scores = score.sentiment(southwest.text, pos,neg)
southwest.scores$airline = 'Southwest'
southwest.scores$code = 'SA'

#combine all scores

all.scores = rbind( delta.scores,american.scores,united.scores, jetblue.scores, southwest.scores )


##positive and negative tweets

all.scores$very.pos = as.numeric( all.scores$score >= 2 )
all.scores$very.neg = as.numeric( all.scores$score <=- 2 )


##overall sentiment score is positive/negative
twitter.df = ddply(all.scores, c('airline', 'code'), summarise, pos.count = sum( very.pos ), neg.count = sum( very.neg ) )
twitter.df$all.count = twitter.df$pos.count + twitter.df$neg.count
twitter.df$score = round( 100 * twitter.df$pos.count /twitter.df$all.count )


#plotting for all scores

cbPalette=c("#a6cee3","#1f78b4",
            "#b2df8a",
            "#33a02c",
            "#fb9a99")



ggplot(data=all.scores) +  geom_bar(mapping=aes(x=score, fill=airline), binwidth=1) + facet_grid(airline~.) +  theme_bw() + scale_fill_manual(values=cbPalette)
##output for the sample
result = score.sentiment(sample, pos, neg)
##cleaning the data

sjsu.text=str_replace_all(sjsu.text,"[^[:graph:]]", " ")
# calculate the scores
sjsu.scores = score.sentiment(sjsu.text, pos,neg)
sjsu.scores$university = 'SJSU'
sjsu.scores$code = 'SJSU'

##plotting
qplot(sjsu.scores$score)

sfsu.tweets = searchTwitter('@sfsu', n=100)
sfsu.text = laply(sfsu.tweets, function(t) t$getText() )
sfsu.text=str_replace_all(sfsu.text,"[^[:graph:]]", " ")
sfsu.scores = score.sentiment(sfsu.text, pos,neg)
sfsu.scores$university = 'SFSU'
sfsu.scores$code = 'SFSU'

stanford.tweets = searchTwitter('@stanford', n=100)
stanford.text = laply(stanford.tweets, function(t) t$getText() )
stanford.text=str_replace_all(stanford.text,"[^[:graph:]]", " ")
stanford.scores = score.sentiment(stanford.text, pos,neg)
stanford.scores$university = 'Stanford'
stanford.scores$code = 'Stanford'

all.scores = rbind(sjsu.scores,sfsu.scores,stanford.scores)
##positive and negative tweets

all.scores$very.pos = as.numeric( all.scores$score >= 2 )
all.scores$very.neg = as.numeric( all.scores$score <=- 2 )


##overall sentiment score is positive/negative
twitter.df = ddply(all.scores, c('university', 'code'), summarise, pos.count = sum( very.pos ), neg.count = sum( very.neg ) )
twitter.df$all.count = twitter.df$pos.count + twitter.df$neg.count
twitter.df$score = round( 100 * twitter.df$pos.count /twitter.df$all.count )

#plotting for all scores
cbPalette=c("#a6cee3","#1f78b4",
            "#b2df8a")

ggplot(data=all.scores) +  geom_bar(mapping=aes(x=score, fill=university), binwidth=1) + facet_grid(university~.) +  theme_bw() + scale_fill_manual(values=cbPalette)

orderBy(~-score, twitter.df)
