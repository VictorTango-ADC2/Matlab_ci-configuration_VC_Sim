Autonomous Vehicle Controller Simulation
Overview
This project simulates an autonomous vehicle controller using MATLAB and Simulink. It leverages a Clothoid Toolbox to manage smooth path generation and evaluates vehicle performance across various real-world and synthetic tracks (e.g., VIR, Pikes Peak, and figure-8 maneuvers).
Project Structure
main.m: The primary execution script.
VC_v1p2.slx: The core Simulink model for the vehicle controller.
../clothoid_toolbox: A dependency containing path-generation utilities and waypoint data.
init_par.m: Initializes vehicle dynamics and controller parameters.
repack_simdata.m: Post-processes raw Simulink output into organized MATLAB structures.
Getting Started
Prerequisites
MATLAB (R2021b or later recommended).
Simulink.
The clothoid_toolbox directory must be located in the parent folder.
Running the Simulation
Open MATLAB and navigate to the project directory.
In the TESTS array, specify the ID of the track you wish to simulate (e.g., TESTS = [13] for VTTI).
Set saveplots = true if you wish to archive the results in the /results folder.
Run the script.
Configuration
Reference Velocity & Constraints
The simulation calculates a velocity profile based on the following parameters:
vmax: Maximum allowable speed 
max_alat: Maximum lateral acceleration 
max_along: Maximum longitudinal acceleration
Waypoint Datasets

Performance Validation
After the simulation completes, the results are validated against specific thresholds to ensure safety and passenger comfort:
Cross-Track Error
Velocity Error
Comfort Limit (Jerk)
Stability Limit (Lat Accel
Security (Jamming Alert)
Output
simdata.mat: Contains all logged signals (position, heading, velocity, etc.).
Results Folder: If enabled, plots and data are saved to ./results/testcaseX/.
Inference Plots: Visual representations of robustness and threshold violations.
 
