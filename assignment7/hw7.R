library(glmnet)
library(caret)

srange = c(10000, 20000, 50000, 75000, 100000, 150000, 200000, 300000, 500000000)

locDataRaw = read.table('Locations.txt', header = TRUE)
tempDataRaw = read.table('Oregon_Met_Data.txt', header = TRUE)

locData = locDataRaw[c('SID', 'East_UTM', 'North_UTM')]
tempDataUnfiltered = tempDataRaw[c('SID', 'Year', 'Tmin_deg_C')]

meanEast = mean(locData[,2])
sdEast = sd(locData[,2])
meanNorth = mean(locData[,3])
sdNorth = sd(locData[,3])

# locData[,2] = (locData[,2] - meanEast)/sdEast
# locData[,3] = (locData[,3] - meanNorth)/sdNorth

tempData = tempDataUnfiltered[tempDataUnfiltered[,3] < 9999,]

avgTemp = aggregate(tempData, by=list(tempData$SID,tempData$Year), FUN=mean, na.rm=TRUE)

metDataByYear = merge(avgTemp, locData, by = 'SID')

metData = metDataByYear[,-c(1,2,3,4)]

stationTempMeans = aggregate(metDataByYear[,c('SID', 'Tmin_deg_C')], by= list(metDataByYear$SID), FUN=mean, na.rm=TRUE)[,c(2,3)]

bp = createDataPartition(stationTempMeans[,1], 1, 0.8, list = FALSE)
mseTrain = rep(-1, length(srange))
mseTest = rep(-1, length(srange))
for (rangeIt in 1:length(srange)){
  print(rangeIt)
  mseTrainVec = rep(-1, 1)
  mseTestVec = rep(-1, 1)
  for (partitionIt in 1:1){
    bpVector = 1:length(stationTempMeans[,1]) %in% bp
    train = apply(metDataByYear, 1, function(x) x['SID'] %in% bp)
    metDataTrain = metData[train, ]
    
    spacesTrain = dist(metDataTrain[, c(2,3)], method = 'euclidean' ,diag= FALSE,upper= FALSE)
    spaces = dist(metData[, c(2,3)], method = 'euclidean' ,diag= FALSE,upper= FALSE)
    mspTrain <- as.matrix(spacesTrain)
    msp <- as.matrix(spaces)
    msp <- msp[,train]
    
    wmat = exp(-mspTrain^2/(2*srange[rangeIt]^2))
    
    frameData = data.frame(temp = metDataTrain[,1], x = wmat)
    metSmoothCVlm <- lm(temp ~ ., data = frameData)
    
    
    wmat <- exp(-msp^2/(2*srange[rangeIt]^2))
    frameData = data.frame(temp = metData[,1], x = wmat)
    predTempCV <- predict(metSmoothCVlm, newdata = frameData)
    
    # betahatols = coef(metSmoothCVlm)
    # betahatols[is.na(betahatols)] = 0
    # yhatols = cbind(rep(1, nrow(wmat)), as.matrix(wmat)) %*% betahatols
    
    predTempCVwSID = cbind(metDataByYear['SID'], predTempCV)
    predTempAvgCV = aggregate(predTempCVwSID, by=list(predTempCVwSID$SID), FUN=mean, na.rm=TRUE)
    
    
    mseTrainVec[partitionIt] = sum((predTempAvgCV[bpVector,'predTempCV'] - stationTempMeans[bpVector,'Tmin_deg_C'])^2)/length(predTempAvgCV[bpVector,'predTempCV'])
    mseTestVec[partitionIt] = sum((predTempAvgCV[!bpVector,'predTempCV'] - stationTempMeans[!bpVector,'Tmin_deg_C'])^2)/length(predTempAvgCV[!bpVector,'predTempCV'])
  }
  mseTrain[rangeIt] = mean(mseTrainVec)
  mseTest[rangeIt] = mean(mseTestVec)
}

print(mseTrain)
print(mseTest)

# minEast = min(locData['East_UTM'])
# maxEast = max(locData['East_UTM'])
# minNorth = min(locData['North_UTM'])
# maxNorth = max(locData['North_UTM'])
# eastSeq = seq(minEast ,  maxEast ,length=100)
# northSeq = seq(minNorth, maxNorth, length = 100)
# points <- matrix(0, 100*100, 2)
# for (i in 1:100){
#   for (j in 1:100){
#     points[i*100 + j, ] = c(eastSeq[i], northSeq[j])
#   }
# }
# 
# bp = 1:531
# bpVector = rep(TRUE, 531)
# 
# spaces = dist(metData[, c(2,3)], method = 'euclidean' ,diag= FALSE,upper= FALSE)
# msp <- as.matrix(spaces)
# 
# wmat = exp(-msp^2/(2*srange[4]^2))
# 
# frameData = data.frame(temp = metData[,1], x = wmat)
# model <- lm(temp ~ ., data = frameData)
# 
# 
# east = matrix(points[,1], nrow(points), length(bp))
# north = matrix(points[,2], nrow(points), length(bp))
# 
# eastbp = t(matrix(metData[bpVector, 2], length(bp), nrow(points)))
# northbp = t(matrix(metData[bpVector, 3], length(bp), nrow(points)))
# 
# pointSpaces = sqrt((east - eastbp)^2 + (north - northbp)^2)
# 
# wmat <- exp(-pointSpaces^2/(2*srange[4]^2))
# frameData = data.frame(x = wmat)
# tempPrediction <- predict(model, newdata = frameData)
# tempMatrix = matrix(tempPrediction, 100, 100)
