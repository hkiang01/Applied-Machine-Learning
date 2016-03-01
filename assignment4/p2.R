setwd('/Users/harry/projects/aml/assignment4/')
library('mixOmics')
wdat<-read.csv('wine_data.csv', header=FALSE)
bigx<-wdat[,-c(1)] #label is the first col
bigy<-wdat[,1]
bigx2<-scale(bigx, center=TRUE, scale=TRUE)

# PART A
# see figure 3.34 in section 3.7
x_nipals<-nipals(bigx2, ncomp=10) #the first eigenvaue is much larger
Eigvalues<-x_nipals$eig
plot(Eigvalues,main="Eigenvalues of covariance matrix in sorted order from NIPALS")
# 4-7 components are good
# based on visual analysis as on bottom of page 81 in 2/16 version of notes

# PART B
# see figure 3.34 in section 3.7
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

# PART C
# see figure 3.27 left graph in section 3.6
x_nipals_selected<-nipals(bigx2, ncomp=2)
bigx3<-t(bigx2) #iterate through cols (each col is a dp)
x_coord<-matrix(data=0, ncol=NCOL(bigx3))
y_coord<-matrix(data=0, ncol=NCOL(bigx3))
# labels are in bigy
for(i in 1:NCOL(bigx3)) {
  x_coord[i]<-sum(x_nipals_selected$p[,c(1)]*bigx3[,c(i)])
  y_coord[i]<-sum(x_nipals_selected$p[,c(2)]*bigx3[,c(i)])
}
wdat$color="black"
wdat$color[wdat[,1]==2]="red"
wdat$color[wdat[,1]==3]="blue"
plot(x_coord,y_coord,col=wdat$color,main="Wine Recognition plotted on two principal components",
     xlab="First principal component", ylab="Second principal component")
legend(2,-2,c("class 1", "class 2", "class 3"),col=c("black", "red", "blue"),pch=1)
# specify pch for plot and legend for filling in circles
