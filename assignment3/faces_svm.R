# libraries
library(klaR)
library(caret)

# import data
# http://www.portfolioprobe.com/user-area/documentation/portfolio-probe-cookbook/data-basics/read-a-tab-separated-file-into-r/
wdat<-read.table('pubfig_dev_50000_pairs.txt')
# v1 is label, rest (v2-v147) are features
labels<-wdat[1]
features<-wdat[-1]
#for (wi in 1:10) {
  wtd<-createDataPartition(y=labels, p=.8, list=FALSE)
  svm<-svmlight(features[wtd,], labels[wtd], pathsvm='.')
  trlabels<-predict(svm, features[wtd,])
  
#}