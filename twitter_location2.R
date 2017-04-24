
library(mapproj)
library(ggplot2)
setup_twitter_oauth('bROy3QOsXzlIEA46VERbsEC0Q', 'trzN0KCB4bPUxgUSAYu5VF1RuwNEQuv4Blvw4ur7DRIIB99h3Q', access_token=NULL, access_secret=NULL)

searchTerm <- "#bigdata"
TwitterData <- searchTwitter(searchTerm, n = 200)  # Gather Tweets 
CleanUpTwitterStream = function(data) {
  
  pos = 1
  data = as.matrix(data)
  n = nrow(data)
  
  # 1. preallocate 1 million positions (any additional space needed will be
  # allocated slowly)
  
  storedCoordinates = rep(0, 1e+06)
  
  for (i in 1:n) {
    tweet = data[i]
    tweet <- gsub('[[:punct:]]', "", tweet)
    tweet <- gsub('[[:cntrl:]]', "", tweet)
    
    rawCoordinates = unlist(strsplit(tweet, "coordinates", fixed = TRUE))
    
    if (i/50 == i%/%50) {
      
      cat("extracting coordinates - iteration", i, "of", n, "\n")
      
    }
    
    for (j in 1:length(rawCoordinates)) {
      
      line = unlist(strsplit(rawCoordinates[j], "]},"))[1]
      
      # 2. a series of manipulations to reformat the datas
      
      line = paste(line, "]", sep = "")
      
      line = gsub("\\:", "", line, fixed = TRUE)
      line = gsub("[", "c(", line, fixed = TRUE)
      line = gsub("]", ")", line, fixed = TRUE)
      
      # 3. if the line consists of only these characters, and it has the right
      # length, it is assummed to be geotag data
      
      characterSet = unique(unlist(strsplit(line, "")))
      expected = c(as.character(0:9), ".", "c", "(", ")", "-", ",")
      
      if (prod(is.element(characterSet, expected)) == 1 && nchar(line) > 
          5) {
        
        storedCoordinates[pos:pos + length(line)] = line
        pos = pos + (length(line))
        
      }
      
    }
    
  }
  
  parsedCoordinates = list()
  
  for (i in 1:pos) {
    
    if (i/50 == i%/%50) {
      
      cat("parsing coordinates - iteration", i, "of", pos, "\n")
      
    }
    
    # 4. add each parsed line to a list of coordinates
    
    parsedCoordinates[[i]] = eval(parse(text = storedCoordinates[i]))
    
  }
  
  return(parsedCoordinates)
  
}

LongLatCoordinates = function(parsedCoordinates) {
  longitudes = latitudes = rep(0, 1e+06)
  count = i = pos = 1
  loopSize = length(unlist(parsedCoordinates))
  while (count < loopSize) {
    coordinateSet = unlist(parsedCoordinates[[i]])
    longitudesPos = 2 * (1:(0.5 * length(coordinateSet)))
    latitudesPos = longitudesPos - 1
    longitudes[pos:(pos + length(longitudesPos) - 1)] = coordinateSet[longitudesPos]
    latitudes[pos:(pos + length(latitudesPos) - 1)] = coordinateSet[latitudesPos]
    count = count + length(coordinateSet)
    i = i + 1
    pos = pos + length(longitudesPos) - 1
  }
  data = list("coordinates")
  data$longitudes = longitudes[1:pos]
  data$latitudes = latitudes[1:pos]
  return(data)
}

TwitterData = CleanUpTwitterStream(TwitterData)
TwitterData = LongLatCoordinates(TwitterData)

require(mapproj)
TwitterData = mapproject(y = TwitterData$longitudes, x = TwitterData$latitudes, "mollweide")

MapDataPlot = function(mappedData) {
  
  require(ggplot2)
  # F5B342 FFFF99
  
  x = mappedData$x
  y = mappedData$y
  time = length(x):1
  
  mappedData = data.frame(x, y, time)
  plotData = ggplot(mappedData, aes(x, y, colour = time, alpha = time))
  plotData = plotData + geom_point(shape = ".") + theme_bw() + scale_colour_gradient(low = "#FFFFFF",  high = "#F5B342", guide = "none") + scale_alpha(guide = "none")
  
  print(plotData)
  
}

MapDataPlot(TwitterData)
