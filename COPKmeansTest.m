% COPKmeansTest.m
%
% Kemal Tugrul Yesilbek
% May 2015
% 

%% Initialize
close all;
clear all;
clc;
rng('shuffle');

%% Options
numM = 25;
numC = 25;
K = 4;
maxIter = 550;

%% Load data
tmp = load('feats.mat');
feats = tmp.feats;

tmp = load('labels.mat');
labels = tmp.labels;


%% Generate constraints

% Must Links
M = [];
uniqueLabels = unique(labels);
for i = 1 : numM
	
	% Select a class
	classToLink = randi( length(uniqueLabels), 1 );
	
	% Select instances from that class
	classIdx = find( labels == classToLink );
	toLink = classIdx( randperm(length(classIdx), 2) );
	
	% Link them
	M = [M ; [toLink(1), toLink(2)] ];
end

% Cannot Links
C = [];
for i = 1 : numC
	
	% Select a class
	classToLinks = uniqueLabels( randperm( length(unique(labels)), 2 ) );
	
 	% Select instances from that class
 	classIdxA = find( labels == classToLinks(1) );
	classIdxB = find( labels == classToLinks(2) );

	toLinkA = classIdxA(randperm(length(classIdxA), 1));
	toLinkB = classIdxB(randperm(length(classIdxB), 1));
	
	% Link them
	C = [C ; [toLinkA, toLinkB] ];
end


%% Apply Constraint Clustering
[clusters, isFailed] = COPKmeans(feats, K, M, C, maxIter);

if(isFailed)
	fprintf('Clustering failed...\n');
	return;
else
	fprintf('Clustering Successful...\n');
end

%% Visualize Clusters
figure; hold on;
colors = lines(length(clusters));
for clusterID = 1 : length(clusters);

	clusterIdx = clusters{clusterID}.idx;
	
	for i = 1 : length(clusterIdx)
		pnt = clusterIdx(i);
		
		c = colors(clusterID,:);
		plot( feats(pnt,1), feats(pnt,2), 'Color', c, 'Marker', 'o' );
	end
	
end
grid on; grid minor;
title('CKmeans Clusters');


%% Apply K-Means Clustering
[clustersIDs] = kmeans(feats, K);

%% Visualize Clusters
figure; hold on;
colors = lines(K);
for pnt = 1 : length(clustersIDs)
	c = colors( clustersIDs(pnt) ,:);
	plot( feats(pnt,1), feats(pnt,2), 'Color', c, 'Marker', 'o' );
end
grid on; grid minor;
title('Kmeans Clusters');

	
%% Visualize data
figure; hold on;
for pnt = 1 : length(labels)
	if(labels(pnt) == 1)
		plot( feats(pnt,1), feats(pnt,2), 'co' );
	elseif(labels(pnt) == 2)
		plot( feats(pnt,1), feats(pnt,2), 'bo' );
	elseif(labels(pnt) == 3)
		plot( feats(pnt,1), feats(pnt,2), 'mo' );
	elseif(labels(pnt) == 4)
		plot( feats(pnt,1), feats(pnt,2), 'ko' );
	end
end

for m = 1 : size(M,1)
	fm = M(m,:);
	line( [feats(fm(1),1) feats(fm(2),1)], [feats(fm(1),2), feats(fm(2),2)], 'color', 'g' );
end

for c = 1 : size(C,1)
	fc = C(c,:);
	line( [feats(fc(1),1) feats(fc(2),1)], [feats(fc(1),2), feats(fc(2),2)], 'color', 'r' );
end

grid on; 
grid minor;
title('Original Distribution');


























