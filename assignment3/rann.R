library(RANN)

# Notice that, in principle, you could build a classifier for each pair by 
# matching the first attribute vector to this dataset, matching the second 
# attribute vector to the dataset, then seeing if the two names are the same. 
# Doing this in practice presents challenges, because there is so much data. 
# Use an approximate nearest neighbors package (I favor FLANN or RANN) to 
# build such a matcher.

wdat1<-read.table('pubfig_dev_50000_pairs.txt', sep='\t')

olddat1<-wdat1[2:74]
olddat2<-wdat1[75:147]

wdat2<-read.table('pubfig_attributes.txt', sep='\t')
newdat<-wdat2[3:75]

nn1<-nn2(newdat, olddat1, k = 1)#k=min(10, nrow(wdat)), treetype = c("kd"))
nn2<-nn2(newdat, olddat2, k = 1)#k=min(10, nrow(wdat)), treetype = c("kd"))

idx1<-nn1$nn.idx # nearest neightbor indices
dists1<-nn1$nn.dists # near neighbor Euclidean distances
idx2<-nn2$nn.idx # nearest neightbor indices
dists2<-nn2$nn.dists # near neighbor Euclidean distances

pairMatch<-wdat2[idx1, 1] == wdat2[idx2, 1]
result<-pairMatch == wdat1[,1]

accuracy<-sum(result)/length(result)
