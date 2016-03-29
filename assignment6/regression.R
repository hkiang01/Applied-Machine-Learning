library('caret') #createDataPartition
library('stats') #lm

#You should ignore outliers.
#You should regard latitude and longitude as entirely independent.

#last 2 cols are lat and long

setwd('/Users/harry/projects/aml/assignment6/')
rawdat<-read.csv('default_plus_chromatic_features_1059_tracks.txt', header=FALSE)
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

#we're allowed to use lm and glmnet
# https://piazza.com/class/ijn48296bq5tc?cid=477
# lm doc: https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html
xdat_obj<-as.matrix(xdat)
y_lat_obj<-as.matrix(y_lat)
foo_lat<-data.frame(ind=xdat_obj[,c(1:ncol(xdat_obj))], dep=y_lat_obj[,c(1)])
foo_lat.lm<-lm(dep~xdat_obj,data=foo_lat) #the dimensions of y and model in forumla=y~model must be equal

for (feature in 1:ncol(xdat_obj))
{
  if(is.na(foo_lat.lm$coefficients[feature+1])==FALSE) #ignore features that are dependent on other features
    # http://stats.stackexchange.com/questions/25804/why-would-r-return-na-as-a-lm-coefficient
  {
    plot(x=foo_lat.lm$model$xdat_obj[,c(feature)],y=foo_lat.lm$fitted.values, main=paste("Latitute vs Feature ",feature),
       xlab=paste("Feature ",feature), ylab="Latitude")
    abline(a=foo_lat.lm$coefficients[1], b=foo_lat.lm$coefficients[feature+1])
  }
}

lat_r_squared_val<-summary(foo_lat.lm)$r.squared
lat_r_squared_val_adj<-summary(foo_lat.lm)$adj.r.squared


#LONGITUDE

#we're allowed to use lm and glmnet
# https://piazza.com/class/ijn48296bq5tc?cid=477
# lm doc: https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html
xdat_obj<-as.matrix(xdat)
y_long_obj<-as.matrix(y_long)
foo_long<-data.frame(ind=xdat_obj[,c(1:ncol(xdat_obj))], dep=y_long_obj[,c(1)])
foo_long.lm<-lm(dep~xdat_obj,data=foo_long) #the dimensions of y and model in forumla=y~model must be equal

for (feature in 1:ncol(xdat_obj))
{
  if(is.na(foo_long.lm$coefficients[feature+1])==FALSE) #ignore features that are dependent on other features
    # http://stats.stackexchange.com/questions/25804/why-would-r-return-na-as-a-lm-coefficient
    {
      plot(x=foo_long.lm$model$xdat_obj[,c(feature)],y=foo_long.lm$fitted.values, main=paste("Longitude vs Feature ",feature),
       xlab=paste("Feature ",feature), ylab="Longitude")
      abline(a=foo_long.lm$coefficients[1], b=foo_long.lm$coefficients[feature+1])
    }
}

long_r_sqared_val<-summary(foo_long.lm)$r.squared
long_r_squared_val_adj<-summary(foo_long.lm)$adj.r.squared
