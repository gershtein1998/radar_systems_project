% Script to plot the points from the file and create a video without object labels

% Parameters
area_size = 10; % 10m x 10m area
radar_position = [area_size / 2, 0]; % Radar at the bottom middle
num_points = 10; % Number of random points per object
time_step = 0.1; % Time increment for simulation (seconds)
total_time = 3; % Total simulation time (seconds)
num_steps = total_time / time_step; % Total number of steps
sim_speedup = 1; % Speed up for animation

% Open the file to read the saved points' positions and speeds (without labels)
fileID = fopen('points_movement_without_labels.txt', 'r');

% Prepare figure for animation
figure;
hold on;
axis([0 area_size 0 area_size]);
title('Plot of Points Without Object Labels');
xlabel('X (m)');
ylabel('Y (m)');

% Create video writer object to save the animation
video_filename = 'points_without_labels_video.avi';
video_writer = VideoWriter(video_filename);
open(video_writer);

% Plot radar
plot(radar_position(1), radar_position(2), 'r^', 'MarkerSize', 10, 'DisplayName', 'Radar');

% Main loop to plot the data
for step = 1:num_steps
    % Initialize arrays for points
    object_points = zeros(num_points * 2, 2); % All points (object 1 + object 2)

    % Read data from file (for both objects at this step)
    for point_idx = 1:num_points * 2
        % Format: [point_id, x_location, y_location, x_speed, y_speed]
        data = fscanf(fileID, '%d %f %f %f %f\n', 5);
        object_points(point_idx, :) = data(2:3); % X and Y positions (ignore point_id and speeds)
    end

    % Clear previous plot and redraw
    cla;
    axis([0 area_size 0 area_size]);

    % Plot radar
    plot(radar_position(1), radar_position(2), 'r^', 'MarkerSize', 10, 'DisplayName', 'Radar');

    % Plot all points with the same color (ignoring object labels)
    plot(object_points(:, 1), object_points(:, 2), 'bo', 'MarkerSize', 5, 'DisplayName', 'Points');
    
    legend show;

    % Pause to create animation effect
    pause(time_step / sim_speedup);
    
    % Capture the frame and write to video
    frame = getframe(gcf);
    writeVideo(video_writer, frame);
end

% Close the video file after the simulation ends
close(video_writer);

% Close the file
fclose(fileID);
hold off;

disp(['Video saved to: ', video_filename]);
