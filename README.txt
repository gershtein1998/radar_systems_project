This simulation was done as part of the project for the Radar systems course at Ben Gurion University, at the school of Electrical and Computer Engineering.

To run this simulation MATLAB is required. There are two ways to run it:
	1. running the "ground_truth_creation.m" file and then selecting which type of clustering (labeling) method to use.
	2. to test the different methods against each other, it is possible to run the "final_run_and_results.m" file.

Note that there exist 3 scenarios that can be edited in the data generation part of the simulation or added upon. each scenario is clustered in 3 different ways:
	1. location based (distance based)
	2. location and speed based
	3. location, speed and RD-Flow based
In the same area of the code, one can also find different parameters that could be edited, like number of hits per object, distribution parameters, etc.

for each methods the DBSCAN parameters can also be edited, this can be done in the individual sections of each method

