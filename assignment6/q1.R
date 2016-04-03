#library('stats') #lm
library('glmnet') #glmnet
#library('pls') #elastic

#You should ignore outliers.
#You should regard latitude and longitude as entirely independent.

#last 2 cols are lat and long

setwd('/Users/harry/projects/aml/assignment6/')
rawdat<-read.csv('default_plus_chromatic_features_1059_tracks.txt', header=FALSE)
xdat<-rawdat[,-c(ncol(rawdat),ncol(rawdat)-1)]
ydat<-rawdat[,c(ncol(rawdat)-1,ncol(rawdat))]
y_lat<-ydat[,c(1)]
y_long<-ydat[,c(2)]

n = nrow(xdat)
split = 0.7
train = sample(1:n, round(n * split))
xdat_tr = xdat[train, ]
xdat_test = xdat[-train, ]
y_lat_tr = y_lat[train]
y_lat_test = y_lat[-train]
y_long_tr = y_long[train]
y_long_test = y_long[-train]

# Train regression models
# Find best regularization constant for each model via cross-validation (default = 10 folds)

#latitude
ols_lat = lm(y_lat_tr ~ as.matrix(xdat_tr))
lasso_lat = cv.glmnet(as.matrix(xdat_tr), y_lat_tr, alpha = 1)
ridge_lat = cv.glmnet(as.matrix(xdat_tr), y_lat_tr, alpha = 0)
elasticnet_lat = cv.glmnet(as.matrix(xdat_tr), y_lat_tr, alpha = 0.5)

bestlambdalasso_lat = lasso_lat$lambda.min
bestlambdaridge_lat = ridge_lat$lambda.min
bestlambdanet_lat = elasticnet_lat$lambda.min

#longitude
ols_long = lm(y_long_tr ~ as.matrix(xdat_tr))
lasso_long = cv.glmnet(as.matrix(xdat_tr), y_long_tr, alpha = 1)
ridge_long = cv.glmnet(as.matrix(xdat_tr), y_long_tr, alpha = 0)
elasticnet_long = cv.glmnet(as.matrix(xdat_tr), y_long_tr, alpha = 0.5)

bestlambdalasso_long = lasso_long$lambda.min
bestlambdaridge_long = ridge_long$lambda.min
bestlambdanet_long = elasticnet_long$lambda.min

# Test regression models after finding best regularization constant for each

#latitude
betahatols_lat = coef(ols_lat)
yhatols_lat = cbind(rep(1, n - length(train)), as.matrix(xdat_test)) %*% betahatols_lat;
yhatlasso_lat = predict(lasso_lat, as.matrix(xdat_test), s = bestlambdalasso_lat)
yhatridge_lat = predict(ridge_lat, as.matrix(xdat_test), s = bestlambdaridge_lat)
yhatelastic_lat = predict(elasticnet_lat, as.matrix(xdat_test), s = bestlambdanet_lat)

#longitude
betahatols_long = coef(ols_long)
yhatols_long = cbind(rep(1, n - length(train)), as.matrix(xdat_test)) %*% betahatols_long;
yhatlasso_long = predict(lasso_long, as.matrix(xdat_test), s = bestlambdalasso_long)
yhatridge_long = predict(ridge_long, as.matrix(xdat_test), s = bestlambdaridge_long)
yhatelastic_long = predict(elasticnet_long, as.matrix(xdat_test), s = bestlambdanet_long)

# Compare MSE on test data

#latitude
ols_mse_lat = sum((y_lat_test - yhatols_lat)^2) / nrow(xdat_test)
lasso_mse_lat = sum((y_lat_test - yhatlasso_lat)^2) / nrow(xdat_test)
ridge_mse_lat = sum((y_lat_test - yhatridge_lat)^2) / nrow(xdat_test)
elastic_mse_lat = sum((y_lat_test - yhatelastic_lat)^2) / nrow(xdat_test)

#longitude
ols_mse_long = sum((y_long_test - yhatols_long)^2) / nrow(xdat_test)
lasso_mse_long = sum((y_long_test - yhatlasso_long)^2) / nrow(xdat_test)
ridge_mse_long = sum((y_long_test - yhatridge_long)^2) / nrow(xdat_test)
elastic_mse_long = sum((y_long_test - yhatelastic_long)^2) / nrow(xdat_test)
