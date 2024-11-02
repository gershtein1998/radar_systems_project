% Sample 4D data
X = rand(15,5); % 100 points in 4D space

% Set the parameters
epsilon = 0.5;  % Neighborhood distance (epsilon)
minPts = 2;     % Minimum number of points required to form a cluster

% Apply DBSCAN
labels = dbscan(X, epsilon, minPts);
disp(labels)


