%score = csvread('nipals_score.csv');
%load = csvread('nipals_load.csv');
%label = csvread('nipals_label.csv');

xma = csvread('breast_results/xma.csv');
yma = csvread('breast_results/yma.csv');
zma = csvread('breast_results/zma.csv');
xba = csvread('breast_results/xba.csv');
yba = csvread('breast_results/yba.csv');
zba = csvread('breast_results/zba.csv');

xmb = csvread('breast_results/xmb.csv');
ymb = csvread('breast_results/ymb.csv');
zmb = csvread('breast_results/zmb.csv');
xbb = csvread('breast_results/xbb.csv');
ybb = csvread('breast_results/ybb.csv');
zbb = csvread('breast_results/zbb.csv');

% separate into benign/malignant

figure(1);
hold on;
hma = scatter3(xma,yma,zma,[],'r');
hba = scatter3(xba,yba,zba,[],'g');
hold off;
title('Breast Cancer Data Using PCA');
xlabel('PCA 1');
ylabel('PCA 2');
zlabel('PCA 3');

figure(2);
hold on;
hmb = scatter3(xmb,ymb,zmb,[],'r');
hbb = scatter3(xbb,ybb,zbb,[],'g');
hold off;
title('Breast Cancer Data Using PLS1');
xlabel('PLS 1');
ylabel('PLS 2');
zlabel('PLS 3');
