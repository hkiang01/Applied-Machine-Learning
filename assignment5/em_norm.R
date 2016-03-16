library(jpeg)
library(ForeCA)
img = readJPEG("test_images/mountains.jpg", native = FALSE)

itNum <- 30
N <- 10  #number of clusters

red <- img[,,1]
green <- img[,,2]
blue <- img[,,3]

imgH = nrow(red)
imgW = ncol(red)

dim(red) <- NULL
dim(green) <- NULL
dim(blue) <- NULL

xdatRaw <- matrix(0, length(red), 3)
xdatRaw[,1] <- red
xdatRaw[,2] <- green
xdatRaw[,3] <- blue

d <- ncol(xdatRaw)
n <- nrow(xdatRaw)

xdat <- whiten(xdatRaw)$U

xdat <- xdat * 5

piProb <- rep(1/N, N)# N elements
weight <- matrix(0, n, N) # n by N
distMean <- matrix(0, N, d) # N by d

#initialize means
randChoice <- sample(1:n, N, replace=FALSE)
for (i in 1:N){
  r <- randChoice[i]
  distMean[i, ] <- xdat[r,]
}

for(it in 1:itNum){
  print(it)
  
  # calculate weights
#   for (i in 1:n){
#     for (j in 1:N){
#       x = xdat[i, ]
#       numerator <- exp(-1/2 * t(x - distMean[j, ]) %*% (x - distMean[j, ])) * piProb[j]
#       denomSum <- 0
#       for (k in 1:N){
#         denomSum = denomSum + exp(-1/2 * t(x - distMean[k]) %*% (x - distMean[k])) * piProb[k]
#       }
#       weight[i, j] = numerator / denomSum
#     }
#   }
  denomSum <- rep(0, i)
  for (j in 1:N){
    x = xdat
    difference = t(t(x) - distMean[j,])
    distance = rowSums(difference^2)
    
    numerator <- exp(-1/2 * distance) * piProb[j]

    weight[, j] = numerator
    denomSum <- denomSum + numerator
  }
  weight <- weight/denomSum
  
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

denomSum <- rep(0, i)
for (j in 1:N){
  x = xdat
  difference = t(t(x) - distMean[j,])
  distance = rowSums(difference^2)
  
  numerator <- exp(-1/2 * distance) * piProb[j]
  
  weight[, j] = numerator
  denomSum <- denomSum + numerator
}
weight <- weight/denomSum
clusters <- apply(weight, 1, which.max)

output <- xdatRaw * 0
color <- matrix(0, N, 3);
for (i in 1:N){
  x = xdatRaw[clusters == i,]
  newMean <- apply(x, 2, mean)
  color[i, ] = newMean
  output[clusters == i, 1] = newMean[1]
  output[clusters == i, 2] = newMean[2]
  output[clusters == i, 3] = newMean[3]
}

dim(output) <- c(imgH, imgW, 3)

writeJPEG(output, target = "a.jpg", quality = 1, bg = "white")
writeJPEG(color, target = "palette.jpg", quality = 1, bg = "white")

colorCount = rep(0, N)
for (i in 1:N){
  colorCount [i] = print(sum(clusters == i))
}
