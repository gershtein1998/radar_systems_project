results1 = [];
results2 = [];
results3 = [];

for i=1:10
    % First Simulation: Save movement, speed, and radial speed of points with noise
    close all;
    % Parameters
    scenario_index = 3;%1 or 2 or 3
    area_size = 10; % 10m x 10m area
    radar_position = [area_size / 2, 0]; % Radar at the bottom middle
    radius = 0.5; % Objects' radius
    num_points = 10; % Number of random points per object
    location_noise_std = 0.02; % Standard deviation of noise for position
    speed_noise_std = 0.01; % Standard deviation of noise for speed
    
    % Simulation parameters
    time_step = 0.1; % Time increment for simulation (seconds)
    total_time = 3; % Total simulation time (seconds)
    num_steps = total_time / time_step; % Total number of steps
    sim_speedup = 100;
    
    if scenario_index == 1
        % Fixed object centers
        object1_center = [4.6, 2]; % Center of object 1
        object2_center = [5.4, 2.5]; % Center of object 2
        
        % Define acceleration and initial speed for each object
        acceleration1 = [0.0, 0.0]; % Acceleration for object 1 (x, y)
        acceleration2 = [0.0, 1.0]; % Acceleration for object 2 (x, y)
        initial_speed1 = [0.0, 2.0]; % Initial speed for object 1 (x, y)
        initial_speed2 = [0.0, 1.0]; % Initial speed for object 2 (x, y)
    elseif scenario_index == 2
        % Fixed object centers
        object1_center = [8.7, 2]; % Center of object 1
        object2_center = [9.3, 2.5]; % Center of object 2
    
        % Define acceleration and initial speed for each object
        acceleration1 = [0.0, 0.0]; % Acceleration for object 1 (x, y)
        acceleration2 = [-1/sqrt(2), 1/sqrt(2)]; % Acceleration for object 2 (x, y)
        initial_speed1 = 2*[-1/sqrt(2), 1/sqrt(2)]; % Initial speed for object 1 (x, y)
        initial_speed2 = [-1/sqrt(2), 1/sqrt(2)]; % Initial speed for object 2 (x, y)
    else
        % Fixed object centers
        object1_center = [8.7, 4.6]; % Center of object 1
        object2_center = [9.3, 5.4]; % Center of object 2
    
        % Define acceleration and initial speed for each object
        acceleration1 = [0.0, 0.0]; % Acceleration for object 1 (x, y)
        acceleration2 = [-1.0, 0.0]; % Acceleration for object 2 (x, y)
        initial_speed1 = [-2.0, 0.0]; % Initial speed for object 1 (x, y)
        initial_speed2 = [-1.0, 0.0]; % Initial speed for object 2 (x, y)
    end
    % Generate random points for each object using a normal distribution (once)
    theta1 = 2 * pi * rand(num_points, 1); % Random angles
    r1 = abs(normrnd(0, radius / 2, num_points, 1)); % Normally distributed radii
    r1(r1 > radius) = radius; % Ensure points do not exceed the object radius
    relative_object1_points = [r1 .* cos(theta1), r1 .* sin(theta1)]; % Relative points for object 1
    
    theta2 = 2 * pi * rand(num_points, 1);
    r2 = abs(normrnd(0, radius / 2, num_points, 1)); % Normally distributed radii
    r2(r2 > radius) = radius; % Ensure points do not exceed the object radius
    relative_object2_points = [r2 .* cos(theta2), r2 .* sin(theta2)]; % Relative points for object 2
    
    % Initialize positions and speeds
    position1 = object1_center;
    position2 = object2_center;
    speed1 = initial_speed1;
    speed2 = initial_speed2;
    
    % Prepare file to save points' positions, speeds, and object ID (with labels)
    fileID_with_labels = fopen('points_movement_with_labels.txt', 'w');
    % Prepare second file to save points' positions and speeds (without labels)
    fileID_without_labels = fopen('points_movement_without_labels.txt', 'w');
    
    % Prepare figure for animation
    figure;
    hold on;
    axis([0 area_size 0 area_size]);
    title('Simulation of Moving Objects');
    xlabel('X (m)');
    ylabel('Y (m)');
    
    % Plot radar
    plot(radar_position(1), radar_position(2), 'r^', 'MarkerSize', 10, 'DisplayName', 'Radar');
    
    % Main simulation loop
    for step = 1:num_steps
        % Update speeds based on acceleration
        speed1 = speed1 + acceleration1 * time_step;
        speed2 = speed2 + acceleration2 * time_step;
        
        % Update positions based on current speed
        position1 = position1 + speed1 * time_step;
        position2 = position2 + speed2 * time_step;
    
        % Add position to relative points
        object1_points = relative_object1_points + position1; % Broadcasting position1 (1x2)
        object2_points = relative_object2_points + position2; % Broadcasting position2 (1x2)
    
        % Add Gaussian noise to positions and speeds
        object1_points = object1_points + normrnd(0, location_noise_std, size(object1_points));
        object2_points = object2_points + normrnd(0, location_noise_std, size(object2_points));
        speed1 = speed1 + normrnd(0, speed_noise_std, size(speed1));
        speed2 = speed2 + normrnd(0, speed_noise_std, size(speed2));
    
        % Save data to files (with and without labels)
        for point_idx = 1:num_points
            % Assign point IDs: points 1-10 for object 1, points 11-20 for object 2
            point_id1 = point_idx; % ID for object 1 points
            point_id2 = num_points + point_idx; % ID for object 2 points
    
            % Save object 1 data: [point_id, object_id, x_location, y_location, x_speed, y_speed]
            fprintf(fileID_with_labels, '%d %d %f %f %f %f\n', point_id1, 1, object1_points(point_idx, 1), object1_points(point_idx, 2), speed1(1), speed1(2));
            fprintf(fileID_without_labels, '%d %f %f %f %f\n', point_id1, object1_points(point_idx, 1), object1_points(point_idx, 2), speed1(1), speed1(2));
    
            % Save object 2 data: [point_id, object_id, x_location, y_location, x_speed, y_speed]
            fprintf(fileID_with_labels, '%d %d %f %f %f %f\n', point_id2, 2, object2_points(point_idx, 1), object2_points(point_idx, 2), speed2(1), speed2(2));
            fprintf(fileID_without_labels, '%d %f %f %f %f\n', point_id2, object2_points(point_idx, 1), object2_points(point_idx, 2), speed2(1), speed2(2));
        end
    
        % Clear previous plot and redraw
        cla;
        axis([0 area_size 0 area_size]);
        
        % Plot radar
        plot(radar_position(1), radar_position(2), 'r^', 'MarkerSize', 10, 'DisplayName', 'Radar');
        
        % Plot objects
        plot(object1_points(:, 1), object1_points(:, 2), 'bo', 'MarkerSize', 5, 'DisplayName', 'Object 1');
        plot(object2_points(:, 1), object2_points(:, 2), 'go', 'MarkerSize', 5, 'DisplayName', 'Object 2');
    
        legend show;
        
        % Pause to create animation effect
        pause(time_step / sim_speedup);
    end
    
    % Close files
    fclose(fileID_with_labels);
    fclose(fileID_without_labels);
    hold off;

        % Parameters
    area_size = 10; % 10m x 10m area
    radar_position = [area_size / 2, 0]; % Radar at the bottom middle
    num_points = 10; % Number of random points per object
    time_step = 0.1; % Time increment for simulation (seconds)
    total_time = 3; % Total simulation time (seconds)
    num_steps = total_time / time_step; % Total number of steps
    epsilon = 0.5; % Distance threshold for DBSCAN (similar to distance_threshold)
    minPts = 2; % Minimum number of points to form a cluster in DBSCAN
    
    % Open the files to read the saved points' positions and speeds (without labels and with labels)
    fileID_without_labels = fopen('points_movement_without_labels.txt', 'r');
    fileID_with_labels = fopen('points_movement_with_labels.txt', 'r');
    
    % Prepare figure for animation
    figure;
    hold on;
    axis([0 area_size 0 area_size]);
    title('Clustering Points Using DBSCAN');
    xlabel('X (m)');
    ylabel('Y (m)');
    
    % Variables to store the number of incorrectly grouped points
    incorrect_groupings = 0;
    
    % Main loop to read and cluster the data for each time step
    for step = 1:num_steps
        % Initialize arrays for points
        object_points = zeros(num_points * 2, 2); % All points (object 1 + object 2)
        point_ids = zeros(num_points * 2, 1); % IDs of the points
    
        % Read data from file (for both objects at this step)
        for point_idx = 1:num_points * 2
            % Read the line from the file: [point_id, x_location, y_location, x_speed, y_speed]
            data = fscanf(fileID_without_labels, '%d %f %f %f %f\n', 5);
            point_ids(point_idx) = data(1); % Point ID
            object_points(point_idx, :) = data(2:3); % X and Y positions
        end
    
        % Perform DBSCAN clustering
        cluster_labels = dbscan(object_points, epsilon, minPts);
    
        % Clear previous plot and redraw
        cla;
        axis([0 area_size 0 area_size]);
    
        % Plot radar
        plot(radar_position(1), radar_position(2), 'r^', 'MarkerSize', 10, 'DisplayName', 'Radar');
    
        % Define colors for clusters
        unique_labels = unique(cluster_labels);
        cluster_colors = lines(length(unique_labels)); % Generate different colors for clusters
    
        % Plot the points with their respective cluster colors
        for cluster_idx = 1:length(unique_labels)
            current_label = unique_labels(cluster_idx);
            if current_label == -1
                % Noise points (not part of any cluster) are labeled as -1
                cluster_points = object_points(cluster_labels == current_label, :);
                plot(cluster_points(:, 1), cluster_points(:, 2), 'kx', 'MarkerSize', 5, 'DisplayName', 'Noise');
            else
                cluster_points = object_points(cluster_labels == current_label, :);
                plot(cluster_points(:, 1), cluster_points(:, 2), 'o', 'MarkerSize', 5, 'Color', cluster_colors(cluster_idx, :), 'DisplayName', ['Cluster ', num2str(current_label)]);
            end
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
    disp(['distance based Percentage of wrongly grouped points: ', num2str(wrongly_grouped_percentage), '%']);
    results1(i) = wrongly_grouped_percentage;

    % Close the files
    fclose(fileID_without_labels);
    fclose(fileID_with_labels);
    hold off;

        % Parameters
    area_size = 10; % 10m x 10m area
    radar_position = [area_size / 2, 0]; % Radar at the bottom middle
    num_points = 10; % Number of random points per object
    time_step = 0.1; % Time increment for simulation (seconds)
    total_time = 3; % Total simulation time (seconds)
    num_steps = total_time / time_step; % Total number of steps
    epsilon = 0.4; % Distance threshold for DBSCAN (similar to distance_threshold)
    minPts = 2; % Minimum number of points to form a cluster in DBSCAN
    
    % Open the files to read the saved points' positions and speeds (without labels and with labels)
    fileID_without_labels = fopen('points_movement_without_labels.txt', 'r');
    fileID_with_labels = fopen('points_movement_with_labels.txt', 'r');
    
    % Prepare figure for animation
    figure;
    hold on;
    axis([0 area_size 0 area_size]);
    title('Clustering Points Using DBSCAN (Position and Speed)');
    xlabel('X (m)');
    ylabel('Y (m)');
    
    % Variables to store the number of incorrectly grouped points
    incorrect_groupings = 0;
    
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
    
        % Concatenate positions and speeds for clustering
        position_speed_data = [object_points, point_speeds]; % Combine position and speed into a single array
    
        % Perform DBSCAN clustering
        cluster_labels = dbscan(position_speed_data, epsilon, minPts);
    
        % Clear previous plot and redraw
        cla;
        axis([0 area_size 0 area_size]);
    
        % Plot radar
        plot(radar_position(1), radar_position(2), 'r^', 'MarkerSize', 10, 'DisplayName', 'Radar');
    
        % Define colors for clusters
        unique_labels = unique(cluster_labels);
        cluster_colors = lines(length(unique_labels)); % Generate different colors for clusters
    
        % Plot the points with their respective cluster colors
        for cluster_idx = 1:length(unique_labels)
            current_label = unique_labels(cluster_idx);
            if current_label == -1
                % Noise points (not part of any cluster) are labeled as -1
                cluster_points = object_points(cluster_labels == current_label, :);
                plot(cluster_points(:, 1), cluster_points(:, 2), 'kx', 'MarkerSize', 5, 'DisplayName', 'Noise');
            else
                cluster_points = object_points(cluster_labels == current_label, :);
                plot(cluster_points(:, 1), cluster_points(:, 2), 'o', 'MarkerSize', 5, 'Color', cluster_colors(cluster_idx, :), 'DisplayName', ['Cluster ', num2str(current_label)]);
            end
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
    disp(['distance and speed based Percentage of wrongly grouped points: ', num2str(wrongly_grouped_percentage), '%']);
    results2(i) = wrongly_grouped_percentage;

    % Close the files
    fclose(fileID_without_labels);
    fclose(fileID_with_labels);
    hold off;

        % Parameters
    area_size = 10; % 10m x 10m area
    radar_position = [area_size / 2, 0]; % Radar at the bottom middle
    num_points = 10; % Number of random points per object
    time_step = 0.1; % Time increment for simulation (seconds)
    total_time = 3; % Total simulation time (seconds)
    num_steps = total_time / time_step; % Total number of steps
    
    epsilon = 1.1; % DBSCAN distance threshold (epsilon value)
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
    results3(i) = wrongly_grouped_percentage;

    % Close the files
    fclose(fileID_without_labels);
    fclose(fileID_with_labels);
    hold off;

end
%%
avgs = [mean(results1),mean(results2),mean(results3)];
vars = [std(results1),std(results2),std(results3)];
y = avgs/100;
figure;
errorbar(1:3,avgs,vars,'o')
xticks(1:length(y));

% Define custom labels for the x-axis
xticklabels({'distance based', 'distance and speed based', 'distance, speed and acceleration based'});

% Set font size
set(gca, 'FontSize', 14);

% Label the y-axis
ylabel('Classification Error Percentage');
xlim([0.5,3.5])

% Add a title
title('Classification Errors per Clustering Method');
y = avgs/100;
for i = 1:length(y)
    text(i, y(i)*100, sprintf('%.2f%%', y(i) * 100), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 12, 'Color', 'blue');
end