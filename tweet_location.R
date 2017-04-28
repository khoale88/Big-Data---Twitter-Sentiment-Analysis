
# Install and Activate Packages
install.packages("streamR", "RCurl", "ROAuth", "RJSONIO")
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
setup_twitter_oauth('bROy3QOsXzlIEA46VERbsEC0Q', 'trzN0KCB4bPUxgUSAYu5VF1RuwNEQuv4Blvw4ur7DRIIB99h3Q', access_token=NULL, access_secret=NULL)

searchTerm <- "#sjsu"
searchResults <- searchTwitter(searchTerm, n = 200)  # Gather Tweets 
tweetFrame <- twListToDF(searchResults)  # Convert to a nice dF

userInfo <- lookupUsers(tweetFrame$screenName)  # Batch lookup of user info
userFrame <- twListToDF(userInfo)  # Convert to a nice dF

locations <- geocode(userFrame$location[!userFrame$location %in% ""])
# approximate lat/lon from textual location data.

tweet.x <- locations$lon
tweet.y <- locations$lat

sapply(locations, class)
map("world", fill=TRUE, col="white", bg="lightblue", ylim=c(-60, 90), mar=c(0,0,0,0))
points(tweet.y,tweet.x, col="red", pch=16)
mp <- NULL
mapWorld <- borders("world", colour="gray50", fill="gray50") # create a layer of borders
mp <- ggplot() +   mapWorld

#Now Layer the cities on top
mp <- mp+ geom_point(aes(x=tweet.x, y=tweet.y) ,color="blue", size=3) 
mp
