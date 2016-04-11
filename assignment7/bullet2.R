#Regularize this kernel method (section 9.1.1; worked example 9.1; associated code) using the lasso,
#and predict the average annual temperature at each point on a 100x100 grid spanning the weather stations.
#You should choose the regularization constant using cross validation
#(cv.glmnet will do the work for you; read the manual!).
#You should use each data point as a base point, and you use a range of at least six scales.
#Plot your prediction as an image.
#Compare to the Kriging result that you can find in figure 4 here .
#How many predictors does your model use? How does prediction error change with the number of predictors?

library('glmnet') #glmnet
library(caret) #createDataPartition

# setwd('/Users/harry/projects/aml/assignment7/')
setwd('/Users/annlinsheih/Dev/aml/assignment7/')

srange = c(10000, 20000, 50000, 75000, 100000, 150000, 200000, 300000, 500000000)

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

tempData = tempDataUnfiltered[tempDataUnfiltered[,3] < 9999,]

avgTemp = aggregate(tempData, by=list(tempData$SID,tempData$Year), FUN=mean, na.rm=TRUE)

#average temp by SID and year (true values)
metDataByYear = merge(avgTemp, locData, by = 'SID')
metDataByYear = metDataByYear[,-c(2,3)] #gets rid of Group1 and Group2 columns created by merge

metData = metDataByYear[,c(3,4,5)]

#average temp across all years by SID (true values)
stationTempMeans = aggregate(metDataByYear[,c('SID', 'Tmin_deg_C')], by= list(metDataByYear$SID), FUN=mean, na.rm=TRUE)[,c(2,3)]

#data split
bp = createDataPartition(stationTempMeans[,1], 1, 0.8, list = FALSE)
bpVector = 1:length(stationTempMeans[,1]) %in% bp
train = apply(metDataByYear, 1, function(x) x['SID'] %in% bp)
metDataTrain = metData[train, ]
metDataTest = metData[-train,]

#obtain the distance matrix
xmat = as.matrix(metDataTrain)
test_mat = as.matrix(metDataTest)
xspaces = dist(xmat[,c(2,3)], method = "euclidean", diag = FALSE, upper = FALSE)
test_spaces = dist(test_mat[,c(2,3)], method = "euclidean", diag = FALSE, upper = FALSE)
xmsp = as.matrix(xspaces)
test_msp = as.matrix(test_spaces)

test_mat = as.matrix(metDataTest)

all_mat = as.matrix(metData)
all_spaces = dist(all_mat[,c(2,3)], method = "euclidean", diag = FALSE, upper = FALSE)
all_msp = as.matrix(all_spaces)

#generate Gramm matrix for each scale candidate
mseTrain = rep(-1, length(srange)) #used to test scale candidates
mseTest = rep(-1, length(srange)) #used to test scale candidates
# for(i in 1:length(srange)) {
#   grammMatrix = exp(-xmsp/2*srange[i]^2)
#   xwmat = cbind(xwmat, grammMatrix)
# }

train_answers = as.matrix(xmat[,c(1)])

for(i in 1:length(srange)) {
  
#   i = 1
  #kernel function
  xwmat = exp(-xmsp^2/(2*srange[i]^2))
  all_wmat = exp(-all_msp^2/(2*srange[i]^2))
  
  #the training
  wmod = cv.glmnet(xwmat, metDataTrain[,1], alpha = 1) #lasso
  
  #the predicting
  predTemp = predict(wmod, xwmat, s=wmod$lambda.min )
  
  mseTrain[i] = sum((predTemp - train_answers)^2) / nrow(train_answers)
  
  
}


#image bounds
xmin = min(locData[,c(2)])
xmax = max(locData[,c(2)])
ymin = min(locData[,c(3)])
ymax = max(locData[,c(3)])
xvec = seq(xmin, xmax, length=100)
yvec = seq(ymin, ymax, length=100)

#plots
points<-matrix(0,nrow=100*100,ncol=2)
points <- matrix(0, 100*100, 2)
for (i in 0:99){
  for (j in 1:100){
    points[i*100 + j, ] = c(xvec[i+1], yvec[j])
  }
}

bp = 1:nrow(all_mat)
bpVector = rep(TRUE, nrow(all_mat))
bestScale = srange[which.min(mseTrain)]

spaces = dist(metData[, c(2,3)], method = 'euclidean' ,diag= FALSE,upper= FALSE)
msp <- as.matrix(spaces)

wmat = exp(-msp^2/(2*bestScale^2))

wmod_best = cv.glmnet(wmat, metData[,1], alpha = 1) #lasso

east = matrix(points[,1], nrow(points), length(bp))
north = matrix(points[,2], nrow(points), length(bp))

eastbp = t(matrix(metData[bpVector, 2], length(bp), nrow(points)))
northbp = t(matrix(metData[bpVector, 3], length(bp), nrow(points)))

pointSpaces = sqrt((east - eastbp)^2 + (north - northbp)^2)

wmat <- exp(-pointSpaces^2/(2*bestScale^2))
tempPrediction = predict(wmod_best, wmat, s=wmod_best$lambda.min )
tempMatrix = t(matrix(tempPrediction, 100, 100))
image(tempMatrix)

#Bullet3
net_alphas = array(c(.4,.5,.6))

mseTrainElastic = rep(-1, length(net_alphas)) #used to test scale candidate

#   i = 1
#kernel function
xwmat = exp(-xmsp^2/(2*bestScale^2))
all_wmat = exp(-all_msp^2/(2*bestScale^2))


for(i in 1:length(net_alphas)) {

  #the training
  wmod = cv.glmnet(xwmat, metDataTrain[,1], alpha = net_alphas[i] ) #elastic net
  #the predicting
  predTemp = predict(wmod, xwmat, s=wmod$lambda.min )
  mseTrainElastic[i] = sum((predTemp - train_answers)^2) / nrow(train_answers)
  
}

bestAlpha = net_alphas[which.min(mseTrainElastic)]

bp = 1:nrow(all_mat)
bpVector = rep(TRUE, nrow(all_mat))
bestScale = bestScale #srange[which.min(mseTrain)]

spaces = dist(metData[, c(2,3)], method = 'euclidean' ,diag= FALSE,upper= FALSE)
msp <- as.matrix(spaces)

wmat = exp(-msp^2/(2*bestScale^2))

wmod_best = cv.glmnet(wmat, metData[,1], alpha = bestAlpha) #elastic

east = matrix(points[,1], nrow(points), length(bp))
north = matrix(points[,2], nrow(points), length(bp))

eastbp = t(matrix(metData[bpVector, 2], length(bp), nrow(points)))
northbp = t(matrix(metData[bpVector, 3], length(bp), nrow(points)))

pointSpaces = sqrt((east - eastbp)^2 + (north - northbp)^2)

wmat <- exp(-pointSpaces^2/(2*bestScale^2))
tempPrediction = predict(wmod_best, wmat, s=wmod_best$lambda.min )
tempMatrix = t(matrix(tempPrediction, 100, 100))
image(tempMatrix)

