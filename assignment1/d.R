setwd('/Users/harry/projects/aml/assignment1/')
rm(list=ls()) # housekeeping
wdat<-read.csv('data.txt', header=FALSE)
library(klaR)
library(caret)
bigx<-wdat[,-c(9)] #drop col 9
bigy<-as.factor(wdat[,9]) #coerce col 9 and store as factor (class label)
wtd<-createDataPartition(y=bigy, p=.8, list=FALSE) #randomly partitions with probability .8
#svmlight 
svm<-svmlight(bigx[wtd,], bigy[wtd], pathsvm='/Users/harry/projects/aml/assignment1/')
#run on testing data (remaining 20%)
labels<-predict(svm, bigx[-wtd,]) #run svm model object on test data
foo<-labels$class
# evaluate performance on test data
sum(foo==bigy[-wtd])/(sum(foo==bigy[-wtd])+sum(!(foo==bigy[-wtd])))
