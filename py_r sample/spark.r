library(sparklyr)
sc <- spark_connect(master = "local")

#Configure twitter API
api_key <- "AcJYBgHWc7FhEX0Ls4SsVBTkA"
api_secret <- "r4i8I6kGgm5I0Uyc9R9JHVste4lrGWtajP0CLbZjNif8P3AoFm"
access_token <- "4162930993-QsTezz6yeseB5AxEaxvu6aSz5ha9m1jVL9B2NUG"
access_token_secret <- "4Y71MZrnCI20GSDlWpWPYDYEfstvvWWo2j1TPJvbLsNPY"
 
library("twitteR")
setup_twitter_oauth(api_key,api_secret, access_token, access_token_secret)

library(dplyr)
searchTerm <- "#Bench press"
output_path <- ""

num_tweets <- 20

tweets <- searchTwitter(searchTerm, num_tweets, lang='en', resultType="recent") #can remove resultType=recent
tweets #to see the tweets

library("wordcloud") #for for word cloud
library("tm") #textmining package
library(stringr) #to count words


tweets_text <- sapply(tweets, function(x) x$getText()) #to get only text
tweets_text

tweets_tbl <- copy_to(sc, tweets_text)
