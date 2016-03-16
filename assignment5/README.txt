To run project:

R files:
Open RStudio.
setwd('/directory/of/project')
source('project_file.R')

Part 1: Topic Classification
Source code: "em_multinomial.R"
	Libraries: None
	Run source code em_multinomial.R
	Note input parameters near top of source code (lines 1-6)

	Results (global vars):
	ret$wordProb: probability of each word for every cluster
					N by d, rows are clusters, cols are individual word probs
	ret$clusterProb: probability of each cluster, length N array
	listOfWords: for each cluster, top 10 words
				 N by d, rows are clusters, cols are top words in decreasing order

	Files:
		"Probability of Topics.png": probability of each topic in no particular order
		"Most Common Words Per Cluster.csv": Most common words per cluster in decreasing order

	Note: to see global var results, please highlight all lines (select all) and click "Run" in RStudio

Part 2: Image Segmentation
Source code: "em_norm.R"
	Libraries: "jpeg", "ForeCA"
	Install missing packages from Tools → Install Packages...
	Run source code em_norm.R
	Note input parameters near top of source code (lines 3-6)


REPORT FILES (there are 2)
- HW5Report.pdf
- PolarLightsAnalysis.pdf

IMAGE FILES
- see "image_results" directory

░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░░░▄▄▄▄▄▄▄░░░░░░░░░
░░░░░░░░░▄▀▀▀░░░░░░░▀▄░░░░░░░
░░░░░░░▄▀░░░░░░░░░░░░▀▄░░░░░░
░░░░░░▄▀░░░░░░░░░░▄▀▀▄▀▄░░░░░
░░░░▄▀░░░░░░░░░░▄▀░░██▄▀▄░░░░
░░░▄▀░░▄▀▀▀▄░░░░█░░░▀▀░█▀▄░░░
░░░█░░█▄▄░░░█░░░▀▄░░░░░▐░█░░░
░░▐▌░░█▀▀░░▄▀░░░░░▀▄▄▄▄▀░░█░░
░░▐▌░░█░░░▄▀░░░░░░░░░░░░░░█░░
░░▐▌░░░▀▀▀░░░░░░░░░░░░░░░░▐▌░
░░▐▌░░░░░░░░░░░░░░░▄░░░░░░▐▌░
░░▐▌░░░░░░░░░▄░░░░░█░░░░░░▐▌░
░░░█░░░░░░░░░▀█▄░░▄█░░░░░░▐▌░
░░░▐▌░░░░░░░░░░▀▀▀▀░░░░░░░▐▌░
░░░░█░░░░░░░░░░░░░░░░░░░░░█░░
░░░░▐▌▀▄░░░░░░░░░░░░░░░░░▐▌░░
░░░░░█░░▀░░░░░░░░░░░░░░░░▀░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

                  Herpderp.