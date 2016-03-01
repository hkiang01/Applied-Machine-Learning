#scatter plot matrix

irisdat<-read.csv("iris.data", header=FALSE)
library('lattice');
numiris = irisdat[,c(1,2,3,4)]
speciesnames<-c('setosa', 'versicolor', 'virginica')
pchr<-c(1,2,3)
colr<-c('red', 'green', 'blue', 'yellow', 'orange')
ss<-expand.grid(species =1:3)
parset<-with(ss, simpleTheme(pch = pchr[species], col=colr[species]))
grapihc = splom(irisdat[,c(1:4)], groups=irisdat$V5, par.settings=parset,
      varnames = c('Sepal\nLength', 'Sepal\nWidth','Petal\nLength', 'Petal\nWidth'),
      key = list(text=list(speciesnames), points=list(pch=pchr), columns = 3))
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

a = nipals(normiris,ncomp = 2)

# is this how you project into principal components? I'm honestly not sure but it sorta works out sorta?
T = data.matrix(normiris) %*% data.matrix(a$p)
