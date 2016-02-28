# 3.4.2 for 2-16 version of notes for general procedure
# see procedure 3.1
# see definition 3.1 for covariance
# see definition 3.2 and for covariance matrix (section 3.2, page 63 of 2/16/16 version of notes)

setwd('/Users/harry/projects/aml/assignment4/')
library('mixOmics')
wdat<-read.csv('wine_data.csv', header=FALSE)
bigx<-wdat[,-c(1)] #label is the first col
bigy<-wdat[,1]

# translate the blob so its mean is at the origin
# each component of mean{x} is the mean of that component of the data
# see 3.2.1 The Mean
# http://stackoverflow.com/questions/18065929/how-to-row-wise-subtract-a-vector-keeping-the-means-of-a-data-frames-df-column
bigx2<-scale(bigx, center=TRUE, scale=TRUE)
# BUGGY CODE
# bigx3<-t(bigx2)
# covmat<-matrix(data=0, nrow=NCOL(bigx3), ncol=NCOL(bigx3)) #the covmat
# 
# # populate the covmat
# for (j in 1:NCOL(bigx3)) {
#   for (k in 1:NCOL(bigx3)) {
#     x_j<-as.matrix(bigx3[,c(j)])
#     x_k<-as.matrix(t(bigx3[,c(k)]))
#     val<-sum((x_j*t(x_k)))
#     covmat[,c(j)][k]<-val
#   }
# }
# 
# eigendat<-eigen(covmat)
# eigenvalues<-eigendat$values
# eigenvalues_sorted<-sort(eigenvalues)
# plot(eigenvalues_sorted)
# END OF BUGGY CODE

# PART A
x_nipals<-nipals(bigx2, ncomp=10) #the first eigenvaue is much larger
eigvalues<-x_nipals$eig
plot(eigvalues)
# 4-7 components are good
# based on visual analysis as on bottom of page 81 in 2/16 version of notes
# END OF PART A

# PART B
