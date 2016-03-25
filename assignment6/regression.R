#You should ignore outliers.
#You should regard latitude and longitude as entirely independent.

#last 2 cols are lat and long

setwd('/Users/harry/projects/aml/assignment6/')
rawdat<-read.csv('default_features_1059_tracks.txt', header=FALSE)
xdat<-rawdat[,-c(ncol(rawdat),ncol(rawdat)-1)]
ydat<-rawdat[,c(ncol(rawdat),ncol(rawdat)-1)]

#First, build a straightforward linear regression of latitude (resp. longitude) against features.
#What is the R-squared? Plot a graph evaluating each regression.

