# Creating twitter dev account (Important)
1. Create Twitter account
2. Go to:  https://apps.twitter.com/
3. Click on create new app
4. Use the credentials in R script to connect to twitter api and access Tweets
5. Create file "twitter_token.csv" inside rscript folder with 4 headers: "api_key", "api_secret", "access_token", "access_token_secret" and their values

# Dependency
1. r-base:3.4
2. python:2.7

## Install following packages to successfully run R script 
1. twitteR 
2. methods
3. wordcloud
4. tm
5. stringr
6. streamR
7. RCurl
8. RJSONIO
9. devtools
10. maptools
11. maps
12. ggplot2
13. XML
14. data.table
15. mapproj
16. ggmap

## Install following library to run Python
1. Flask

# Run application natively in local environment
1. Install all dependency mentioned above
2. Open terminal in the folder where main.py is present
3. Execute the command: python main.py 

# Run application in docker environment
1. Install docker
2. Open terminal in the folder where Dockerfile is present
3. Execute the command: docker build -t tsa .
4. Execute the command: docker run -d -p 5000:5000 tsa
5. Open webpage at Localhost:5000 for Ubuntu, or <VM_IPaddress>:5000 for Mac or Windows

