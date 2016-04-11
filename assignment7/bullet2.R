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

setwd('/Users/harry/projects/aml/assignment7/')

srange = c(10000, 20000, 50000, 75000, 100000, 150000, 200000, 300000, 500000000)

locDataRaw = read.table('Locations.txt', header = TRUE)
tempDataRaw = read.table('Oregon_Met_Data.txt', header = TRUE)

locData = locDataRaw[c('SID', 'East_UTM', 'North_UTM')]
tempDataUnfiltered = tempDataRaw[c('SID', 'Year', 'Tmin_deg_C')]

# meanEast = mean(locData[,2])
# sdEast = sd(locData[,2])
# meanNorth = mean(locData[,3])
# sdNorth = sd(locData[,3])

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

#obtain the distance matrix
xmat = as.matrix(metDataTrain)
spaces = dist(xmat[,c(2,3)], method = "euclidean", diag = FALSE, upper = FALSE)
msp = as.matrix(spaces)

#kernel function
wmat = exp(-msp/(2*srange[i]^2))

#generate Gramm matrix for each scale candidate
mseTrain = rep(-1, length(srange)) #used to test scale candidates
mseTest = rep(-1, length(srange)) #used to test scale candidates
for(i in 1:length(srange)) {
  grammMatrix = exp(-msp/2*srange[i]^2)
  wmat = cbind(wmat, grammMatrix)
}

#the training
wmod = cv.glmnet(wmat, metDataTrain[,1], alpha = 1) #lasso

#image bounds
xmin = min(xmat['East_UTM'])
xmax = max(xmat['East_UTM'])
ymin = min(xmat['North_UTM'])
ymax = max(xmat['North_UTM'])
xvec = seq(xmin, xmax, length=100)
yvec = seq(ymin, ymax, length=100)

#plots
points<-matrix(0,nrow=100*100,ncol=2)
for (i in 0:99){
  for (j in 1:100){
    points[i*100 + j, ] = c(xvec[i+1], yvec[j])
  }
}

#define outer product (cross product) function argument
diff_ij = function(i,j) sqrt(rowSums((points[i,] - xmat[j,])^2))
distsampletOpts = outer(seq_len(10000), seq_len(dim(xmat)[1]), diff_ij)
