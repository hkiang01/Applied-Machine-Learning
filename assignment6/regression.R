library('caret') #createDataPartition

#You should ignore outliers.
#You should regard latitude and longitude as entirely independent.

#last 2 cols are lat and long

setwd('/Users/harry/projects/aml/assignment6/')
rawdat<-read.csv('default_features_1059_tracks.txt', header=FALSE)
xdat<-rawdat[,-c(ncol(rawdat),ncol(rawdat)-1)]
ydat<-rawdat[,c(ncol(rawdat),ncol(rawdat)-1)]
y_lat<-ydat[,c(1)]
y_long<-ydat[,c(2)]

#First, build a straightforward linear regression of latitude (resp. longitude) against features.
#What is the R-squared? Plot a graph evaluating each regression.

#LATITUDE

#split into training and test
tr_indices<-createDataPartition(y=y_lat, p=.8, list=FALSE)
#80% training
x_train<-xdat[tr_indices,]
y_lat_train<-y_lat[tr_indices]
#20% test
x_test<-xdat[-tr_indices,]
y_lat_test<-y_lat[-tr_indices]

