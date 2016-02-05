wdat<-read.csv('adult.data', header=FALSE)
library(klaR)
library(caret)
bigx<-wdat[c(1,3,5,11,12,13)] # continuous features
bigy<-wdat[,15] # labels
bigy2<-matrix() #blank matrix

# for loop to replace <=50K with -1
# and >50K with 1
counter<-0
for(i in bigy) {
  #if(identical(j, i)) {
  if(identical(" <=50K", i)) {
    bigy2[counter]<- -1
  }
  else {
    bigy2[counter]<- 1
  }
  counter<-counter+1
}

tr_indices<-createDataPartition(y=bigy2, p=.8, list=FALSE)
trdat<-bigx[tr_indices,] # training features
trlab<-bigy2[tr_indices] #training labels
otherdat<-bigx[-tr_indices,]
otherlab<-bigy2[-tr_indices]
test_indices<-createDataPartition(y=otherlab, p=.5, list=FALSE)
testdat<-otherdat[test_indices,] # test features
testlab<-otherlab[test_indices] # test labels
valdat<-otherdat[-test_indices,] #validation features
vallab<-otherlab[-test_indices] #validation labels

#exp(1) represents e
lamda_arr<-c(exp(1)-3, exp(1)-2, exp(1)-1, 1)
alpha<-matrix(data=0, ncol=NCOL(bigx))
beta<-0
