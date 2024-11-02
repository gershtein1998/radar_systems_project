% Your data
y = [36.6667, 21.6667, 16.6667] / 100;

% Create a line plot with markers
plot(y, '-o', 'LineWidth', 3, 'MarkerSize', 8, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r'); 

% Set x-axis ticks to match the number of data points
xticks(1:length(y));

% Define custom labels for the x-axis
xticklabels({'distance based', 'distance and speed based', 'distance, speed and acceleration based'});

% Set font size
set(gca, 'FontSize', 14);

% Label the y-axis
ylabel('Classification Error Percentage');

% Add a title
title('Classification Errors per Clustering Method');

% Add text labels next to each marker
for i = 1:length(y)
    text(i, y(i), sprintf('%.2f%%', y(i) * 100), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 12, 'Color', 'blue');
end
