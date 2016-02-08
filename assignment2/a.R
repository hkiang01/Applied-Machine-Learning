
accuracyfunc <- function(dat, lab, alpha, beta) {
  # compute accuracy on dat set
  # dat has features, lab has labels
  valtest<-matrix(data=0, nrow=50) # predictions for this epoch
  for(m in 1:50) { #for each data point in data
    #uniformly pick at random one validation point
    dp<-sample(1:NROW(lab),1)
    # yi = sign(t(alpha)*xi+beta)
    xi<-dat[dp,] # the validation row
    prediction<-sign(sum(alpha*xi)) # 1 or -1 from generated model
    
    # compare prediction with respective vllab entry
    if(prediction == lab[dp]) { # good prediction
      valtest[m]<-1
    }
    else { #bad prediction
      valtest[m]<-0
    }
  } # dp
  gotright<-sum(valtest) # number of good predictions
  acc<-gotright/(NROW(valtest))
  return(acc)
}


wdat<-read.csv('adult.data', header=FALSE)
library(klaR)
library(caret)
bigx<-wdat[c(1,3,5,11,12,13)] # continuous features

mycolmeans<-colMeans(bigx, na.rm = FALSE, dims = 1)

#mean-center data and scale by attriibute std dev
#for(f in 1:NCOL(bigx)) { #for every feature
  mymean<-sapply(bigx,mean,na.rm=FALSE)
  mysd<-sapply(bigx,sd,na.rm=FALSE)
  myoffsets<-t(t(bigx)-mymean)
  myscales<-t(t(myoffsets)/mysd)
  bigx<-myscales
#   for(row in 1:NROW(bigx)) {
#     old<-bigx[row, f]
#     old<-old-mycolmeans[f]
#     old<-old/mysd
#     bigx[row, f]<-old
#   }
#}


bigy<-wdat[,15] # labels
bigy2<-matrix() #blank matrix

#------------------------------------------------------------------

# for loop to replace <=50K with -1 and >50K with 1
counter<-1
for(i in bigy) {
  #if(identical(j, i)) {
  if(identical(" <=50K", i)) {
    bigy2[counter]<- -1
  }
  else {
    bigy2[counter]<- 1
  }
  counter<-counter+1
}

tr_indices<-createDataPartition(y=bigy2, p=.8, list=FALSE)
#80% training
trdat<-bigx[tr_indices,] # training features
trlab<-bigy2[tr_indices] #training labels
#20% other
otherdat<-bigx[-tr_indices,]
otherlab<-bigy2[-tr_indices]
test_indices<-createDataPartition(y=otherlab, p=.5, list=FALSE)
#10% test
testdat<-otherdat[test_indices,] # test features 
testlab<-otherlab[test_indices] # test labels
#10% validation
valdat<-otherdat[-test_indices,] #validation features
vallab<-otherlab[-test_indices] #validation labels

#------------------------------------------------------------------

Ne<-50 # number epochs
Ns<-300 # number steps
#Ns<-1
a<-0.01
b<-50
#exp(1) represents e
#lambda<-c(exp(1)-3, exp(1)-2, exp(1)-1, 1) # regularization weight
#lambda<-c(0.001, 0.01, 0.1, 1) # regularization weight
lambda<-c(0.005, 0.0075, 0.05, 0.075) # regularization weight
lambdaaccuracies<-matrix(data=0, ncol=NROW(lambda))

# the meat.
for(l in 1:NROW(lambda)) { # for each lambda
  #l<-1
  lambdacur<-lambda[l]
  alpha<-matrix(data=0, ncol=NCOL(bigx))
  beta<-0 # matrix of labels
  
  accuracies<-matrix(data=0,ncol=Ne) #on validation for each epoch
  yplotaccuracies<-matrix(data=0, ncol=((Ne*Ns))) # for acc val 30 steps
  xplotaccuracies<-matrix(data=0, ncol=((Ne*Ns))) # for acc val 30 steps
  xplot<-matrix(data=0, ncol=(Ne*Ns)) # for acc val every step in a given epoch
  yplot<-matrix(data=0, ncol=(Ne*Ns)) # for acc val every step in a given epoch
  pac<-1

  for (i in 1:Ne){ # for each epoch
    for (j in 1:Ns){ # for each step
    	n<-1/(a*i + b) #c compute step length
    	# choose subset of training set for validation
    	
    	num<-sample(1:NROW(trlab),1)
    	ynum<-trlab[num] #yi from notes
    	xnum<-trdat[num,] #xi from notes
    	gamma<-sum(alpha*xnum) + beta #yk(a*x+b) in notes
    
    	# update rule
    	if(ynum*gamma >= 1) {
    	  # first case
    	  # alpha(n+1) = alpha - n(lamda*alpha)
    	  temp<-lambdacur*alpha
    	  temp2<-n*temp
    	  alpha<-alpha-temp2
    	  
    	  # preserve beta
    	  beta<-beta
    	}
    	else {
        # otherwise case
        # alpha(n+1) = alpha - n(lamda*alpha - yk*x)
        first<-lambdacur*alpha
        second<-ynum*xnum
        temp<-first-second
        temp2<-n*temp
        alpha<-alpha-temp2
        
        # beta(n+1) = beta -n(-yk)
        beta<-beta-n*(-ynum)
    	}
  	
    	# compute accuracy of current classifier on set held out on training data
    	# for the epoch every 30 steps
    	if(j%%30==0) {
    	  curacc<-accuracyfunc(trdat, trlab, alpha, beta)
    	  yplotaccuracies[i*Ns+j]<-curacc
    	  xplotaccuracies[i*Ns+j]<-i*Ns+j
    	}
    	
    	curacc<-accuracyfunc(trdat, trlab, alpha, beta)
    	yplot[i*Ns+j]<-curacc
    	xplot[i*Ns+j]<-i*Ns+j
    	
    } #step
    
    # compute accuracy on training set (to get accuracy of model)
    # trdat has training features, trlab has training labels
    # alpha has the features weights, beta has the bias
    curacc<-accuracyfunc(trdat, trlab, alpha, beta)
    accuracies[l]<-curacc
    
    #plot(xplot, yplot, 	xlab="steps", ylab="accuracy", type='p')
    
  } # epoch
  
  # generate plot for plotaccuracies (30 steps per point)
  # x: number of steps
  # y: accuracy (0 to 1)
  plot(xplotaccuracies,yplotaccuracies,xlab="steps", ylab="accuracy",type='p')
  title(main = paste("lambda = ", lambda[l]))
  
  # code to test lambdas on validation
  curlambdaacc<-accuracyfunc(valdat, vallab, alpha, beta)
  lambdaaccuracies[l]<-curlambdaacc
  
} # lambda
# report best lambda

plot(lambda, lambdaaccuracies)
