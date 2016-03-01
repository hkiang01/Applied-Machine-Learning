# The UC Irvine machine learning data repository hosts a collection of data
# on breast cancer diagnostics, donated by Olvi Mangasarian, Nick Street, and
# William H. Wolberg. You can find this data at http://archive.ics.uci.edu/ml/
# datasets/Breast+Cancer+Wisconsin+(Diagnostic). For each record, there is an
# id number, 10 continuous variables, and a class (benign or malignant). There
# are 569 examples. Separate this dataset randomly into 100 validation, 100
# test, and 369 training examples.
# (a) Plot this dataset on the first three principal components, using different
# markers for benign and malignant cases. What do you see?
# (b) Now use PLS1 to obtain three discriminative directions, and project the
# data on to those directions. Does the plot look better? Explain Keep in
# mind that the most common error here is to forget that the X and the Y in
# PLS1 are centered - i.e. we subtract the mean. Once you have computed
# the first (etc.) direction, you should subtract it from X , but leave Y alone.

# I <3 (.)(.)


# (a)

library(chemometrics)

breast<-read.csv('breast-cancer-wisconsin.data', header=FALSE, sep=',')
breast_att<-breast[c(2:10)]
breast_label<-data.matrix(breast[c(11)]) # 2 = benign, 4 = malignant

for (i in c(1:9)) # for i in 3,4,6,8
{vw<-breast_att[, i]=='?' #whether entry in that col is 0
breast_att[vw, i]=NA #replace with NA (NA+1=NA)
}

breast_att<-data.matrix(breast_att)
breast_att[is.na(breast_att)]<-0 # changed from NA to 0 because very few NA exist
breast_scaled<-scale(breast_att, center=TRUE, scale=TRUE)

# how to randomize the data partitions
wtd<-createDataPartition(y=breast_label, p=499/699, list=FALSE)
train_data<-breast_scaled[wtd,] # 499

other_data<-breast_scaled[-wtd,]
other_label<-breast_label[-wtd,] 
other_wtd<-createDataPartition(y=other_label, p=0.5, list=FALSE)
test_data<-other_data[other_wtd,] # 100
val_data<-other_data[-other_wtd,] # 100

# NIPALS
nipples<-nipals(train_data, it = 200, a=3, tol = 1e-04)
nips<-nipples$T
lolz<-nipples$P

# (b)