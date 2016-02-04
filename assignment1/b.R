wdat<-read.csv('data.txt', header=FALSE)
library(klaR)
library(caret)
bigx<-wdat[,-c(9)]
bigy<-wdat[,9]
nbx<-bigx
for (i in c(3, 4, 6, 8))# for i in 3,4,6,8 
{vw<-bigx[, i]==0 #whether entry in bigx in that col is 0
 nbx[vw, i]=NA #replace with NA (NA+1=NA)
}
trscore<-array(dim=10)
tescore<-array(dim=10)
for (wi in 1:10)
{wtd<-createDataPartition(y=bigy, p=.8, list=FALSE)
 ntrbx<-nbx[wtd, ]
 ntrby<-bigy[wtd]
 trposflag<-ntrby>0
 ptregs<-ntrbx[trposflag, ]
 ntregs<-ntrbx[!trposflag,]
 ntebx<-nbx[-wtd, ]
 nteby<-bigy[-wtd]
 ptrmean<-sapply(ptregs, mean, na.rm=TRUE) #ignore any NA
 ntrmean<-sapply(ntregs, mean, na.rm=TRUE)
 ptrsd<-sapply(ptregs, sd, na.rm=TRUE)
 ntrsd<-sapply(ntregs, sd, na.rm=TRUE)
 ptroffsets<-t(t(ntrbx)-ptrmean)
 ptrscales<-t(t(ptroffsets)/ptrsd)
 ptrlogs<--(1/2)*rowSums(apply(ptrscales,c(1, 2), function(x)x^2), na.rm=TRUE)-sum(log(ptrsd))
 ntroffsets<-t(t(ntrbx)-ntrmean)
 ntrscales<-t(t(ntroffsets)/ntrsd)
 ntrlogs<--(1/2)*rowSums(apply(ntrscales,c(1, 2), function(x)x^2), na.rm=TRUE)-sum(log(ntrsd))
 lvwtr<-ptrlogs>ntrlogs
 gotrighttr<-lvwtr==ntrby
 trscore[wi]<-sum(gotrighttr)/(sum(gotrighttr)+sum(!gotrighttr))
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
