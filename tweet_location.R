library('twitteR')
library('dismo')
library('maps')
library('ggplot2')
library('XML')
library('data.table')
library("RJSONIO")
library('maps')
library('mapproj')
setup_twitter_oauth('bROy3QOsXzlIEA46VERbsEC0Q', 'trzN0KCB4bPUxgUSAYu5VF1RuwNEQuv4Blvw4ur7DRIIB99h3Q', access_token=NULL, access_secret=NULL)

searchTerm <- "#bigdata"
searchResults <- searchTwitter(searchTerm, n = 200)  # Gather Tweets 
tweetFrame <- twListToDF(searchResults)  # Convert to a nice dF

userInfo <- lookupUsers(tweetFrame$screenName)  # Batch lookup of user info
userFrame <- twListToDF(userInfo)  # Convert to a nice dF


locations <- geocode(userFrame$location[!userFrame$location %in% ""])
# approximate lat/lon from textual location data.
with(locations, plot(longitude, latitude))

worldMap <- map_data("world")  # Easiest way to grab a world map shapefile

zp1 <- ggplot(worldMap)

zp1 <- zp1 + geom_path(aes(x = longitude, y = latitude, group = group),  # Draw map
                       colour = gray(2/3), lwd = 1/3)
zp1 <- zp1 + geom_point(data = locations,  # Add points indicating users
                        aes(x = longitude, y = latitude),
                        colour = "RED", alpha = 1/2, size = 1)
zp1 <- zp1 + coord_equal()  # Better projections are left for a future post
zp1 <- zp1 + theme_minimal()  # Drop background annotations
print(zp1)
