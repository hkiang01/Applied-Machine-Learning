
itNum <- 100
N <- 2  #number of clusters

xdatRaw <- matrix(c(100, 87,5,3,4,5,8,45,40,39),5,2)
d <- ncol(xdatRaw)
n <- nrow(xdatRaw)

datMean <- apply(xdatRaw, 2, mean)
datSD <- apply(xdatRaw, 2, sd)

xdat <- xdatRaw
for (i in 1:d){
  xdat[ ,i] = (xdatRaw[,i] - datMean[i] )/datSD[i]
}


piProb <- rep(1/N, N)# N elements
weight <- matrix(0, n, N) # n by N
distMean <- matrix(0, N, d) # N by d

#initialize means
#randChoice <- sample(1:n, N, replace=FALSE)
randChoice <- c(1,5)
for (i in 1:N){
  r <- randChoice[i]
  distMean[i, ] <- xdat[r,]
}

for(it in 1:itNum){
  
  # calculate weights
  for (i in 1:n){
    for (j in 1:N){
      x = xdat[i, ]
      numerator <- exp(-1/2 * t(x - distMean[j, ]) %*% (x - distMean[j, ])) * piProb[j]
      denomSum <- 0
      for (k in 1:N){
        denomSum = denomSum + exp(-1/2 * t(x - distMean[k]) %*% (x - distMean[k])) * piProb[k]
      }
      weight[i, j] = numerator / denomSum
    }
  }
  
  #M step
  #calculate means of the cluster distributions
  for (j in 1:N){
    productSum <- rep(0, d)
    weightSum <- 0
    for (i in 1:n){
      productSum <- productSum + xdat[i, ]*weight[i,j]
      weightSum <- weightSum + weight[i,j]
    }
    distMean[j, ] = productSum / weightSum;
    piProb[j] = weightSum/n;
  }
}