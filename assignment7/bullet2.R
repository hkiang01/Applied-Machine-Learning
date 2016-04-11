#Regularize this kernel method (section 9.1.1; worked example 9.1; associated code) using the lasso,
#and predict the average annual temperature at each point on a 100x100 grid spanning the weather stations.
#You should choose the regularization constant using cross validation
#(cv.glmnet will do the work for you; read the manual!).
#You should use each data point as a base point, and you use a range of at least six scales.
#Plot your prediction as an image.
#Compare to the Kriging result that you can find in figure 4 here .
#How many predictors does your model use? How does prediction error change with the number of predictors?

library('glmnet') #glmnet
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

#average temp across all years by SID (true values)
stationTempMeans = aggregate(metDataByYear[,c('SID', 'Tmin_deg_C')], by= list(metDataByYear$SID), FUN=mean, na.rm=TRUE)[,c(2,3)]

