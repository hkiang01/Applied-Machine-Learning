%score = csvread('nipals_score.csv');
%load = csvread('nipals_load.csv');
%label = csvread('nipals_label.csv');

m = csvread('m_score.csv');
b = csvread('b_score.csv');

% separate into benign/malignant

xm = m(:,1);
ym = m(:,2);
zm = m(:,3);

xb = b(:,1);
yb = b(:,2);
zb = b(:,3);

figure(1);
hold on;
hm = scatter3(xm,ym,zm,[],'r');
hb = scatter3(xb,yb,zb,[],'g');
hold off;
xlabel('PCA 1');
ylabel('PCA 2');
zlabel('PCA 3');
