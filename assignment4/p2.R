setwd('/Users/harry/projects/aml/assignment4/')
library('mixOmics')
wdat<-read.csv('wine_data.csv', header=FALSE)
bigx<-wdat[,-c(1)] #label is the first col
bigy<-wdat[,1]
bigx2<-scale(bigx, center=TRUE, scale=TRUE)

# PART A
x_nipals<-nipals(bigx2, ncomp=10) #the first eigenvaue is much larger
eigvalues<-x_nipals$eig
plot(eigvalues)
# 4-7 components are good
# based on visual analysis as on bottom of page 81 in 2/16 version of notes

# PART B
# stem plotting function from: http://www.r-bloggers.com/matlab-style-stem-plot-with-r/
# created by Matti Pastell
attrib_labels<-c("Alcohol", "Malic acid", "Ash", "Alcalinity of ash",
                 "Magnesium", "Total phenols", "Flavanoids",
                 "Nonflavanoid phenols", "Color intensity", "Hue",
                 "OD280/OD315 of diluted wines", "Proline")
stem <- function(x,y,pch=16,linecol=1,clinecol=1,eig_iter=0,...){
  if (missing(y)){
    y = x
    x = 1:length(x) }
  plot(x,y,main=paste("Wine Recognition: Stem Plot of Principal Component",toString(eig_iter)),
       xlab="Attributes",ylab="Energy",
       pch=pch,text(x,y*.8-y*.3*(x%%2)-y*.1*(x%%3),attrib_labels),...)
  for (i in 1:length(x)){
    lines(c(x[i],x[i]), c(0,y[i]),col=linecol)
  }
  lines(c(x[1]-2,x[length(x)]+2), c(0,0),col=clinecol)
}

x_nipals_selected<-nipals(bigx2, ncomp=3)
eigvectors<-x_nipals_selected$p
for(i in 1:NCOL(eigvectors)) {
  stem(eigvectors[,i],eig_iter=i)
}
