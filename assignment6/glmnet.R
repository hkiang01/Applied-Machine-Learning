library('caret') #createDataPartition
library('stats') #lm
library('glmnet') #glmnet

#You should ignore outliers.
#You should regard latitude and longitude as entirely independent.

#last 2 cols are lat and long

setwd('/Users/harry/projects/aml/assignment6/')
rawdat<-read.csv('default_plus_chromatic_features_1059_tracks.txt', header=FALSE)
xdat<-rawdat[,-c(ncol(rawdat),ncol(rawdat)-1)]
ydat<-rawdat[,c(ncol(rawdat)-1,ncol(rawdat))]
y_lat<-ydat[,c(1)]
y_long<-ydat[,c(2)]

# Use glmnet to produce...

# A regression regularized by L2 (equivalently, a ridge regression).
# You should estimate the regularization coefficient that produces the minimum error.
# Is the regularized regression better than the unregularized regression?

#latitude
xdat_obj<-as.matrix(xdat)
y_lat_obj<-as.matrix(y_lat)

dmodel_lat<-cv.glmnet(xdat_obj, y_lat_obj, alpha=0)
min_lambda_lat<-dmodel$lambda.min

#longitude
#xdat_obj<-as.matrix(xdat)
y_long_obj<-as.matrix(y_long)

dmodel_long<-cv.glmnet(xdat_obj, y_long_obj, alpha=0)
min_lambda_long<-dmodel$lambda.min