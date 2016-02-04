setwd('~/Current/Courses/LearningCourse/Pima')
wdat<-read.csv('data.txt', header=FALSE)
library(klaR)
library(caret)


bigx<-wdat[,-c(9)] #drop col 9 that contains labels
bigy<-as.factor(wdat[,9]) #coerce col 9 into storing it as a factor (takes in fixed number of vars)
wtd<-createDataPartition(y=bigy, p=.8, list=FALSE) #randomly split 80% of data
trax<-bigx[wtd,] #training features
tray<-bigy[wtd] #choose rows with indices wtd
model<-train(trax, tray, 'nb', trControl=trainControl(method='cv', number=10)) #trust validation built in, in this case 10 times
teclasses<-predict(model,newdata=bigx[-wtd,]) #gives predictions on test data
confusionMatrix(data=teclasses, bigy[-wtd])
