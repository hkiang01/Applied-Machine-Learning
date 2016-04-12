library(glmnet)
library(caret)
library(SDMTools)
library(grDevices)

srange = c(10000, 1000000, 10000000, 68000000000, 100000000000, 1000000000000)


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
mseTrain = rep(0, length(srange))
mseTest = rep(0, length(srange))
for (partitionIt in 1:10){
  bpVector = 1:length(stationTempMeans[,1]) %in% bp
  train = apply(metDataByYear, 1, function(x) x['SID'] %in% bp)
  metDataTrain = metData[train, ]
  
  spacesTrain = dist(metDataTrain[, c(2,3)], method = 'euclidean' ,diag= FALSE,upper= FALSE)
  spaces = dist(metData[, c(2,3)], method = 'euclidean' ,diag= FALSE,upper= FALSE)
  mspTrain <- as.matrix(spacesTrain)
  msp <- as.matrix(spaces)
  msp <- msp[,train]
  for (rangeIt in 1:length(srange)){
    
    
    wmat = exp(-mspTrain^2/(2*srange[rangeIt]^2))
    
    frameData = data.frame(temp = metDataTrain[,1], x = wmat)
    metSmoothCVlm <- lm(temp ~ ., data = frameData)
    
    
    wmat <- exp(-msp^2/(2*srange[rangeIt]^2))
    frameData = data.frame(x = wmat)
    predTempCV <- predict(metSmoothCVlm, newdata = frameData)
    
    # betahatols = coef(metSmoothCVlm)
    # betahatols[is.na(betahatols)] = 0
    # yhatols = cbind(rep(1, nrow(wmat)), as.matrix(wmat)) %*% betahatols
    
    predTempCVwSID = cbind(metDataByYear['SID'], predTempCV)
    predTempAvgCV = aggregate(predTempCVwSID, by=list(predTempCVwSID$SID), FUN=mean, na.rm=TRUE)
    
    
    mseTrain[rangeIt] = mseTrain[rangeIt] + sum((predTempAvgCV[bpVector,'predTempCV'] - stationTempMeans[bpVector,'Tmin_deg_C'])^2)/length(predTempAvgCV[bpVector,'predTempCV'])
    mseTest[rangeIt] = mseTest[rangeIt] + sum((predTempAvgCV[!bpVector,'predTempCV'] - stationTempMeans[!bpVector,'Tmin_deg_C'])^2)/length(predTempAvgCV[!bpVector,'predTempCV'])
  }
}


mseTrainR = mseTrain / partitionIt
mseTestR = mseTest / partitionIt

print(mseTrainR)
print(mseTestR)

minEast = min(locData['East_UTM'])
maxEast = max(locData['East_UTM'])
minNorth = min(locData['North_UTM'])
maxNorth = max(locData['North_UTM'])
eastSeq = seq(minEast ,  maxEast ,length=100)
northSeq = seq(minNorth, maxNorth, length = 100)
points <- matrix(0, 100*100, 2)
for (i in 0:99){
  for (j in 1:100){
    points[i*100 + j, ] = c(eastSeq[i+1], northSeq[j])
  }
}

bp = 1:531
bpVector = rep(TRUE, 531)
bestScale = 68000000000

spaces = dist(metData[, c(2,3)], method = 'euclidean' ,diag= FALSE,upper= FALSE)
msp <- as.matrix(spaces)

wmat = exp(-msp^2/(2*bestScale))

frameData = data.frame(temp = metData[,1], x = wmat)
model <- lm(temp ~ ., data = frameData)


east = matrix(points[,1], nrow(points), length(bp))
north = matrix(points[,2], nrow(points), length(bp))

eastbp = t(matrix(metData[bpVector, 2], length(bp), nrow(points)))
northbp = t(matrix(metData[bpVector, 3], length(bp), nrow(points)))

pointSpaces = sqrt((east - eastbp)^2 + (north - northbp)^2)

wmat <- exp(-pointSpaces^2/(2*bestScale))
frameData = data.frame(x = wmat)
tempPrediction <- predict(model, newdata = frameData)
tempMatrix = t(matrix(tempPrediction, 100, 100))
image(tempMatrix, col=rainbow(25), xlab="east", ylab="north")
title("Mean Min Temperature (C)")
pnts = cbind(c(.85,.9,.9,0.85), c(0.4, 0.4, 0.1, 0.1))
legend.gradient(pnts, col = rainbow(25), limits = c(min(tempMatrix),max(tempMatrix)))


