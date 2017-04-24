library(ggmap)#Load libraries
library(ggplot2)
hpars<-read.table("https://sites.google.com/site/arunsethuraman1/teaching/hpars.dat?revision=1")#Read in the density data
positions <- data.frame(lon=rnorm(20000, mean=-75.1803458, sd=0.05),
                        lat=rnorm(10000,mean=39.98352197, sd=0.05))#Simulate some geographical coordinates #Switch out for your data that has real GPS coords
map <- get_map(location=c(lon=-75.1803458,
                          lat=39.98352197), zoom=11, maptype='roadmap', color='bw')#Get the map from Google Maps
ggmap(map, extent = "device") +
  geom_density2d(data = positions, aes(x = lon, y = lat), size = 0.3) + 
  stat_density2d(data = positions, 
                 aes(x = lon, y = lat, fill = ..level.., alpha = ..level..), size = 0.01, 
                 bins = 16, geom = "polygon") + scale_fill_gradient(low = "green", high = "red") + 
  scale_alpha(range = c(0, 0.3), guide = FALSE)#Plot