wdat<-read.csv('adult.data', header=FALSE)
library(klaR)
library(caret)
bigx<-wdat[,-c(16)]
bigy<-wdat[,16]

