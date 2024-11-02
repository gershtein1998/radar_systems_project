% Parameters
area_size = 10; % 10m x 10m area
radar_position = [area_size / 2, 0]; % Radar at the bottom middle
num_points = 10; % Number of random points per object
time_step = 0.1; % Time increment for simulation (seconds)
total_time = 3; % Total simulation time (seconds)
num_steps = total_time / time_step; % Total number of steps
sim_speedup = 1; % Speed up for animation

epsilon = 0.7; % DBSCAN distance threshold (epsilon value)
minPts = 2; % Minimum number of points for a cluster (minPts)

% Open the files to read the saved points' positions and speeds (without labels and with labels)
fileID_without_labels = fopen('points_movement_without_labels.txt', 'r');
fileID_with_labels = fopen('points_movement_with_labels.txt', 'r');

% Prepare figure for animation
figure;
hold on;
axis([0 area_size 0 area_size]);
title('Clustering Points Based on Location, Speed, and Acceleration using DBSCAN');
xlabel('X (m)');
ylabel('Y (m)');

% Variables to store the number of incorrectly grouped points
incorrect_groupings = 0;

% Store previous speeds for acceleration calculation
previous_speeds = zeros(num_points * 2, 2); % Previous speeds initialized to zero

% Main loop to read and cluster the data for each time step
for step = 1:num_steps
    % Initialize arrays for points
    object_points = zeros(num_points * 2, 2); % All points (object 1 + object 2)
    point_ids = zeros(num_points * 2, 1); % IDs of the points
    point_speeds = zeros(num_points * 2, 1); % Speeds of the points

    % Read data from file (for both objects at this step)
    for point_idx = 1:num_points * 2
        % Read the line from the file: [point_id, x_location, y_location, x_speed, y_speed]
        data = fscanf(fileID_without_labels, '%d %f %f %f %f\n', 5);
        point_ids(point_idx) = data(1); % Point ID
        object_points(point_idx, :) = data(2:3); % X and Y positions
        angle1 = atan(data(2)/data(3));
        angle2 = atan(data(4)/data(5));
        angle3 = angle1-angle2;
        point_speeds(point_idx) = sqrt(data(4)*data(4)+data(5)*data(5))*cos(angle3);%radial speed calculation
    end

    % Calculate acceleration for each point based on previous speeds
    accelerations = (point_speeds - previous_speeds) / time_step; % Calculate acceleration
    previous_speeds = point_speeds; % Update previous speeds for next iteration

    % Create a feature matrix for DBSCAN (combine location, speed, and acceleration)
    feature_matrix = [(object_points-mean(object_points))/std(object_points), (point_speeds-mean(point_speeds))/std(point_speeds), 1*(accelerations-mean(accelerations))/std(accelerations)];

    % Run DBSCAN clustering
    cluster_labels = dbscan(feature_matrix, epsilon, minPts);

    % Clear previous plot and redraw
    cla;
    axis([0 area_size 0 area_size]);

    % Plot radar
    plot(radar_position(1), radar_position(2), 'r^', 'MarkerSize', 10, 'DisplayName', 'Radar');

    % Define colors for clusters
    cluster_colors = lines(max(cluster_labels)); % Generate different colors for clusters

    % Plot the points with their respective cluster colors
    for cluster_idx = 1:max(cluster_labels)
        cluster_points = object_points(cluster_labels == cluster_idx, :);
        plot(cluster_points(:, 1), cluster_points(:, 2), 'o', 'MarkerSize', 5, 'Color', cluster_colors(cluster_idx, :), 'DisplayName', ['Cluster ', num2str(cluster_idx)]);
    end

    legend show;

    % Pause to create animation effect
    pause(time_step / sim_speedup);
    
    % Compare with ground truth labels (read the same points from the labeled file)
    truth = [1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2];
    for point_idx = 1:num_points * 2
        % Format: [object_id, x_location, y_location, x_speed, y_speed]
        labeled_data = fscanf(fileID_with_labels, '%d %f %f %f %f %f\n', 6);
        true_object_id = labeled_data(1); % Get the true object ID (1 or 2)

        % % Check if the clustering matches the true label (1 or 2)
        % if (~mod(point_idx,2) && cluster_labels(point_idx)==2) || (mod(point_idx,2) && cluster_labels(point_idx)==1 || cluster_labels(point_idx)>2 || cluster_labels(point_idx)<0)
        %     incorrect_groupings = incorrect_groupings + 1;
        % end
        if cluster_labels(point_idx) ~= truth(point_idx)
            incorrect_groupings = incorrect_groupings + 1;
        end
    end
end

% Calculate and display the percentage of points that were grouped wrongly
total_points = num_points * 2 * num_steps; % Total points processed
wrongly_grouped_percentage = (incorrect_groupings / total_points) * 100;
disp(['distance, speed and acceloration based Percentage of wrongly grouped points: ', num2str(wrongly_grouped_percentage), '%']);

% Close the files
fclose(fileID_without_labels);
fclose(fileID_with_labels);
hold off;
