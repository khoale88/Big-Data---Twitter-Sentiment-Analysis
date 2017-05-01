
# PART 1: Declare Twitter API Credentials & Create Handshake
library(ROAuth)
library("twitteR")
library(RCurl) 
library(streamR)
options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))
requestURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "http://api.twitter.com/oauth/access_token"
authURL <- "http://api.twitter.com/oauth/authorize"
consumerKey <- "TPtZR63Mzmbj87BTrMpOdsyRb" # From dev.twitter.com
consumerSecret <- "IucDHiVwFr7T9APxEzBjBMK3b2FqxCi2ObYBKHFs3c1wgeS8oA" # From dev.twitter.com
setup_twitter_oauth('TPtZR63Mzmbj87BTrMpOdsyRb', 'IucDHiVwFr7T9APxEzBjBMK3b2FqxCi2ObYBKHFs3c1wgeS8oA', access_token=NULL, access_secret=NULL)

my_oauth <- OAuthFactory$new(consumerKey = "TPtZR63Mzmbj87BTrMpOdsyRb",
                             consumerSecret = "IucDHiVwFr7T9APxEzBjBMK3b2FqxCi2ObYBKHFs3c1wgeS8oA",
                             requestURL = requestURL,
                             accessURL = accessURL,
                             authURL = authURL)
my_oauth$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))

### STOP HERE!!! ###c

# PART 2: Save the my_oauth data to an .Rdata file
save(my_oauth, file = "my_oauth.Rdata")

filterStream(file.name = "tweets.json", # Save tweets in a json file
             track = c("Affordable Care Act", "ACA", "Obamacare"), # Collect tweets mentioning either Affordable Care Act, ACA, or Obamacare
             language = "en",
             timeout = 60, # Keep connection alive for 60 seconds
             oauth = my_oauth) # Use my_oauth file as the OAuth credentials

tweets.df <- parseTweets("tweets.json", simplify = FALSE) # parse the json file and save to a data frame called