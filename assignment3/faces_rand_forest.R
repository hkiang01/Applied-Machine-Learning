# housekeeping
rm(list=ls())

library(randomForest)
library(caret)


# import data
# http://www.portfolioprobe.com/user-area/documentation/portfolio-probe-cookbook/data-basics/read-a-tab-separated-file-into-r/
wdat<-read.table('pubfig_dev_50000_pairs.txt')
# v1 is label, rest (v2-v147) are features
bigx = wdat[,-c(1)] #drop col 1
bigy<-as.factor(wdat[,1]) #coerce col 1 and store as factor (class label)

# # import validation data
valdat1<-read.table('pubfig_kaggle_1.txt')
valdat2<-read.table('pubfig_kaggle_2.txt')
valdat3<-read.table('pubfig_kaggle_3.txt')

trscore<-array(dim=10)
testscore<-array(dim=10)

trBigX <- bigx
trBigY <- bigy

#  tsBigX <- bigx[-wtd,]
#  tsBigY <- bigy[-wtd]

model <- randomForest(trBigX, trBigY, ntree = 1000)
trResult <- predict(model, trBigX)
colnames(valdat1) <- colnames(bigx)
colnames(valdat2) <- colnames(bigx)
colnames(valdat3) <- colnames(bigx)

# val1Result <- predict(model, valdat1)
# val2Result <- predict(model, valdat2)
# val3Result <- predict(model, valdat3)
# 
# solutions1<-read.table('pubfig_kaggle_1_solution.txt', sep=",", header=TRUE)
# solutions2<-read.table('pubfig_kaggle_2_solution.txt', sep=",", header=TRUE)
# solutions3<-read.table('pubfig_kaggle_3_solution.txt', sep=",", header=TRUE)
# 
# sol1<-as.numeric(as.character(solutions1[,2])) #coerce col 2 and store as factor (class label)
# sol2<-as.numeric(as.character(solutions2[,2])) #coerce col 2 and store as factor (class label)
# sol3<-as.numeric(as.character(solutions3[,2])) #coerce col 2 and store as factor (class label)
# 
# testscore1<-sum(val1Result==sol1)/length(val1Result)
# testscore2<-sum(val2Result==sol2)/length(val2Result)
# testscore3<-sum(val3Result==sol3)/length(val3Result)
trAccuracy = sum(trResult == trBigY)/length(trBigY)

eval_dat<-read.table('pubfig_kaggle_eval.txt')
colnames(eval_dat) <- colnames(bigx)
eval_labels<-predict(model, eval_dat)
eval_res <- data.frame(0:(length(eval_labels)-1))
eval_res$new.col<-as.numeric(as.character(eval_labels))
colnames(eval_res) <- c("Id", "Prediction")
write.table(eval_res, file="pubfig_kaggle_eval_results_randFor.txt", quote=FALSE, sep=",",  row.names = F)
