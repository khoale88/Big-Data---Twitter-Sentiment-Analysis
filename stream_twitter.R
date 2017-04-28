
# PART 1: Declare Twitter API Credentials & Create Handshake
library(ROAuth)
requestURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"
consumerKey <- "bROy3QOsXzlIEA46VERbsEC0Q" # From dev.twitter.com
consumerSecret <- "trzN0KCB4bPUxgUSAYu5VF1RuwNEQuv4Blvw4ur7DRIIB99h3Q" # From dev.twitter.com

my_oauth <- OAuthFactory$new(consumerKey = "bROy3QOsXzlIEA46VERbsEC0Q",
                             consumerSecret = "trzN0KCB4bPUxgUSAYu5VF1RuwNEQuv4Blvw4ur7DRIIB99h3Q",
                             requestURL = requestURL,
                             accessURL = accessURL,
                             authURL = authURL)
my_oauth$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))

### STOP HERE!!! ###

# PART 2: Save the my_oauth data to an .Rdata file
save(my_oauth, file = "my_oauth.Rdata")

filterStream(file.name = "tweets.json", # Save tweets in a json file
             track = c("Affordable Care Act", "ACA", "Obamacare"), # Collect tweets mentioning either Affordable Care Act, ACA, or Obamacare
             language = "en",
             timeout = 60, # Keep connection alive for 60 seconds
             oauth = my_oauth) # Use my_oauth file as the OAuth credentials

tweets.df <- parseTweets("tweets.json", simplify = FALSE) # parse the json file and save to a data frame called