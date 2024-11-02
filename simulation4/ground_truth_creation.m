% First Simulation: Save movement, speed, and radial speed of points with noise
close all;
% Parameters
scenario_index = 2;%1 or 2 or 3
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
sim_speedup = 1;

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
