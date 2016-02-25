# 3.4.2 for 2-16 version of notes for general procedure
# see procedure 3.1

setwd('/Users/harry/projects/aml/assignment4/')
wdat<-read.csv('wine_data.csv', header=FALSE)
bigx<-wdat[,-c(1)] #label is the first col
bigy<-wdat[,1]

# translate the blob so its mean is at the origin
# each component of mean{x} is the mean of that component of the data
# see 3.2.1 The Mean
# http://stackoverflow.com/questions/18065929/how-to-row-wise-subtract-a-vector-keeping-the-means-of-a-data-frames-df-column
bigx<-scale(bigx, center=TRUE, scale=FALSE)