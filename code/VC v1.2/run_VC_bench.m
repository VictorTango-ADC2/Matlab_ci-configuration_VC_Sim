%  This script sets up and runs a simulation of the autonomous vehicle
%  controller

%  Last Updated:   1/07/2026

clear, clc

%  --setup the temporary path assignments
addpath ../clothoid_toolbox -begin

wptfolder = '../clothoid_toolbox/waypoint_data/';

saveplots = false;
savemovie = false;

if saveplots
    %  --check to see if the results folder exists
    if (exist('results','dir') == 0)
        %  --results folder does not exists so create it
        mkdir results
    end
end


%  --initialize the simulation parameters
init_par


%  --load the waypoint data
%  testcase = enum input for selecting a waypoint data set
%     lanechange.mat                % 1
%     figure8.mat                   % 2
%     Zandvoort_clothoid.mat        % 3
%     Zandvoort.mat                 % 4
%     Yuma_clothoid.mat             % 5
%     Yuma.mat                      % 6
%     VIR_clothoid.mat              % 7
%     VIR.mat                       % 8
%     RoadAmerica_clothoid.mat      % 9
%     RoadAmerica.mat               % 10
%     PikesPeak_clothoid.mat        % 11
%     PikesPeak.mat                 % 12
%     VTTI_VIC.mat                  % 13

TESTS = [1];


%  --loop through each testcase

vstart = 1;    % initial reference velocity (m/s)
vmax = 10;     % maximum allowable reference velocity (m/s)
vfinal = 0;    % final reference velocity (m/s)

max_alat = 3.25;   % maximum lateral acceleration (m/s/s)
max_along = 3.25;  % maximum longitudinal acceleration (m/s/s)

randrotate = false;  % Boolean for applying a randomly rotating data

for testcase = TESTS

    clear NWP EWP HWP VWP KWP ZWP SWP GWP WPT_MTX TFINAL sim

    [NWP,EWP,HWP,VWP,KWP,ZWP,SWP,GWP,coursename] = get_waypoint_data( ...
        testcase, vstart, vmax, vfinal, max_alat, max_along, randrotate, ...
        wptfolder);

    NWP = NWP - NWP(1);
    EWP = EWP - EWP(1);
    
    NUM_WP = length(NWP);
    WPT_MTX = [NWP,EWP,HWP,VWP,KWP,SWP];


    %  --compute and display simulation metrics prior to running

    TFINAL = estimate_sim_duration(VWP,SWP);

    fprintf('Course name:                      %s\n',coursename);
    fprintf('Total Number of Waypoints:        %g\n',NUM_WP);
    fprintf('Total Path Length:                %g (m)\n',SWP(end));
    fprintf('Total Elevation Change:           %g (m)\n',max(ZWP)-min(ZWP));
    fprintf('Total estimated Simulation Time:  %g (s)\n',TFINAL);
    fprintf('Average Speed:                    %g (m/s)\n',SWP(end)/TFINAL);
    fprintf('Average VWP:                      %g (m/s)\n',mean(VWP));
    fprintf('Minimum WP Separation:            %g (m)\n',min(diff(SWP)));
    fprintf('Average WP Separation:            %g (m)\n',mean(diff(SWP)));
    fprintf('Maximum WP Separation:            %g (m)\n',max(diff(SWP)));


    %  --define the vehicle initial conditions

    north0 = NWP(1);   % initial northing coordinate (meters)
    east0 = EWP(1);    % initial easting coordinate (meters)
    psi0 = (pi/180)*HWP(1);     % initial heading (radians)
    vcg0 = 0;          % initial forward velocity (meters/sec)

    % return

    %  --run the closed-loop simulation
    tstart = tic;
    sim('VC_v1p2.slx',TFINAL)
    toc(tstart)

    clear tstart K

    repack_simdata

    if saveplots
        %  --create the folder for test results
        folder = sprintf('./results/testcase%g/',testcase);
        if (exist(folder,'dir') == 0)
            %  --subfolder does not exist so create it
            mkdir(folder);
        end

        %  --save simulation results to the specific testcase folder
        save(strcat(folder,'simdata.mat'))
    else
        %  --just save a local copy of the simulation results
        save simdata.mat
    end


    %%  --plot the simulation response data
    plot_sim_results
end

%%  --remove the temporary path assignments
%rmpath ../clothoid_toolbox
