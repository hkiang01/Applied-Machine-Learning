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

library(caret)
library(chemometrics)

breast<-read.csv('wdbc.data', header=FALSE, sep=',')
breast_att<-breast[c(3:32)]
breast_label<-data.matrix(breast[c(2)]) # 1 = benign, 2 = malignant

breast_scaled<-scale(breast_att, center=TRUE, scale=TRUE)

# how to randomize the data partitions
# wtd<-createDataPartition(y=breast_label, p=369/569, list=FALSE)
# train_data<-breast_scaled[wtd,] # 369
# other_data<-breast_scaled[-wtd,]
# other_label<-breast_label[-wtd,] 
# other_wtd<-createDataPartition(y=other_label, p=0.5, list=FALSE)
# test_data<-other_data[other_wtd,] # 100
# val_data<-other_data[-other_wtd,] # 100

# NIPALS
nipples<-nipals(breast_scaled, it = 50, a=3)
nips<-nipples$T # PCA scores
lolz<-nipples$P # PCA loadings

m = nips[which(breast_label==2), ]
b = nips[-which(breast_label==2), ]

write.table(m,file='m_score.csv',row.names=FALSE,col.names=FALSE)
write.table(b,file='b_score.csv',row.names=FALSE,col.names=FALSE)
#write.table(lolz,file='nipals_load.csv',row.names=FALSE,col.names=FALSE)
#write.table(breast_label,file='nipals_label.csv',row.names=FALSE,col.names=FALSE)

# (b) Now use PLS1 to obtain three discriminative directions, and project the
# data on to those directions. Does the plot look better? Explain Keep in
# mind that the most common error here is to forget that the X and the Y in
# PLS1 are centered - i.e. we subtract the mean. Once you have computed
# the first (etc.) direction, you should subtract it from X , but leave Y alone.
