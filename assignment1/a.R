wdat<-read.csv('data.txt', header=FALSE)
library(klaR)
library(caret)
bigx<-wdat[,-c(9)]
bigy<-wdat[,9]
trscore<-array(dim=10)
tescore<-array(dim=10)
for (wi in 1:10)
{
 #wi<-1 # 1 split (no cross-validation)
 wtd<-createDataPartition(y=bigy, p=.8, list=FALSE) #random .8
 nbx<-bigx
 ntrbx<-nbx[wtd, ] #.8*700 x 8 matrix of features
 ntrby<-bigy[wtd] # features of respective wtd entries
 trposflag<-ntrby>0 # .8*700 x 1 matrix of T/F (T==1, F==0)
 ptregs<-ntrbx[trposflag, ] # subset of feature matrix with label 1 (same as pegs in example)
 ntregs<-ntrbx[!trposflag,] # subset of feature matrix with label 0 (same as negs in example)
 ntebx<-nbx[-wtd, ] # testing features
 nteby<-bigy[-wtd] # testing labels
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
 trscore[wi]<-sum(gotrighttr)/(sum(gotrighttr)+sum(!gotrighttr)) # performance of classifier on splits
 # perform classification on test data
 pteoffsets<-t(t(ntebx)-ptrmean)
 ptescales<-t(t(pteoffsets)/ptrsd)
 ptelogs<--(1/2)*rowSums(apply(ptescales,c(1, 2), function(x)x^2), na.rm=TRUE)-sum(log(ptrsd))
 nteoffsets<-t(t(ntebx)-ntrmean)
 ntescales<-t(t(nteoffsets)/ntrsd)
 ntelogs<--(1/2)*rowSums(apply(ntescales,c(1, 2), function(x)x^2), na.rm=TRUE)-sum(log(ntrsd))
 lvwte<-ptelogs>ntelogs
 gotright<-lvwte==nteby
 tescore[wi]<-sum(gotright)/(sum(gotright)+sum(!gotright))
}
trscoremean<-mean(trscore)
tescoremean<-mean(tescore)
