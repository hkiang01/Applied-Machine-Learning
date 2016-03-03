# The UC Irvine machine learning data repository hosts a collection of data
# on breast cancer diagnostics, donated by Olvi Mangasarian, Nick Street, and
# William H. Wolberg. You can find this data at http://archive.ics.uci.edu/ml/
# datasets/Breast+Cancer+Wisconsin+(Diagnostic). For each record, there is an
# id number, 10 continuous variables, and a class (benign or malignant). There
# are 569 examples. Separate this dataset randomly into 100 validation, 100
# test, and 369 training examples.

# I <3 (.)(.)

# (a) Plot this dataset on the first three principal components, using different
# markers for benign and malignant cases. What do you see?
#setwd('/Users/harry/projects/aml/assignment4/')

library('caret')
library('mixOmics')
library('plsdepot')
library('plot3Drgl')

breast<-read.csv('wdbc.data', header=FALSE, sep=',')
breast_att<-breast[c(3:32)]
breast_label<-data.matrix(breast[c(2)]) # 1 = benign, 2 = malignant

breast_scaled<-scale(breast_att, center=TRUE, scale=TRUE)
breast_scaled_t<-t(breast_scaled)

# NIPALS
nipples<-nipals(breast_scaled, ncomp=3)
scores<-nipples$t # PCA scores
loadings<-nipples$p # PCA loadings

xa<-matrix(data=0, ncol=NCOL(breast_scaled_t))
ya<-matrix(data=0, ncol=NCOL(breast_scaled_t))
za<-matrix(data=0, ncol=NCOL(breast_scaled_t))

for (i in 1:NCOL(breast_scaled_t)) {
  xa[i]<-sum(loadings[,c(1)]*breast_scaled_t[,c(i)])
  ya[i]<-sum(loadings[,c(2)]*breast_scaled_t[,c(i)])
  za[i]<-sum(loadings[,c(3)]*breast_scaled_t[,c(i)])
}

# export to MATLAB for plotting
xa<-t(xa)
ya<-t(ya)
za<-t(za)

xma<-xa[which(breast_label==2), ]
yma<-ya[which(breast_label==2), ]
zma<-za[which(breast_label==2), ]
xba<-xa[-which(breast_label==2), ]
yba<-ya[-which(breast_label==2), ]
zba<-za[-which(breast_label==2), ]

write.table(xma,file='breast_results/xma.csv',row.names=FALSE,col.names=FALSE)
write.table(yma,file='breast_results/yma.csv',row.names=FALSE,col.names=FALSE)
write.table(zma,file='breast_results/zma.csv',row.names=FALSE,col.names=FALSE)
write.table(xba,file='breast_results/xba.csv',row.names=FALSE,col.names=FALSE)
write.table(yba,file='breast_results/yba.csv',row.names=FALSE,col.names=FALSE)
write.table(zba,file='breast_results/zba.csv',row.names=FALSE,col.names=FALSE)

# (b) Now use PLS1 to obtain three discriminative directions, and project the
# data on to those directions. Does the plot look better? Explain Keep in
# mind that the most common error here is to forget that the X and the Y in
# PLS1 are centered - i.e. we subtract the mean. Once you have computed
# the first (etc.) direction, you should subtract it from X , but leave Y alone.

plsdat<-plsreg1(breast_scaled, breast_label, comps=3)
raw_weights<-plsdat$raw.wgs
adj_weights<-plsdat$mod.wgs
xloads<-plsdat$x.loads
breast_scaled_t<-t(breast_scaled)

xb<-matrix(data=0, ncol=NCOL(breast_scaled_t))
yb<-matrix(data=0, ncol=NCOL(breast_scaled_t))
zb<-matrix(data=0, ncol=NCOL(breast_scaled_t))

for(i in 1:NCOL(breast_scaled_t)) {
#   xb[i]<-sum(raw_weights[,c(1)]*breast_scaled_t[,c(i)])
#   yb[i]<-sum(raw_weights[,c(2)]*breast_scaled_t[,c(i)])
#   zb[i]<-sum(raw_weights[,c(3)]*breast_scaled_t[,c(i)])
  #xb[i]<-sum(adj_weights[,c(1)]*breast_scaled_t[,c(i)])
  #yb[i]<-sum(adj_weights[,c(2)]*breast_scaled_t[,c(i)])
  #zb[i]<-sum(adj_weights[,c(3)]*breast_scaled_t[,c(i)])
  xb[i]<-sum(xloads[,c(1)]*breast_scaled_t[,c(i)])
  yb[i]<-sum(xloads[,c(2)]*breast_scaled_t[,c(i)])
  zb[i]<-sum(xloads[,c(3)]*breast_scaled_t[,c(i)])}

xb<-t(xb)
yb<-t(yb)
zb<-t(zb)

# export to MATLAB for plotting
xmb<-xb[which(breast_label==2), ]
ymb<-yb[which(breast_label==2), ]
zmb<-zb[which(breast_label==2), ]
xbb<-xb[-which(breast_label==2), ]
ybb<-yb[-which(breast_label==2), ]
zbb<-zb[-which(breast_label==2), ]

write.table(xmb,file='breast_results/xmb.csv',row.names=FALSE,col.names=FALSE)
write.table(ymb,file='breast_results/ymb.csv',row.names=FALSE,col.names=FALSE)
write.table(zmb,file='breast_results/zmb.csv',row.names=FALSE,col.names=FALSE)
write.table(xbb,file='breast_results/xbb.csv',row.names=FALSE,col.names=FALSE)
write.table(ybb,file='breast_results/ybb.csv',row.names=FALSE,col.names=FALSE)
write.table(zbb,file='breast_results/zbb.csv',row.names=FALSE,col.names=FALSE)
# breast$color="red" #1 is tumor
# breast$color[breast[,c(2)]=="M"]="green" #2 is malignant
#  open3d(params=(windowRect=c(100,50,150,200)))
#  plot3d(xb, yb, zb, col=breast$color, main="Breast Cancer Data Using PLS1",
#       xlab="Direction 1", ylab="Direction 2", zlab="Direction 3")