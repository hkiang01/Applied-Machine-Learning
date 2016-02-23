# libraries
library(klaR)
library(caret)
library(e1071)

# import data
# http://www.portfolioprobe.com/user-area/documentation/portfolio-probe-cookbook/data-basics/read-a-tab-separated-file-into-r/
wdat<-read.table('pubfig_dev_50000_pairs.txt')
# v1 is label, rest (v2-v147) are features
labels<-wdat[,1] #Y
features<-wdat[,-c(1)] #X
trscore<-array(dim=10)
tescore<-array(dim=10)

ntrbx<-features #.8*700 x 8 matrix of features
ntrby<-labels # features of respective wtd entries
trposflag<-ntrby>0 # .8*700 x 1 matrix of T/F (T==1, F==0)
ptregs<-ntrbx[trposflag, ] # subset of feature matrix with label 1 (same as pegs in example)
ntregs<-ntrbx[!trposflag,] # subset of feature matrix with label 0 (same as negs in example)

eval_dat<-read.table('pubfig_kaggle_eval.txt')

ntebx<-eval_dat # testing features

ptrmean<-sapply(ptregs, mean, na.rm=FALSE) # positive training mean excluding N/A's
ntrmean<-sapply(ntregs, mean, na.rm=FALSE) # negative training mean excluding N/A's
ptrsd<-sapply(ptregs, sd, na.rm=FALSE) #positive training standard dev excluding N/A's
ntrsd<-sapply(ntregs, sd, na.rm=FALSE) #negative training standard dev excluding N/A's
ptroffsets<-t(t(ntrbx)-ptrmean) # subtract mean from positive training
ptrscales<-t(t(ptroffsets)/ptrsd) # divide positive training by std dev
# square positive training and subtract the log of std dev
ptrlogs<--(1/2)*rowSums(apply(ptrscales,c(1, 2), function(x)x^2), na.rm=TRUE)-sum(log(ptrsd))
ntroffsets<-t(t(ntrbx)-ntrmean)
ntrscales<-t(t(ntroffsets)/ntrsd)
ntrlogs<--(1/2)*rowSums(apply(ntrscales,c(1, 2), function(x)x^2), na.rm=TRUE)-sum(log(ntrsd))
lvwtr<-ptrlogs>ntrlogs #note that addition of log of prior is unecessary as they are both about equal
gotrighttr<-lvwtr==ntrby #true if classification got right answer, false else
trscore<-sum(gotrighttr)/(sum(gotrighttr)+sum(!gotrighttr)) # performance of classifier on splits
# perform classification on test data
pteoffsets<-t(t(ntebx)-ptrmean)
ptescales<-t(t(pteoffsets)/ptrsd)
ptelogs<--(1/2)*rowSums(apply(ptescales,c(1, 2), function(x)x^2), na.rm=TRUE)-sum(log(ptrsd))
nteoffsets<-t(t(ntebx)-ntrmean)
ntescales<-t(t(nteoffsets)/ntrsd)
ntelogs<--(1/2)*rowSums(apply(ntescales,c(1, 2), function(x)x^2), na.rm=TRUE)-sum(log(ntrsd))
lvwte<-ptelogs>ntelogs

eval_res <- data.frame(0:(length(lvwte)-1))
eval_res$new.col<-lvwte
colnames(eval_res) <- c("Id", "Prediction")
write.table(eval_res, file="pubfig_kaggle_eval_results_naivebayes.txt", quote=FALSE, sep=",",  row.names = F)


# wtd<-createDataPartition(y=labels, p=.8, list=FALSE)
 
# trlabels<-features[wtd,]
# trfeatures<-labels[wtd]

# telabels<-features[-wtd,]
# tefeatures<-labels[-wtd]

# nb<-naiveBayes(trlabels, trfeatures)
# table(predict(nb, telabels), trlabels)
#prediction<-predict(nb,telabels)
# table(prediction, trlabels$Class)


