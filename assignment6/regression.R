library('caret') #createDataPartition
library('stats') #lm

#You should ignore outliers.
#You should regard latitude and longitude as entirely independent.

#last 2 cols are lat and long

setwd('/Users/harry/projects/aml/assignment6/')
rawdat<-read.csv('default_features_1059_tracks.txt', header=FALSE)
xdat<-rawdat[,-c(ncol(rawdat),ncol(rawdat)-1)]
ydat<-rawdat[,c(ncol(rawdat)-1,ncol(rawdat))]
y_lat<-ydat[,c(1)]
y_long<-ydat[,c(2)]

#Normalize
#xdat_norm<-scale(xdat, center=TRUE, scale=TRUE)

#First, build a straightforward linear regression of latitude (resp. longitude) against features.
#What is the R-squared? Plot a graph evaluating each regression.
# y = t(x)*β + ξ, where β is the vector of weights, ξ is random with 0 mean (unmodelled)
#Goal: estimate β

#LATITUDE

# #split into training and test
# tr_indices<-createDataPartition(y=y_lat, p=.8, list=FALSE)
# #80% training
# x_train<-xdat[tr_indices,]
# y_lat_train<-y_lat[tr_indices]
# #20% test
# x_test<-xdat[-tr_indices,]
# y_lat_test<-y_lat[-tr_indices]

#we're allowed to use lm and glmnet
# https://piazza.com/class/ijn48296bq5tc?cid=477
# lm doc: https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html
xdat_obj<-as.matrix(xdat)
y_lat_obj<-as.matrix(y_lat)
foo<-data.frame(ind=xdat_obj[,c(1:ncol(xdat_obj))], dep=y_lat_obj[,c(1)])
#foo.ind<-xdat_obj
#foo.dep<-y_lat_obj
foo.lm<-lm(dep~xdat_obj,data=foo) #the dimensions of y and model in forumla=y~model must be equal

for (feature in 1:ncol(xdat_obj))
{
  plot(x=foo.lm$model$xdat_obj[,c(feature)],y=foo.lm$fitted.values, main=paste("Latitute vs Feature ",feature),
       xlab=paste("Feature ",feature), ylab="Latitude")
  abline(a=foo.lm$coefficients[1], b=foo.lm$coefficients[feature+1])
}

r_squared_val<-summary(foo.lm)$r.squared
r_squared_val_adj<-summary(foo.lm)$adj.r.squared
