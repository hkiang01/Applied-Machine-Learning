#There are 12419 words, so each document is of 12419 dimensions
#Each data point is a document. There are 1500 documents.

setwd('/Users/harry/projects/aml/assignment5/')
vocab<-read.table('vocab.nips.txt') #vocab.[asdf].txt
docword<-read.table('docword.nips.txt', skip=3) #docword.[asdf].txt

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

xdat<-dataFormatted[,c(goodCols)] #to be processed by EM algo



