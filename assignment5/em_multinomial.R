setwd('/Users/harry/projects/aml/assignment5/')
vocab<-read.table('vocab.nips.txt') #vocab.[asdf].txt
docword<-read.table('docword.nips.txt', skip=3) #docword.[asdf].txt
wordProbConstant<-0.000001
numTopics<-30
topWordsPerTopic<-10

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
  clusterProb <- rep(1/N, N)# N elements of all equal prob
  wordProb <- matrix(1/d, N, d) # N by d
  weight <- matrix(0, n, N) # n by N
  
  #initialize wordProb
  randChoice <- sample(1:n, N, replace=FALSE) #pick cluster number of random dp's
  for (i in 1:N){ #for each cluster
    r <- randChoice[i]#pick corresponding random row
    sumWords <- sum(xdat[r, ]) #the row
    wordProb[i, ] <- xdat[r,] / sumWords #prob for each word for each cluster
  }
  
  #normalize wordProb by adding a small constant
  wordProb <- wordProb + wordProbConstant
  for (i in 1:N){
    normalizeRow = sum(wordProb[i, ])
    wordProb[i, ] = wordProb[i, ] / normalizeRow
  }
  
  #wordProb has the prob of each word for each cluster (random dp)
  
  for(it in 1:itNum){
    
    # calculate weights
    for (i in 1:n){ # for each dp
      
      numArr<-array(0,0,0) #stores log(A_j) for all clusters 1 to j
      
      for (j in 1:N){ #for each cluster
        x = xdat[i, ] # get the dp (the row)
        
        #numerator <- clusterProb[j] # get the prior for cluster j
        #for (k in 1:d){
        #  numerator <- numerator * (wordProb[j, k] ^ x[k])
        #  #numerator <- numerator * (wordProb[j, k] ^ xdat[i,k])
        #}
        numerator<-sum(log(wordProb[j,])*xdat[i,]) + log(clusterProb[j]) #log(A_j) for cluster j
        numArr<-cbind(numArr,numerator)
        
        #weight[i, j] = numerator / denomSum #Y
        #weight[i,j] <- log(weight[i,j]) #log(Y)
        weight[i,j]<- numerator #log(A_j)
        #note that M step operates on exp(log(Y))
        
        # weight[i,j] stores p(delta_i,j | theta^(n),x ) - see top of page 138 of march 3 notes
      }
      
      logAMax<-max(numArr)
      
      #subtract the log of the denominator
      #for(j in 1:N) {
      #weight[i,j]<-weight[i,j] - denomSum
      #}
      weight[i,]<-weight[i,]-logAMax - logSumExp(weight[i,] - logAMax) #weight stores log(Y)
      
    }
    
    #M step
    for (j in 1:N){
      productSum <- rep(0, d)
      weightSum <- 0
      weightSumNorm <- 0
      for (i in 1:n){
        productSum <- productSum + xdat[i, ]*exp(weight[i,j])
        weightSumNorm <- weightSumNorm + sum(xdat[i,]) *exp( weight[i,j])
        weightSum <- weightSum + exp(weight[i,j])
      }
      wordProb[j, ] = productSum / weightSumNorm;
      clusterProb[j] = weightSum/n;
    }
    
    #add small constant to wordProb and re-normalize
    wordProb <- wordProb + wordProbConstant
    for (i in 1:N){
      normalizeRow = sum(wordProb[i, ])
      wordProb[i, ] = wordProb[i, ] / normalizeRow
    }
  }
  
  return(list(wordProb=wordProb, clusterProb=clusterProb))
}

processing_docs<-TRUE

if(processing_docs) {
  #For Nips
  #There are 12419 words, so each document is of 12419 dimensions
  #Each data point is a document. There are 1500 documents.
  
  numFeatures<-as.numeric(nrow(vocab))
  docword<-t(docword)
  numDataPoints<-as.numeric(docword[,c(ncol(docword))][1])
  dataFormatted<-matrix(data=0, numDataPoints, numFeatures)
  
  for(line in 1:ncol(docword)) {
    item<-docword[,c(line)]
    docId<-as.numeric(item[1])
    wordId<-as.numeric(item[2])
    wordCount<-as.numeric(item[3])
    
    oldVal<-as.numeric(dataFormatted[docId][wordId])
    if(is.na(oldVal)) oldVal<-0
    newVal<-oldVal+wordCount
    dataFormatted[,c(wordId)][docId]<-newVal
  }
  
  #remove zero columns
  goodCols<-array(0,0,0)
  
  for(col in 1:ncol(dataFormatted)) {
    curCol<-dataFormatted[,c(col)]
    allZeroes<-TRUE
    for(rowElem in 1:length(curCol)) {
      curElem<-curCol[rowElem]
      if(curElem!=0) {
        allZeroes<-FALSE
        break
      }
    }
    
    if(allZeroes==FALSE) {
      goodCols<-cbind(goodCols,col)
    }
  }
}


#MAIN
xdat<-dataFormatted[,c(goodCols)] #to be processed by EM algo
#xdat <- matrix(c(100, 87,5,3,4,5,8,45,40,39),5,2) #for debugging
ret <- em_multinomial(xdat, numTopics, itNum = 15) #30 topics

# Note that every col corresponds to word id in goodCols
#   (see remove zero columns)
#   e.g., col 4 corresponds to 4th elem in goodCols
#     and 4th elem in goodCols refers to corresponding word in vocab
#     col 4 does NOT necessarily refer to corresponding word in vocab


#translation from cols to goodCols to words
tvocab<-t(vocab)
listOfWords<-array("",c(numTopics,topWordsPerTopic))
for(topic in 1:numTopics) {
  topGoodCols<-order(ret$wordProb[topic,], decreasing = T)[1:topWordsPerTopic] #top 10 indices
  listOfWordsRow<-array("",0)
  for(tgc in 1:topGoodCols) {
    index<-goodCols[topGoodCols[tgc]] #goodCols lookup table (translation)
    listOfWordsRow[tgc]<-tvocab[index]
  }
  listOfWordsRow<-na.omit(listOfWordsRow)
  #print(listOfWordsRow)
  listOfWords[topic,]<-listOfWordsRow
}

#
#listWords[i,j] contains j'th most common word in i'th cluster
#NOTE: CLUSTERS ARE IN NO PARTICULAR ORDER
png(filename="Probability of Topics.png", width=1920, height=1080)
barplot(ret$clusterProb, main="Probability of Topics", 
        xlab="Topic", names.arg=c(1:numTopics))
dev.off()

write.csv(listOfWords,file="Most Common Words Per Cluster.csv")