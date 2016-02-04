wdat<-read.csv('data.txt', header=FALSE)
library(klaR)
library(caret)
trscore<-array(dim=1)
tescore<-array(dim=1)
bigx<-wdat[,-c(9)] #drop col 9 that contains labels
bigy<-as.factor(wdat[,9]) #coerce col 9 into storing it as a factor (takes in fixed number of vars)
for (wi in 1:10) #trControl's number argument takes care of this
{
  wtd<-createDataPartition(y=bigy, p=.8, list=FALSE) #randomly split 80% of data
  trax<-bigx[wtd,] #training features
  tray<-bigy[wtd] #choose rows with indices wtd
  #trust validation built in, in this case 10 times
  model<-train(trax, tray, 'nb', trControl=trainControl(method='cv', number=10))
  trclasses<-predict(model,newdata=bigx[wtd,])
  teclasses<-predict(model,newdata=bigx[-wtd,]) #gives predictions on test data
  trmatrixresult<-confusionMatrix(data=trclasses, bigy[wtd])
  tematrixresult<-confusionMatrix(data=teclasses, bigy[-wtd])
  trscore[wi]<-trmatrixresult$overall['Accuracy']
  tescore[wi]<-tematrixresult$overall['Accuracy']
}
trscoremean<-mean(trscore)
tescoremean<-mean(tescore)
