#! /usr/bin/Rscript
library(ggplot2)

#take in 2 argument, 1 for searchTerm, 1 for path to a directory to store graphs
args = commandArgs(trailingOnly=TRUE)
if (length(args) != 2) {
  stop("Need exactly arguments, searchTerm and path to output folder", call.=FALSE)
} else {
  searchTerm <- args[1]
  output_path <- args[2]
  print( paste( "graphs will be stored in:", output_path, sep=" "))
}

fit <- lm(mpg ~ hp + I(hp), data = mtcars)
prd <- data.frame(hp = seq(from = range(mtcars$hp)[1], to = range(mtcars$hp)[2], length.out = 100))
err <- predict(fit, newdata = prd, se.fit = TRUE)

prd$lci <- err$fit - 1.96 * err$se.fit
prd$fit <- err$fit
prd$uci <- err$fit + 1.96 * err$se.fit

#save graph to output_path
png(filename = output_path)

ggplot(prd, aes(x = hp, y = fit)) +
  ggtitle(searchTerm)+
  theme_bw() +
  geom_line() +
  geom_smooth(aes(ymin = lci, ymax = uci), stat = "identity") +
  geom_point(data = mtcars, aes(x = hp, y = mpg)) 


dev.off()