library('caret') #createDataPartition
library('stats') #lm
library('glmnet')
library('boot')

dataRaw = read.csv("default of credit card clients.csv", header = TRUE)
data = dataRaw[-1, -1]

xdata = as.matrix(data[,c(1:23)])
ydata = as.matrix(data[,c(24)])
class(xdata) <- "numeric"
class(ydata) <- "numeric"

n = nrow(xdata)

train = createDataPartition(ydata, 1, 0.8, list = FALSE)

xdataTrain = xdata[train, ]
xdataTest = xdata[-train, ]

ydataTrain = ydata[train]
ydataTest = ydata[-train]

regData<-data.frame(ind=xdataTrain, dep=ydataTrain)
logicFit <-glm(dep~xdataTrain,data=regData, family=binomial(link=logit))

lassoFit <- cv.glmnet(xdataTrain, ydataTrain, alpha = 1, family="binomial")
ridgeFit <- cv.glmnet(xdataTrain, ydataTrain, alpha = 0, family="binomial")

elasticAcc <- rep(0, 9)
elasticAccTr <- rep(0,9)
elasticCoef <- rep(0, 9)
for (i in 1:9){
  elasticFit <- cv.glmnet(xdataTrain, ydataTrain, alpha = 0.1*i, family="binomial")
  elasticResults <- (predict(elasticFit, xdataTest, s = elasticFit$lambda.min) >= 0.5 ) *1
  elasticAcc[i] <- sum(elasticResults == ydataTest) / length(ydataTest)
  
  elasticResults <- (predict(elasticFit, xdataTrain, s = elasticFit$lambda.min) >= 0.5 ) *1
  elasticAccTr[i] <- sum(elasticResults == ydataTrain) / length(ydataTrain)
  
  elasticCoef[i] <- elasticFit$lambda.min
}

betahatols = coef(logicFit)
yhatols = cbind(rep(1, n - length(ydataTrain)), as.matrix(xdataTest)) %*% betahatols
linResults <- (inv.logit(yhatols) >= 0.5) * 1
linResultsTr <- (unname(logicFit$fitted.values) >= 0.5) * 1


lassoResults <- (predict(lassoFit, xdataTest, s = lassoFit$lambda.min) >= 0.5 ) *1
ridgeResults <- (predict(ridgeFit, xdataTest, s = ridgeFit$lambda.min) >= 0.5 ) *1

lassoResultsTr <- (predict(lassoFit, xdataTrain, s = lassoFit$lambda.min) >= 0.5 ) *1
ridgeResultsTr <- (predict(ridgeFit, xdataTrain, s = ridgeFit$lambda.min) >= 0.5 ) *1


linAccuracy <- sum(linResults == ydataTest) / length(ydataTest)
lassoAcc <- sum(lassoResults == ydataTest) / length(ydataTest)
ridgeAcc <- sum(ridgeResults == ydataTest) / length(ydataTest)

linAccuracyTr <- sum(linResultsTr == ydataTrain) / length(ydataTrain)
lassoAccTr <- sum(lassoResultsTr == ydataTrain) / length(ydataTrain)
ridgeAccTr <- sum(ridgeResultsTr == ydataTrain) / length(ydataTrain)

