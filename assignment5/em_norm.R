
itNum <- 1
dim <- 5
N <- 30  #number of clusters

wdat
xdat
n <- nrow(xdat)
piProb # N elements
weight # n by N
distMean # n by N

for(it in 1:itNum){
  
  # calculate weights
  for (i in 1:n){
    for (j in 1:N){
      x = xdat[i, ]
      numerator <- exp(1/2 * t(x - distMean[j]) %*% (x - distMean[j])) * piProb[j]
      denomSum <- 0
      for (k in 1:N){
        denomSum = denomSum + exp(1/2 * t(x - distMean[k]) %*% (x - distMean[k])) * piProb[k]
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
    distMean = productSum / weightSum;
    piProb[j] = weightSum/N;
  }
}