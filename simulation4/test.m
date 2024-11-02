% Sample data
x = 1:10;                  % X-axis values
y = rand(1, 10) * 10;      % Y-axis values (random data for illustration)
errors = rand(1, 10);      % Error values for each point (random for illustration)

% Create error plot
figure;
errorbar(x, y, errors, 'o'); % 'o' specifies circular markers
xlabel('X-axis');
ylabel('Y-axis');
title('Error Plot Example');
