
xdat <- matrix(c(100, 87,5,3,4,5,8,45,40,39),5,2)
ret <- em_multinomial(xdat, 2)

#em_multinomial 
# Parameters:
#   xdatRaw: input data into 
#   N: Number of clusters
#   itNum: Number of iterations
# Return:
#   2 element list
#     - wordProb: probability of each word for every cluster
#                 N by d. rows are clusters. cols are individual word probs
#     - clusterProb: Probability of each cluster. Length N array
em_multinomial <- function(xdatRaw, N, itNum = 100){
  xdat <- xdatRaw
    d <- ncol(xdat)
  n <- nrow(xdat)
  clusterProb <- rep(1/N, N)# N elements
  wordProb <- matrix(1/d, N, d) # N by d
  weight <- matrix(0, n, N) # n by N
  
  #initialize wordProb
  randChoice <- sample(1:n, N, replace=FALSE)
  for (i in 1:N){
    r <- randChoice[i]
    sumWords <- sum(xdat[r, ])
    wordProb[i, ] <- xdat[r,] / sumWords
  }
  
  for(it in 1:itNum){
    
    # calculate weights
    for (i in 1:n){
      for (j in 1:N){
        x = xdat[i, ]
        
        numerator <- clusterProb[j]
        denomSum <- 0
        for (k in 1:d){
          numerator <- numerator * (wordProb[j, k] ^ x[k])
        }
        for (l in 1:N){
          denomProduct <- clusterProb[l]
          for (k in 1:d){
            denomProduct <- denomProduct * (wordProb[l,k] ^ x[k])
          }
          denomSum = denomSum + denomProduct
        }
        weight[i, j] = numerator / denomSum
      }
    }
    
    #M step
    for (j in 1:N){
      productSum <- rep(0, d)
      weightSum <- 0
      weightSumNorm <- 0
      for (i in 1:n){
        productSum <- productSum + xdat[i, ]*weight[i,j]
        weightSumNorm <- weightSumNorm + sum(xdat[i,]) * weight[i,j]
        weightSum <- weightSum + weight[i,j]
      }
      wordProb[j, ] = productSum / weightSumNorm;
      clusterProb[j] = weightSum/n;
    }
  }
  
  return(list(wordProb=wordProb, clusterProb=clusterProb))
}