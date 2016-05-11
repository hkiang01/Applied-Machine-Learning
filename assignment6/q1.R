#library('stats') #lm
library('glmnet') #glmnet
#library('pls') #elastic

#You should ignore outliers.
#You should regard latitude and longitude as entirely independent.

#last 2 cols are lat and long

setwd('~/projects/Applied-Machine-Learning/assignment6/')
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

lasso_alphas = array(c(.8,.9,1))
ridge_alphas = array(c(0,.1,.2))
net_alphas = array(c(.4,.5,.6))

lasso_mse_arr_lat = c()
ridge_mse_arr_lat = c()
net_mse_arr_lat = c()

lasso_mse_arr_long = c()
ridge_mse_arr_long = c()
net_mse_arr_long = c()

bestlambdalasso_arr_lat = c()
bestlambdaridge_arr_lat = c()
bestlambdanet_arr_lat = c()

bestlambdalasso_arr_long = c()
bestlambdaridge_arr_long = c()
bestlambdanet_arr_long = c()

for(i in 1:length(lasso_alphas)) {
  #latitude
  ols_lat = lm(y_lat_tr ~ as.matrix(xdat_tr))
  lasso_lat = cv.glmnet(as.matrix(xdat_tr), y_lat_tr, alpha = lasso_alphas[i])
  ridge_lat = cv.glmnet(as.matrix(xdat_tr), y_lat_tr, alpha = ridge_alphas[i])
  elasticnet_lat = cv.glmnet(as.matrix(xdat_tr), y_lat_tr, alpha = net_alphas[i])
  
  bestlambdalasso_lat = lasso_lat$lambda.min
  bestlambdaridge_lat = ridge_lat$lambda.min
  bestlambdanet_lat = elasticnet_lat$lambda.min
  
  bestlambdalasso_arr_lat = c(bestlambdalasso_arr_lat, bestlambdalasso_lat)
  bestlambdaridge_arr_lat = c(bestlambdaridge_arr_lat, bestlambdaridge_lat)
  bestlambdanet_arr_lat = c(bestlambdanet_arr_lat, bestlambdanet_lat)
  
  #longitude
  ols_long = lm(y_long_tr ~ as.matrix(xdat_tr))
  lasso_long = cv.glmnet(as.matrix(xdat_tr), y_long_tr, alpha = lasso_alphas[i])
  ridge_long = cv.glmnet(as.matrix(xdat_tr), y_long_tr, alpha = ridge_alphas[i])
  elasticnet_long = cv.glmnet(as.matrix(xdat_tr), y_long_tr, alpha = net_alphas[i])
  
  bestlambdalasso_long = lasso_long$lambda.min
  bestlambdaridge_long = ridge_long$lambda.min
  bestlambdanet_long = elasticnet_long$lambda.min
  
  bestlambdalasso_arr_long = c(bestlambdalasso_arr_long, bestlambdalasso_long)
  bestlambdaridge_arr_long = c(bestlambdaridge_arr_long, bestlambdaridge_long)
  bestlambdanet_arr_long = c(bestlambdanet_arr_long, bestlambdanet_long)
  
  # Test regression models after finding best regularization constant for each
  
  #latitude
  betahatols_lat = coef(ols_lat)
  betahatols_lat[is.na(betahatols_lat)]<-0 # replace NA's with 0
  yhatols_lat = cbind(rep(1, n - length(train)), as.matrix(xdat_test)) %*% betahatols_lat;
  yhatlasso_lat = predict(lasso_lat, as.matrix(xdat_test), s = bestlambdalasso_lat)
  yhatridge_lat = predict(ridge_lat, as.matrix(xdat_test), s = bestlambdaridge_lat)
  yhatelastic_lat = predict(elasticnet_lat, as.matrix(xdat_test), s = bestlambdanet_lat)
  
  #longitude
  betahatols_long = coef(ols_long)
  betahatols_long[is.na(betahatols_long)]<-0 # # replace NA's with 0
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
  
  # Store the results for each alpha
  lasso_mse_arr_lat = c(lasso_mse_arr_lat, lasso_mse_lat)
  ridge_mse_arr_lat = c(ridge_mse_arr_lat, ridge_mse_lat)
  net_mse_arr_lat = c(net_mse_arr_lat, elastic_mse_lat)
  
  lasso_mse_arr_long = c(lasso_mse_arr_long, lasso_mse_long)
  ridge_mse_arr_long = c(ridge_mse_arr_long, ridge_mse_long)
  net_mse_arr_long = c(net_mse_arr_long, elastic_mse_long)
  
  # Generate plots for each regularization scheme (lasso, ridge, elastic net)
  
  #latitude
  plot(lasso_lat)
  title(paste("Lasso Regression (latitude) alpha =",lasso_alphas[i]), line=3)
  plot(ridge_lat)
  title(paste("Ridge Regression (latitude) alpha =",ridge_alphas[i]), line=3)
  plot(elasticnet_lat)
  title(paste("Elastic Net Regression (latitude) alpha =",net_alphas[i]), line=3)
  
  
  #longitude
  plot(lasso_long)
  title(paste("Lasso Regression (longitude) alpha =",lasso_alphas[i]), line=3)
  plot(ridge_long)
  title(paste("Ridge Regression (longitude) alpha =",ridge_alphas[i]), line=3)
  plot(elasticnet_long)
  title(paste("Elastic Net Regression (longitude) alpha =",net_alphas[i]), line=3)
  
  
}

