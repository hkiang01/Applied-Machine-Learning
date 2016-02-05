wdat<-read.csv('adult.data', header=FALSE)
library(klaR)
library(caret)
bigx<-wdat[c(1,3,5,11,12,13)] # continuous features
bigy<-wdat[,15] # labels
tr_indices<-createDataPartition(y=bigy, p=.8, list=FALSE)
trdat<-bigx[tr_indices,]
trlab<-bigy[tr_indices]
otherdat<-bigx[-tr_indices,]
otherlab<-bigy[-tr_indices]
test_indices<-createDataPartition(y=otherlab, p=.5, list=FALSE)
testdat<-otherdat[test_indices,]
testlab<-otherlab[test_indices]
valdat<-otherdat[-test_indices,]
vallab<-otherlab[-test_indices]
