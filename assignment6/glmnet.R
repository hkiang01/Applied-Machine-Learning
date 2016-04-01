library('caret') #createDataPartition
library('stats') #lm
library('glmnet') #glmnet
library('pls') #elastic

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
xdat_obj<-as.matrix(xdat)
y_lat_obj<-as.matrix(y_lat)
y_long_obj<-as.matrix(y_long)


# A regression regularized by L2 (equivalently, a ridge regression).
# You should estimate the regularization coefficient that produces the minimum error.
# Is the regularized regression better than the unregularized regression?

#latitude
l2_dmodel_lat<-cv.glmnet(xdat_obj, y_lat_obj, alpha=0)
plot(l2_dmodel_lat)
l2_min_lambda_lat<-l2_dmodel_lat$lambda.min
l2_lat_cross_val_err<-l2_dmodel_lat$cvm

#longitude
l2_dmodel_long<-cv.glmnet(xdat_obj, y_long_obj, alpha=0)
plot(l2_dmodel_long)
l2_min_lambda_long<-l2_dmodel_long$lambda.min
l2_long_cross_val_err<-l2_dmodel_long$cvm

# L1
#latitude
l1_dmodel_lat<-cv.glmnet(xdat_obj, y_lat_obj, alpha=1)
plot(l1_dmodel_lat)
l1_min_lambda_lat<-l1_dmodel_lat$lambda.min
l1_lat_cross_val_err<-l1_dmodel_lat$cvm

#longitude
l1_dmodel_long<-cv.glmnet(xdat_obj, y_long_obj, alpha=1)
plot(l1_dmodel_long)
l1_min_lambda_long<-l1_dmodel_long$lambda.min
l1_long_cross_val_err<-l1_dmodel_long$cvm


#elastic

#latitude
foldid=sample(1:10, size=length(y_lat_obj), replace=TRUE)
cv1=cv.glmnet(xdat_obj, y_lat_obj, foldid=foldid, alpha=1)
cv.5=cv.glmnet(xdat_obj, y_lat_obj, foldid=foldid, alpha=.5)
cv0=cv.glmnet(xdat_obj, y_lat_obj, foldid=foldid, alpha=0)
par(mfrow=c(2,2))
plot(cv1)
legend("top", legend="alpha=1")
plot(cv.5)
legend("top", legend="alpha=.5")
plot(cv0)
legend("top", legend="alpha=0")
plot(log(cv1$lambda),cv1$cvm,pch=19,col="red",
     xlab="log(Lambda)",ylab=cv1$name)
points(log(cv.5$lambda),cv.5$cvm,pch=19,col="grey")
points(log(cv0$lambda),cv0$cvm,pch=19,col="blue")
legend("topleft",
       legend=c("alpha=1","alpha=.5","alpha=0"),
       pch=19,col=c("red","grey","blue"))