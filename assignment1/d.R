rm(list=ls()) # housekeeping
wdat<-read.csv('data.txt', header=FALSE)
library(klaR)
library(caret)
bigx<-wdat[,-c(9)] #drop col 9
bigy<-as.factor(wdat[,9]) #coerce col 9 and store as factor (class label)
trscore<-array(dim=10)
tescore<-array(dim=10)
for (wi in 1:10)
{
 wtd<-createDataPartition(y=bigy, p=.8, list=FALSE) #randomly partitions with probability .8
 #svmlight 
 svm<-svmlight(bigx[wtd,], bigy[wtd], pathsvm='/Users/harry/projects/aml/assignment1/')
 
 trlabels<-predict(svm, bigx[wtd,])
 trfoo<-trlabels$class
 trscore[wi]<-sum(trfoo==bigy[wtd])/(sum(trfoo==bigy[wtd])+sum(!(trfoo==bigy[wtd])))
 #run on testing data (remaining 20%)
 labels<-predict(svm, bigx[-wtd,]) #run svm model object on test data
 foo<-labels$class
 # evaulate performance on training data
 # evaluate performance on test data
 tescore[wi]<-sum(foo==bigy[-wtd])/(sum(foo==bigy[-wtd])+sum(!(foo==bigy[-wtd])))
}
trscoremean<-mean(trscore)
tescoremean<-mean(tescore)
