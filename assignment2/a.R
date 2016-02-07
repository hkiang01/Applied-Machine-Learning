wdat<-read.csv('adult.data', header=FALSE)
library(klaR)
library(caret)
bigx<-wdat[c(1,3,5,11,12,13)] # continuous features
bigy<-wdat[,15] # labels
bigy2<-matrix() #blank matrix

#------------------------------------------------------------------

# for loop to replace <=50K with -1 and >50K with 1
counter<-0
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
#10% validation
testdat<-otherdat[test_indices,] # test features 
testlab<-otherlab[test_indices] # test labels
#10% test
valdat<-otherdat[-test_indices,] #validation features
vallab<-otherlab[-test_indices] #validation labels

#------------------------------------------------------------------

Ne<-50 # number epochs
Ns<-300 # number steps
#exp(1) represents e
lambda<-c(exp(1)-3, exp(1)-2, exp(1)-1, 1) # regularization weight
lambdacur<-lambda[1]
alpha<-matrix(data=0, ncol=NCOL(bigx))
beta<-0 # matrix of labels

# choose random starting point
#a0<-0 # choose random set of attributes
#b0<-0 # choose label corresponding to that random set?
#u0<-[a0,b0] 

a<-0.01
b<-50
for (i in 1:Ne){ # for each epoch 
	n<-1/(a*i + b) #c compute step length
	# choose subset of training set for validation
  
	# select a single data item uniformly and at random
	# choose number between 1 and NROW(trlab) or NROW(trdat)
	
	num<-sample(1:NROW(trlab),1)
	ynum<-trlab[num] #yi from notes
	xnum<-trdat[num,] #xi from notes
	gamma<-sum(alpha*xnum) #yk(a*x+b) in notes

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
	
}


