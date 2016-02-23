# THIS IS USING THE NONLINEAR KERNEL FROM SVMLIGHT

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


# partition 80% of data for training
# run svm to generate model using polynomial kernel (linear is default)
#svm<-svmlight(bigx[wtd,], bigy[wtd], pathsvm='/Users/harry/projects/aml/assignment3') #svm.options = "-t 1",
svm1<-svmlight(bigx, bigy, svm.options = "-t 1") #svm.options = "-t 1",

# # run on training data
trlabels<-predict(svm, bigx)
trfoo<-trlabels$class
# evaluate performance on training data
trscore<-sum(trfoo==bigy)/length(bigy)
# 
# # run on testing data (remaining 20%)
# labels<-predict(svm, bigx[-wtd,])
# foo<-labels$class
# #evaluate performance on test data
# testscore<-sum(foo==bigy[-wtd])/(sum(foo==bigy[-wtd])+sum(!(foo==bigy[-wtd])))
# 
# # import validation data
# valdat1<-read.table('pubfig_kaggle_1.txt')
# valdat2<-read.table('pubfig_kaggle_2.txt')
# valdat3<-read.table('pubfig_kaggle_3.txt')
# 
# # run on validation data pubfig_kaggle_[1,2,3].txt
# vallabels1<-predict(svm, valdat1)
# vallabels2<-predict(svm, valdat2)
# vallabels3<-predict(svm, valdat3)
# 
# foo1<-vallabels1$class
# foo2<-vallabels2$class
# foo3<-vallabels3$class
# 
# # import solutions
# solutions1<-read.table('pubfig_kaggle_1_solution.txt', sep=",", header=TRUE)
# solutions2<-read.table('pubfig_kaggle_2_solution.txt', sep=",", header=TRUE)
# solutions3<-read.table('pubfig_kaggle_3_solution.txt', sep=",", header=TRUE)
# 
# sol1<-as.numeric(as.character(solutions1[,2])) #coerce col 2 and store as factor (class label)
# res1<-as.numeric(as.character(foo1))
# 
# sol2<-as.numeric(as.character(solutions2[,2])) #coerce col 2 and store as factor (class label)
# res2<-as.numeric(as.character(foo2))
# 
# sol3<-as.numeric(as.character(solutions3[,2])) #coerce col 2 and store as factor (class label)
# res3<-as.numeric(as.character(foo3))
# 
# # evaluate performance on test date
# testscore1<-sum(res1==sol1)/length(res1)
# testscore2<-sum(res2==sol2)/length(res2)
# testscore3<-sum(res3==sol3)/length(res3)

eval_dat<-read.table('pubfig_kaggle_eval.txt')
eval_labels<-predict(svm1, eval_dat)
eval_foo<-eval_labels$class
eval_res<-as.numeric(as.character(eval_foo))
write.table(eval_res, file="pubfig_kaggle_eval_results.txt", quote=FALSE, sep=",")