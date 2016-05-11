library('caret') #createDataPartition
library('stats') #lm
library('MASS')  #boxcox

#You should ignore outliers.
#You should regard latitude and longitude as entirely independent.

#last 2 cols are lat and long

 setwd('~/projects/Applied-Machine-Learning/assignment6/') # harrison's
#setwd('/Users/annlinsheih/Dev/aml/assignment6') # annlin's
# source('~/Dev/aml/assignment6/regression.R')

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

predicted_lat<-foo_lat.lm$fitted.values
observed_lat<-y_lat_obj
residuals_lat<-foo_lat.lm$residuals

#predicted vs. observed
plot(x=observed_lat, y=predicted_lat, type="p",
     main="Predicted vs. Observed Latitude",
     xlab="Observed Latitude", ylab="Predicted Latitude")
#residuals vs predicted
plot(x=predicted_lat, y=residuals_lat, type="p", 
     main="Residual vs. Predicted Latitude",
     xlab="Predicted Latitude", ylab="Residual")

# for (feature in 1:ncol(xdat_obj))
# {
#   if(is.na(foo_lat.lm$coefficients[feature+1])==FALSE) #ignore features that are dependent on other features
#     # http://stats.stackexchange.com/questions/25804/why-would-r-return-na-as-a-lm-coefficient
#   {
#     plot(x=foo_lat.lm$model$xdat_obj[,c(feature)],y=foo_lat.lm$fitted.values, main=paste("Latitute vs Feature ",feature),
#        xlab=paste("Feature ",feature), ylab="Latitude")
#     abline(a=foo_lat.lm$coefficients[1], b=foo_lat.lm$coefficients[feature+1])
#   }
# }

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

predicted_long<-foo_long.lm$fitted.values
observed_long<-y_long_obj
residuals_long<-foo_long.lm$residuals

#predicted vs. observed
plot(x=observed_long, y=predicted_long, type="p",
     main="Predicted vs. Observed Longitude",
     xlab="Observed Longitude", ylab="Predicted Longitude")
#residuals vs predicted
plot(x=predicted_long, y=residuals_long, type="p",
     main="Residual vs. Predicted Longitude",
     xlab="Predicted Longitude", ylab="Residual")

# for (feature in 1:ncol(xdat_obj))
# {
#   if(is.na(foo_long.lm$coefficients[feature+1])==FALSE) #ignore features that are dependent on other features
#     # http://stats.stackexchange.com/questions/25804/why-would-r-return-na-as-a-lm-coefficient
#     {
#       plot(x=foo_long.lm$model$xdat_obj[,c(feature)],y=foo_long.lm$fitted.values, main=paste("Longitude vs Feature ",feature),
#        xlab=paste("Feature ",feature), ylab="Longitude")
#       abline(a=foo_long.lm$coefficients[1], b=foo_long.lm$coefficients[feature+1])
#     }
# }

long_r_sqared_val<-summary(foo_long.lm)$r.squared
long_r_squared_val_adj<-summary(foo_long.lm)$adj.r.squared

##################################################
################### BOX-COX ######################
##################################################

# First I did Box-Cox on Y_origin, to get a Y_boxed. 
y_lat_offset <- y_lat_obj + 90
y_long_offset <- y_long_obj + 90

# y vs xdat
bc_lat<-boxcox(y_lat_offset~as.matrix(xdat), lambda = seq(-5, 5, 1/10))
title("Y Lat. Offset vs. Xdat Obj.")
bc_long<-boxcox(y_long_offset~as.matrix(xdat), lambda = seq(-5, 5, 1/10))
title("Y Long. Offset vs. Xdat Obj.")
lambda_lat<-bc_lat$x[which.max(bc_lat$y)]
lambda_long<-bc_long$x[which.max(bc_long$y)]

y_lat_boxed<-(y_lat_offset^lambda_lat - 1)/lambda_lat
y_long_boxed<-(y_long_offset^lambda_long - 1)/lambda_long

# linear regression, x and boxed
reg_bc_lat<-data.frame(ind=xdat, dep=y_lat_boxed)
reg_bc_lat.lm<-lm(y_lat_boxed~as.matrix(xdat))
reg_bc_long<-data.frame(ind=xdat, dep=y_long_boxed)
reg_bc_long.lm<-lm(y_long_boxed~as.matrix(xdat))

# Then I use the model to predict X into Y_predict. 
predict_bc_lat<-predict(reg_bc_lat.lm,data.frame(xdat))
predict_bc_long<-predict(reg_bc_long.lm,data.frame(xdat))

# reverse Box-Cox tranformation from predicted to unboxed.
un_bc_lat<-(predict_bc_lat*lambda_lat+1)^(1/lambda_lat)-90
un_bc_long<-(predict_bc_long*lambda_long+1)^(1/lambda_long)-90
# R2 = var(unboxed)/var(origin).
bc_lat_r2 <- var(un_bc_lat)/var(y_lat_obj)
bc_long_r2 <- var(un_bc_long)/var(y_long_obj)
