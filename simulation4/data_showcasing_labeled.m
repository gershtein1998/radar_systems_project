% Script to plot the points from the file and create a video with object labels

% Parameters
area_size = 10; % 10m x 10m area
radar_position = [area_size / 2, 0]; % Radar at the bottom middle
num_points = 10; % Number of random points per object
time_step = 0.1; % Time increment for simulation (seconds)
total_time = 3; % Total simulation time (seconds)
num_steps = total_time / time_step; % Total number of steps
sim_speedup = 1; % Speed up for animation

% Open the labeled file to read the saved points' positions and speeds
fileID = fopen('points_movement_with_labels.txt', 'r');

% Prepare figure for animation
figure;
hold on;
axis([0 area_size 0 area_size]);
title('Plot of Points With Object Labels');
xlabel('X (m)');
ylabel('Y (m)');


% Plot radar
plot(radar_position(1), radar_position(2), 'r^', 'MarkerSize', 10, 'DisplayName', 'Radar');

% Main loop to plot the data with labels
for step = 1:num_steps
    % Initialize arrays for points
    object_points = zeros(num_points * 2, 2); % All points (object 1 + object 2)
    object_labels = zeros(num_points * 2, 1); % Object labels (1 or 2)

    % Read data from the labeled file (for both objects at this step)
    for point_idx = 1:num_points * 2
        % Format: [object_id, x_location, y_location, x_speed, y_speed]
        data = fscanf(fileID, '%d %f %f %f %f %f\n', 6);
        object_labels(point_idx) = data(2); % Object label (1 or 2)
        object_points(point_idx, :) = data(3:4); % X and Y positions (ignore speeds)
    end

    % Clear previous plot and redraw
    cla;
    axis([0 area_size 0 area_size]);

    % Plot radar
    plot(radar_position(1), radar_position(2), 'r^', 'MarkerSize', 10, 'DisplayName', 'Radar');

    % Plot points based on their labels
    % Object 1 points (label 1)
    object1_points = object_points(object_labels == 1, :);
    plot(object1_points(:, 1), object1_points(:, 2), 'bo', 'MarkerSize', 5, 'DisplayName', 'Object 1');

    % Object 2 points (label 2)
    object2_points = object_points(object_labels == 2, :);
    plot(object2_points(:, 1), object2_points(:, 2), 'go', 'MarkerSize', 5, 'DisplayName', 'Object 2');
    
    legend show;

    % Pause to create animation effect
    pause(time_step / sim_speedup);
    
end

% Close the file
fclose(fileID);
hold off;

