setwd('/Users/harry/projects/aml/assignment7/')


source("image.scale.R")

#DATA AND PLOTTING OVERHEAD

library('glmnet') #glmnet
library(caret) #createDataPartition

#heat map and plotting libraries
if (!require("gplots")) {
  install.packages("gplots", dependencies = TRUE)
  library(gplots)
}
if (!require("RColorBrewer")) {
  install.packages("RColorBrewer", dependencies = TRUE)
  library(RColorBrewer)
}

#setwd('/Users/annlinsheih/Dev/aml/assignment7/')

# list of scale candidates
#srange = c(10000, 20000, 50000, 75000, 100000, 150000, 200000, 300000, 500000000)
srange = seq(50000, 100000, 2500)

#choice of alpha values for elastic net
net_alphas = array(c(.4,.5,.6))

locDataRaw = read.table('Locations.txt', header = TRUE)
tempDataRaw = read.table('Oregon_Met_Data.txt', header = TRUE)

locData = locDataRaw[c('SID', 'East_UTM', 'North_UTM')]
tempDataUnfiltered = tempDataRaw[c('SID', 'Year', 'Tmin_deg_C')]
# 
# meanEast = mean(locData[,2])
# sdEast = sd(locData[,2])
# meanNorth = mean(locData[,3])
# sdNorth = sd(locData[,3])
# 
# locData[,2] = (locData[,2] - meanEast)/sdEast
# locData[,3] = (locData[,3] - meanNorth)/sdNorth

#filter out bad points
tempData = tempDataUnfiltered[tempDataUnfiltered[,3] < 9999,]

#mean min temp by station ID and year
avgTemp = aggregate(tempData, by=list(tempData$SID,tempData$Year), FUN=mean, na.rm=TRUE)

#average temp by SID and year (true values)
metDataByYear = merge(avgTemp, locData, by = 'SID')
metDataByYear = metDataByYear[,-c(2,3)] #gets rid of Group1 and Group2 columns created by merge
metData = metDataByYear[,c(3,4,5)] #min temp, east_utm, north_utm

#average temp across all years by SID (true values)
stationTempMeans = aggregate(metDataByYear[,c('SID', 'Tmin_deg_C')], by= list(metDataByYear$SID), FUN=mean, na.rm=TRUE)[,c(2,3)]

#data split
bp = createDataPartition(stationTempMeans[,1], 1, 0.8, list = FALSE)
bpVector = 1:length(stationTempMeans[,1]) %in% bp
train = apply(metDataByYear, 1, function(x) x['SID'] %in% bp)
metDataTrain = metData[train, ]
metDataTest = metData[-train,]

#obtain the distance matrices
xmat = as.matrix(metDataTrain)
xspaces = dist(xmat[,c("East_UTM", "North_UTM")], method = "euclidean", diag = FALSE, upper = FALSE)
xmsp = as.matrix(xspaces)

test_mat = as.matrix(metDataTest)
test_spaces = dist(test_mat[,c("East_UTM", "North_UTM")], method = "euclidean", diag = FALSE, upper = FALSE)
test_msp = as.matrix(test_spaces)

all_mat = as.matrix(metData)
all_spaces = dist(all_mat[,c("East_UTM", "North_UTM")], method = "euclidean", diag = FALSE, upper = FALSE)
all_msp = as.matrix(all_spaces)

#image bounds
xmin = min(locData[,c("East_UTM")])
xmax = max(locData[,c("East_UTM")])
ymin = min(locData[,c("North_UTM")])
ymax = max(locData[,c("North_UTM")])
xvec = seq(xmin, xmax, length=100)
yvec = seq(ymin, ymax, length=100)

#plot bucketing of 100x100 region
points<-matrix(0,nrow=100*100,ncol=2)
points <- matrix(0, 100*100, 2)
for (i in 0:99){
  for (j in 1:100){
    points[i*100 + j, ] = c(xvec[i+1], yvec[j])
  }
}

east = matrix(points[,1], nrow(points), nrow(all_mat))
north = matrix(points[,2], nrow(points), nrow(all_mat))

#obtain the distance matrix of the base points relative to plot bucketted grid
eastbp = t(matrix(all_mat[,c("East_UTM")], nrow(all_mat), nrow(points)))
northbp = t(matrix(all_mat[,c("North_UTM")], nrow(all_mat), nrow(points)))
pointSpaces = sqrt((east - eastbp)^2 + (north - northbp)^2)

#END OF DATA AND PLOTTING OVERHEAD

#bullet2
#Regularize this kernel method (section 9.1.1; worked example 9.1; associated code) using the lasso,
#and predict the average annual temperature at each point on a 100x100 grid spanning the weather stations.
#You should choose the regularization constant using cross validation
#(cv.glmnet will do the work for you; read the manual!).
#You should use each data point as a base point, and you use a range of at least six scales.
#Plot your prediction as an image.
#Compare to the Kriging result that you can find in figure 4 here .
#How many predictors does your model use? How does prediction error change with the number of predictors?

#generate Gramm matrix for each scale candidate
mseTrain = rep(-1, length(srange)) #used to test scale candidates
mseTest = rep(-1, length(srange)) #used to test scale candidates

#the ground truth, used to pick from scale candidates
train_answers = as.matrix(xmat[,c(1)])

for(i in 1:length(srange)) {
  
  #kernel function
  xwmat = exp(-xmsp^2/(2*srange[i]^2))
  
  #the training
  wmod = cv.glmnet(xwmat, metDataTrain[,1], alpha = 1) #lasso
  
  #the predicting
  predTemp = predict(wmod, xwmat, s=wmod$lambda.min )
  
  #error rate
  mseTrain[i] = sum((predTemp - train_answers)^2) / nrow(train_answers)
  
  #ALL THE GRAPHS (FOR EACH SCALE)
  
  #kernel function for the base points relative to plot bucketted grid
  wmat_pointSpaces = exp(-pointSpaces^2/(2*srange[i]^2))
  
  #kernel function for distance matrix from all points
  wmat = exp(-all_msp^2/(2*srange[i]^2))
  
  #obtain best model for all points using best scale
  wmod_best_lasso = cv.glmnet(wmat, all_mat[,1], alpha = 1)
  bestLambda_lasso = wmod_best_lasso$lambda.min
  
  #apply above distance matrix in the prediction using best model
  tempPrediction_lasso = predict(wmod_best_lasso, wmat_pointSpaces, s=wmod_best_lasso$lambda.min )
  tempMatrix_lasso = t(matrix(tempPrediction_lasso, 100, 100))
  
  #generate heatmap
  layout(matrix(c(1,2), ncol=2), widths=c(4,1))
  par(mar=c(4,4,4,1))
  image(tempMatrix_lasso, xaxt='n', yaxt='n', ann=FALSE)
  axis(1, at=seq(0,1,0.2), labels=as.matrix(seq(as.integer(xmin/1000), as.integer(xmax/1000), length=6)))
  axis(2, at=seq(0,1,0.2), labels=as.matrix(seq(as.integer(ymin/1000), as.integer(ymax/1000), length=6)))
  title(main=paste("Annual Mean of Minimum Temperature\nUsing Lasso w/ scale =",srange[i]), xlab="East_UTM  in 1000's", ylab="North_UTM  in 1000's")
  par(mar=c(4,1,4,3))
  image.scale(tempMatrix_lasso, axis.pos=4)
  par(mfrow=c(1,1)) #cleanup
  
  
}

#choose best scale corresponding to minimum error
bestScale = srange[which.min(mseTrain)]

#kernel function for the base points relative to plot bucketted grid
wmat_pointSpaces = exp(-pointSpaces^2/(2*bestScale^2))

#kernel function for distance matrix from all points
wmat = exp(-all_msp^2/(2*bestScale^2))

#obtain bset model for all points using best scale
wmod_best_lasso = cv.glmnet(wmat, all_mat[,1], alpha = 1)
bestLambda_lasso = wmod_best_lasso$lambda.min

#apply above distance matrix in the prediction using best model
tempPrediction_lasso = predict(wmod_best_lasso, wmat_pointSpaces, s=wmod_best_lasso$lambda.min )
tempMatrix_lasso = t(matrix(tempPrediction_lasso, 100, 100))

#generate heatmap
layout(matrix(c(1,2), ncol=2), widths=c(4,1))
par(mar=c(4,4,4,1))
image(tempMatrix_lasso, xaxt='n', yaxt='n', ann=FALSE)
axis(1, at=seq(0,1,0.2), labels=as.matrix(seq(as.integer(xmin/1000), as.integer(xmax/1000), length=6)))
axis(2, at=seq(0,1,0.2), labels=as.matrix(seq(as.integer(ymin/1000), as.integer(ymax/1000), length=6)))
title(main=paste("Annual Mean of Minimum Temperature\nUsing Lasso (Best Result) w/ scale =",bestScale), xlab="East_UTM  in 1000's", ylab="North_UTM  in 1000's")
par(mar=c(4,1,4,3))
image.scale(tempMatrix_lasso, axis.pos=4)
par(mfrow=c(1,1)) #cleanup


#predictors for best lasso model
#predictors for best elastic model
par(mar=c(5,5,5,1))
plot(wmod_best_lasso, main=paste("MSE v. Lambda (Lasso), h=", bestScale),
     xlab="Regularization Constant", ylab="MSE")

# Bullet3
# Now investigate the effect of different choices of
# elastic net constant (alpha)

#used to test scale and alpha candidates for elastic net
mseTrainElastic = array()
scaleCandidatesArr = array()
alphaCandidatesArr = array()

#train across scales AND alphas
#train across scales AND alphas
#train across scales AND alphas
for(i in 1:length(srange)){
  
  #kernel function for given scale
  xwmat = exp(-xmsp^2/(2*srange[i]^2))
  scaleCandidatesArr[i] = srange[i]
  
  for(j in 1:length(net_alphas)) {
    
    #the training
    wmod = cv.glmnet(xwmat, metDataTrain[,1], alpha = net_alphas[j] ) #elastic net
    
    #the predicting
    predTemp = predict(wmod, xwmat, s=wmod$lambda.min )
    mseTrainElastic[i*length(net_alphas) + j] = sum((predTemp - train_answers)^2) / nrow(train_answers)
    
    alphaCandidatesArr[i*length(net_alphas) + j] = net_alphas[j]
    
  }
}
#choose best alpha corresponding to minimal error
bestScale_elastic = scaleCandidatesArr[which.min(mseTrainElastic)/length(net_alphas)]
bestAlpha = alphaCandidatesArr[which.min(mseTrainElastic)]

#apply kernel function to best scale
wmat_elastic = exp(-all_msp^2/(2*bestScale_elastic^2))

#obtain bset model for all points using best scale and best alpha
wmod_best_elastic = cv.glmnet(wmat_elastic, metData[,1], alpha = bestAlpha) #elastic
bestLambda_elastic = wmod_best_elastic$lambda.min

#apply above distance matrix in the prediction using best model
tempPrediction_elastic = predict(wmod_best_elastic, wmat_pointSpaces, s=wmod_best_elastic$lambda.min )
tempMatrix_elastic = t(matrix(tempPrediction_elastic, 100, 100))

#generate heatmap
layout(matrix(c(1,2), ncol=2), widths=c(4,1))
par(mar=c(4,4,4,1))
image(tempMatrix_elastic, xaxt='n', yaxt='n', ann=FALSE)
axis(1, at=seq(0,1,0.2), labels=as.matrix(seq(as.integer(xmin/1000), as.integer(xmax/1000), length=6)))
axis(2, at=seq(0,1,0.2), labels=as.matrix(seq(as.integer(ymin/1000), as.integer(ymax/1000), length=6)))
title(main=paste("Annual Mean of Minimum Temperature\nUsing Elastic w/ scale=", bestScale_elastic, ", alpha=", bestAlpha), xlab="East_UTM  in 1000's", ylab="North_UTM  in 1000's")
par(mar=c(4,1,4,3))
image.scale(tempMatrix_elastic, axis.pos=4)
par(mfrow=c(1,1)) #cleanup


#predictors for best elastic model
par(mar=c(5,5,5,1))
plot(wmod_best_elastic, main=paste("MSE v. Lambda (Elastic), h=", bestScale_elastic, ", alpha=", net_alphas[i]),
     xlab="Regularization Constant", ylab="MSE")

#ALL THE GRAPHS (FOR EACH ALPHA FOR BEST ELASTIC SCALE)

#apply kernel function to best scale
wmat_elastic = exp(-all_msp^2/(2*bestScale_elastic^2))

for(i in 1:length(net_alphas)){
  #obtain bset model for all points using best scale and best alpha
  wmod_best_elastic = cv.glmnet(wmat_elastic, metData[,1], alpha = net_alphas[i]) #elastic
  bestLambda_elastic = wmod_best_elastic$lambda.min
  
  #apply above distance matrix in the prediction using best model
  tempPrediction_elastic = predict(wmod_best_elastic, wmat_pointSpaces, s=wmod_best_elastic$lambda.min )
  tempMatrix_elastic = t(matrix(tempPrediction_elastic, 100, 100))
  
  #generate heatmap
  layout(matrix(c(1,2), ncol=2), widths=c(4,1))
  par(mar=c(4,4,4,1))
  image(tempMatrix_elastic, xaxt='n', yaxt='n', ann=FALSE)
  axis(1, at=seq(0,1,0.2), labels=as.matrix(seq(as.integer(xmin/1000), as.integer(xmax/1000), length=6)))
  axis(2, at=seq(0,1,0.2), labels=as.matrix(seq(as.integer(ymin/1000), as.integer(ymax/1000), length=6)))
  title(main=paste("Annual Mean of Minimum Temperature\nUsing Elastic w/ scale=", bestScale_elastic, ", alpha=", net_alphas[i]), xlab="East_UTM  in 1000's", ylab="North_UTM  in 1000's")
  par(mar=c(4,1,4,3))
  image.scale(tempMatrix_elastic, axis.pos=4)
  par(mfrow=c(1,1)) #cleanup
  
}