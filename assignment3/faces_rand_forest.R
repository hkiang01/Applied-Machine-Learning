# housekeeping
rm(list=ls())

library(randomForest)
library(caret)


# import data
# http://www.portfolioprobe.com/user-area/documentation/portfolio-probe-cookbook/data-basics/read-a-tab-separated-file-into-r/
wdat<-read.table('pubfig_dev_50000_pairs.txt')
# v1 is label, rest (v2-v147) are features
bigx<-wdat[,-c(1)] #drop col 1
bigy<-as.factor(wdat[,1]) #coerce col 1 and store as factor (class label)

trscore<-array(dim=10)
testscore<-array(dim=10)
for (i in 1:1){
  wtd<-createDataPartition(y=bigy, p=.8, list=FALSE)
  trBigX <- bigx[wtd,]
  trBigY <- bigy[wtd]
  
  tsBigX <- bigx[-wtd,]
  tsBigY <- bigy[-wtd]
  
  model <- randomForest(trBigX, trBigY, ntree = 500)
  trResult <- predict(model, trBigX)
  tsResult <- predict(model, tsBigX)
  
  trAccuracy = sum(trResult == trBigY)/length(trBigY)
  tsAccuracy = sum(tsResult == tsBigY)/length(tsBigY)
}