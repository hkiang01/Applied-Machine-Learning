#scatter plot matrix

irisdat<-read.csv("iris.data", header=FALSE)
library('lattice');
library('caret')
library('chemometrics')
library('plsdepot')

numiris = irisdat[,c(1,2,3,4)]
speciesnames<-c('setosa', 'versicolor', 'virginica')
pchr<-c(1,2,3)
colr<-c('red', 'green', 'blue', 'yellow', 'orange')
ss<-expand.grid(species =1:3)
parset<-with(ss, simpleTheme(pch = pchr[species], col=colr[species]))
grapihc = splom(irisdat[,c(1:4)], groups=irisdat$V5, par.settings=parset,
      varnames = c('Sepal\nLength', 'Sepal\nWidth','Petal\nLength', 'Petal\nWidth'),
      key = list(text=list(speciesnames), points=list(pch=pchr), columns = 3),
      main = 'Iris Data scatter splot matrix')
print(grapihc)

#PCA
library(mixOmics)
means = apply(numiris, 2, mean)
sds = apply(numiris, 2, sd)

#normalize
normiris = numiris
for (i in 1:4){
  normiris[,i] = (numiris[,i] - means[i])/sds[i]
}

a = mixOmics::nipals(normiris,ncomp = 2, reconst = TRUE)

# is this how you project into principal components? I'm honestly not sure but it sorta works out sorta?
T = t(data.matrix(a$p)) %*% t(data.matrix(normiris))
T = t(T)
#g = plot(T, groups=irisdat$V5, key = list(text=list(speciesnames), points=list(pch=pchr), columns = 3))
g = xyplot(T[, 2] ~ T[,1], groups=irisdat$V5, par.settings=parset,
                key = list(text=list(speciesnames), points=list(pch=pchr), columns = 3),
           xlab='First Principal Component', ylab = 'Second Principal Component', main='Iris Data Projected on 2 Principal Comp')
print(g)


#c
y_label = matrix(0, length(normiris[,1]), 3)
y_label[, 1] = irisdat[, 5] == "Iris-setosa"
y_label[, 2] = irisdat[, 5] == "Iris-versicolor"
y_label[, 3] = irisdat[, 5] == "Iris-virginica"
plsdat<-plsreg2(normiris, y_label, comps=2)
raw_weights<-plsdat$raw.wgs
adj_weights<-plsdat$mod.wgs
xloads<-plsdat$x.loads
iris_scaled_t<-t(normiris)
x_coord<-matrix(data=0, ncol=NCOL(iris_scaled_t))
y_coord<-matrix(data=0, ncol=NCOL(iris_scaled_t))
for(i in 1:NCOL(iris_scaled_t)) {
  #x_coord[i]<-sum(raw_weights[,c(1)]*iris_scaled_t[,c(i)])
  #y_coord[i]<-sum(raw_weights[,c(2)]*iris_scaled_t[,c(i)])
  #x_coord[i]<-sum(adj_weights[,c(1)]*breast_scaled_t[,c(i)])
  #y_coord[i]<-sum(adj_weights[,c(2)]*breast_scaled_t[,c(i)])
  x_coord[i]<-sum(xloads[,c(1)]*iris_scaled_t[,c(i)])
  y_coord[i]<-sum(xloads[,c(2)]*iris_scaled_t[,c(i)])}
adx = xyplot(y_coord ~ x_coord, par.settings=parset,
           key = list(text=list(speciesnames), points=list(pch=pchr), columns = 3),
           xlab='First Principal Component', ylab = 'Second Principal Component', main='PSL2')
print(adx)