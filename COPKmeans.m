% COPKmeans.m
% Kemal Tugrul Yesilbek
%
% Implementation of COP-Kmeans by Wagsta et.al.
%
% Input:
% data  : Data points with m x n (m:#data, n: #dim)
% K     : # of clusters
% M     : Must-link constraints M x 2
% C     : Cannot-link constraints C x 2
%
% Output:
% clusterMeans : Medians of clusters
% assignments  : Assigned labels of data points

function [ clusters, isFailed ] = COPKmeans(data, K, M, C, maxIter )

% Generic Vars
m = size(data,1);
n = size(data,2);

% Initialize clusters
clusters = initialize(data, K);

% Assign data points to nearest cluster that doesnt violate any constraints
iterNo = 0;
deviation = 1;
prevClusters = clusters;
while deviation > 0.001 && iterNo < maxIter
    
        % Assign datapoints to clusters
       [clusters, isPass] = COPcluster(data, clusters, K, M, C);
       
       % Check constraints
       if(~isPass)
           % Clustering failed
           clusters = NaN;
           isFailed = true;
           fprintf('Constraints are not satisfied!!!\n');
           return;
       end
       
       % Recalculate cluster centers
       for k = 1:K
           sum = zeros(1,n);
           
           for j = 1:length(clusters{k}.idx)
                sum = sum + data(clusters{k}.idx(j),:);
           end
           
           clusters{k}.center = sum / length(clusters{k}.idx);
       end
       
       % Calculate the deviation in cluster centers
       deviation = 0;
       for i = 1:K
           deviation = deviation + (pdist([clusters{i}.center;prevClusters{i}.center]));
       end
       prevClusters = clusters;
       iterNo = iterNo + 1;
end


if(iterNo == maxIter)
    fprintf('Maximum # iteration reached...\n');
end

isFailed = false;

end

function [clusters, isPass] = COPcluster(data, clusters, K, M, C)
    
    % Generic Vars
    m = size(data,1);
    n = size(data,2);
    
    prevClusters = clusters;
    
    % Reset assignments
    for k = 1:K
        clusters{k}.idx = []; 
    end
    
    % Cluster every data points
    for i = 1:m
        
        % Sort clusters by their distances
        dist = zeros(K,2);
        for k = 1:K
            dist(k,1) = pdist([data(i,:); clusters{k}.center]);
            dist(k,2) = k;
        end
        dist = sortrows(dist);
        sortedClusters = dist(:,2);
        
        
        % Try clusters
        for k = 1:K 
            
            if(isViolateConstraints(i, prevClusters{sortedClusters(k)}.idx, M, C))
                if(k == K)
                    isPass = false;
                    return;
                else
                    continue;
                end
            else
                isPass = true;
                clusters{sortedClusters(k)}.idx = [clusters{sortedClusters(k)}.idx i];
                break;
            end
            
        end
        
    end

end


function clusters = initialize(data, K)
    % Generic Vars
    m = size(data,1);
    n = size(data,2);

    % Initialize cluster centers
    initialIDX = randperm(m,K);

    for i = 1:K
        clusters{i}.center = data(initialIDX(i),:);
        clusters{i}.idx = [];
    end
    
    % Cluster data points
    for i = 1 : m
        minDist = +Inf;
        minDistCluster = 1;
        for k = 1 : K
            dist = pdist([data(i,:);clusters{k}.center]);
            
            if(dist < minDist)
                minDist = dist;
                minDistCluster = k;
            end
        end
        
        clusters{minDistCluster}.idx = [clusters{minDistCluster}.idx i];
    end
end

function isFail = isViolateConstraints(dataPointIdx, clusterIdx, M, C)
    
    % Find must-links for data point
    if(~isempty(M))
        ML = find(M(:,1) == dataPointIdx);
        for i = 1:length(ML)
           if( isempty(find(M(ML(i),2) == clusterIdx)) )
               isFail = true;
               return;
           end
        end
    end
    
    % Find cannot-link for data point
    if(~isempty(C))
        CL = find(C(:,1) == dataPointIdx);
        for i = 1:length(CL)
           if(~isempty(find(C(CL(i),2) == clusterIdx)) )
               isFail = true;
               return;
           end
        end
    end
    
    % All constraints satistied
    isFail = false;
    return;
    
end



















