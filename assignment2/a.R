
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

# variables in global scope for debugging

Ne<-50 # number epochs
Ns<-300 # number steps
#Ns<-1
a<-0.01
b<-50
#exp(1) represents e
lambda<-c(exp(1)-3, exp(1)-2, exp(1)-1, 1) # regularization weight
lambdaaccuracies<-matrix(data=0, ncol=NROW(lambda))
lc<-0 #lambdacounter

lambdacur<-0
alphas<-matrix(data=0, nrow=NROW(lambda), ncol=NCOL(bigx))
betas<-matrix(data=0, ncol=NROW(lambda))
accuracies_matrix<-matrix(data=0, nrow=NROW(lambda), ncol=((Ne*Ns)/30)) #row per lambda, cols accuracies over time
yplotaccuracies_matrix<-matrix(data=0, nrow=NROW(lambda), ncol=((Ne*Ns)/30)) #row per lambda, cols accuracies over time
xplotaccuracies_matrix<-matrix(data=0, nrow=NROW(lambda), ncol=((Ne*Ns)/30)) #row per lambda, cols accuracies over time
num<-1
ynum<-trlab[num]
xnum<-trdat[num,]
alpha<-matrix(data=0, ncol=NCOL(bigx))
beta<-0 # matrix of labels
gamma<-sum(alpha*xnum) + beta
temp<-0
temp2<-0
first<-0
second<-0
curacc<-0

# the meat.
for(l in 1:NROW(lambda)) { # for each lambda
#  l<-1
  lambdacur<-lambda[l]
  alpha<-matrix(data=0, ncol=NCOL(bigx))
  beta<-0 # matrix of labels
  
  accuracies<-matrix(data=0,ncol=Ne) #on validation for each epoch
  yplotaccuracies<-matrix(data=0, ncol=((Ne*Ns)/30)) # for acc val 30 steps
  xplotaccuracies<-matrix(data=0, ncol=((Ne*Ns)/30)) # for acc val 30 steps
  pac<-1
  
  # choose random starting point
  #a0<-0 # choose random set of attributes
  #b0<-0 # choose label corresponding to that random set?
  #u0<-[a0,b0] 
  

  for (i in 1:Ne){ # for each epoch
#    i<-1
    for (j in 1:Ns){ # for each step
    	n<-1/(a*i + b) #c compute step length
    	# choose subset of training set for validation
      
    	# select a single data item uniformly and at random
    	# choose number between 1 and NROW(trlab) or NROW(trdat)
    	
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
    	  yplotaccuracies[pac]<-curacc
    	  xplotaccuracies[pac]<-j
    	  pac<-pac+1
    	}
    	
    } #step
    
    # compute accuracy on training set (to get accuracy of model)
    # trdat has training features, trlab has training labels
    # alpha has the features weights, beta has the bias
    curacc<-accuracyfunc(trdat, trlab, alpha, beta)
    accuracies[l]<-curacc
    
  } # epoch
  
  # generate plot for plotaccuracies (30 steps per point)
  # x: number of steps
  # y: accuracy (0 to 1)
  plot(xplotaccuracies,yplotaccuracies)
  title(main = paste("lambda = ", lambda[l]))

  
  # code to test lambdas on validation
  curlambdaacc<-accuracyfunc(valdat, vallab, alpha, beta)
  lambdaaccuracies[l]<-curlambdaacc
    
  # store into global env
  #alphas[lc,]<-alpha
  #betas[lc]<-beta
  #accuracies_matrix[lc,]<-accuracies
 # yplotaccuracies_matrix[lc,]<-yplotaccuracies
  #xplotaccuracies_matrix[lc,]<-xplotaccuracies
  
  lc<-lc+1
} # lambda
# report best lambda

