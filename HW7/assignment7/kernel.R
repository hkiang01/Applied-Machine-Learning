# You will use kernel functions to build various linear regressions predicting the 
# annual mean of the minimum temperature as a function of position 
# (i.e. you'll use one annual mean of minimum temperature for 2000, 2001, 2002, 2003,
# and 2004 at each weather station).

setwd('/Users/annlinsheih/Dev/aml/assignment7') # annlin's
# source('~/Dev/aml/assignment7/kernel.R')
location_dat<-read.table('Locations.txt', header=TRUE)
temp_dat<-read.table('Oregon_Met_Data.txt', header=TRUE)

utm_dat<-data.frame(location_dat['East_UTM'],location_dat['North_UTM'])

# Use a kernel method (section 9.1.1) to smooth this data, and predict 
# the average annual temperature at each point on a 100x100 grid spanning
# the weather stations. You should use each data point as a base point, 
# and you should search over a range of at least six scales, using 
# cross-validation to choose the scale. Use a Gaussian kernel. Plot 
# your prediction as an image. Compare to the Kriging result that you
# can find in figure 4 here.


