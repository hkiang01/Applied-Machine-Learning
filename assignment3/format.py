#!/usr/bin/python

with open('pubfig_kaggle_eval_results_backup.txt') as fp, open ('pubfig_kaggle_eval_results.txt', 'w') as output_file:
	fp.readline()
	for line in fp:
		newline = ""
		arr = line.split(',')
		newline = str(int(arr[0]) - 1) + "," + arr[1]
		output_file.write(newline)
