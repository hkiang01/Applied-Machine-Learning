library('caret') #createDataPartition
library('stats') #lm

dataRaw = read.csv("default of credit card clients.csv", header = TRUE)
data = dataRaw[-1, -1]

xdata = as.matrix(data[,c(1:23)])
ydata = as.matrix(data[,c(24)])
class(xdata) <- "numeric"
class(ydata) <- "numeric"

regData<-data.frame(ind=xdata, dep=ydata)
logicFit <-glm(dep~xdata,data=regData, family=binomial(link=logit))

results <- (unname(logicFit$fitted.values) >= 0.5) * 1
accuracy <- sum(results == ydata) / length(ydata)