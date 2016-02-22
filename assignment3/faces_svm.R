# housekeeping
rm(list=ls())

# libraries
library(klaR)
library(caret)

# import data
# http://www.portfolioprobe.com/user-area/documentation/portfolio-probe-cookbook/data-basics/read-a-tab-separated-file-into-r/
wdat<-read.table('pubfig_dev_50000_pairs.txt')
# v1 is label, rest (v2-v147) are features
bigx<-wdat[,-c(1)] #drop col 1
bigy<-as.factor(wdat[,1]) #coerce col 1 and store as factor (class label)

trscore<-array(dim=10)
testscore<-array(dim=10)

# run svm to generate model
svm<-svmlight(bigx, bigy) #, pathsvm='/Users/harry/projects/aml/assignment3/')

# run on training data
trlabels<-predict(svm, bigx)
trfoo<-trlabels$class
# evaluate performance on training data
trscore<-sum(trfoo==bigy)/(sum(trfoo==bigy)+sum(!(trfoo==bigy)))

valdat1<-read.table('pubfig_kaggle_1.txt')
valdat2<-read.table('pubfig_kaggle_2.txt')
valdat3<-read.table('pubfig_kaggle_3.txt')

val1Labels <- predict(svm, valdat1)
val2Labels <- predict(svm, valdat2)
val3Labels <- predict(svm, valdat3)

solutions1<-read.table('pubfig_kaggle_1_solution.txt', sep=",", header=TRUE)
solutions2<-read.table('pubfig_kaggle_2_solution.txt', sep=",", header=TRUE)
solutions3<-read.table('pubfig_kaggle_3_solution.txt', sep=",", header=TRUE)

sol1<-as.numeric(as.character(solutions1[,2])) #coerce col 2 and store as factor (class label)
sol2<-as.numeric(as.character(solutions2[,2])) #coerce col 2 and store as factor (class label)
sol3<-as.numeric(as.character(solutions3[,2])) #coerce col 2 and store as factor (class label)

val1Result<-val1Labels$class
val2Result<-val2Labels$class
val3Result<-val3Labels$class

testscore1<-sum(val1Result==sol1)/length(val1Result)
testscore2<-sum(val2Result==sol2)/length(val2Result)
testscore3<-sum(val3Result==sol3)/length(val3Result)

eval_dat<-read.table('pubfig_kaggle_eval.txt')
eval_labels<-predict(svm, eval_dat)
eval_res <- data.frame(0:(length(eval_labels$class)-1))
eval_res$new.col<-eval_labels$class
colnames(eval_res) <- c("Id", "Prediction")
write.table(eval_res, file="pubfig_kaggle_eval_results_linsvm.txt", quote=FALSE, sep=",",  row.names = F)

