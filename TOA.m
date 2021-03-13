  

% Homogeneous Propagation Medium Example
%
% This example provides a simple demonstration of using k-Wave for the
% simulation and detection of the pressure field generated by an initial
% pressure distribution within a two-dimensional homogeneous propagation
% medium.
%
% author: Bradley Treeby
% date: 29th June 2009
% last update: 28th April 2017
%  
% This function is part of the k-Wave Toolbox (http://www.k-wave.org)
% Copyright (C) 2009-2017 Bradley Treeby

% This file is part of k-Wave. k-Wave is free software: you can
% redistribute it and/or modify it under the terms of the GNU Lesser
% General Public License as published by the Free Software Foundation,
% either version 3 of the License, or (at your option) any later version.
% 
% k-Wave is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
% more details. 
% 
% You should have received a copy of the GNU Lesser General Public License
% along with k-Wave. If not, see <http://www.gnu.org/licenses/>. 
clear
clearvars;

% =========================================================================
% SIMULATION
% =========================================================================
%% create the computational grid
Nx = 200;           % number of grid points in the x (row) direction
Ny = 200;           % number of grid points in the y (column) direction
dx = 1e-3;        % grid point spacing in the x direction [m]
dy = 1e-3;        % grid point spacing in the y direction [m]
kgrid = kWaveGrid(Nx, dx, Ny, dy);

% define the properties of the propagation medium
medium.sound_speed = 340;  % [m/s]
medium.alpha_coeff = 0.75;  % [dB/(MHz^y cm)]
medium.alpha_power = 1.5; 

% create initial pressure distribution using makeDisc
% disc_magnitude = 5; % [Pa]
% disc_x_pos = Nx/2+45;    % [grid points]
% disc_y_pos = 65;    % [grid points]
% disc_radius = 1;    % [grid points]
% disc_1 = disc_magnitude * makeDisc(Nx, Ny, disc_x_pos, disc_y_pos, disc_radius);

%% creating a transducer to generate a sine wave.
% create the time array
kgrid.makeTime(medium.sound_speed);

% define a single source point


% define a time varying sinusoidal source
source_freq = 5e4;   % [Hz]
source_mag = 10;         % [Pa]
source.p = source_mag * sin(2 * pi * source_freq * kgrid.t_array);
source.p = filterTimeSeries(kgrid, medium, source.p);

amountSources = 5;
source_set = []
coordinate_set = []
for i = 1:amountSources
    source.p_mask = zeros(Nx, Ny);
    x = round((Nx-20)*rand()+10)
    y = round((Ny-20)*rand()+10)
    
    %x = int16((Nx/2-20)*cos((2*pi*i)/amountSources) + 1)+Nx/2
    %y = int16((Ny/2-20)*sin((2*pi*i)/amountSources) + 1)+Ny/2
    source.p_mask(x,y) = 1;
    
    source_set = [source_set source]
    coordinates = [x y]
    coordinate_set = [coordinate_set coordinates]
end

%error("test")


% filter the source to remove high frequencies not supported by the grid



%% define both sensor array's
x_offset = Nx/2;                 % [grid points]
width = 150;                    % [grid points]
y_mid_left = (width-20)/4 + Ny/2 - width/2;
y_mid_right = (width-20)/4 + Ny/2 + 10;
sensor.mask = zeros(Nx, Ny);
sensor.mask(x_offset, (Ny/2 - width/2 + 1:Ny/2 + width/2)) = 1;
sensor.mask(x_offset, ((Ny/2)-9):((Ny/2)+10)) = 0;

%% run the simulation
%input_args = {'RecordMovie', true, 'MovieName', 'example_movie'};
%sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor, input_args{:});
tic
sensor_data = []

for i = 1:amountSources
    m = (i-1)*2+1;
    %input_args = {'RecordMovie', true, 'MovieName', strcat('JPEG_AVI_',int2str(i)), 'MovieProfile', 'Motion JPEG AVI', 'MovieArgs', {'FrameRate', 10},};
    %sensor_data = [sensor_data; runTime(kspaceFirstOrder2D(kgrid, medium, source_set(i), sensor, input_args{:}),coordinate_set(m:m+1))]
    sensor_data = [sensor_data; runTime(kspaceFirstOrder2D(kgrid, medium, source_set(i), sensor),coordinate_set(m:m+1))]
end
simulationRunTime = toc
timeStep = kgrid.dt

%% get the TOA of each microphone
%in the futur use beam forming and take the array as a possible one
%microphone

t = zeros(30,amountSources)
for i = 1:amountSources
    %check arrival time left side
    for n = 1:15
        p = sensor_data(i).left(n,:)
        temp = find(p>=0.2)*timeStep;
        t(n,i) = temp(1)
    end
    %check arrival time right side
    for n = 1:15
        p = sensor_data(i).right(n,:)
        temp = find(p>=0.2)*timeStep;
        t(n+15,i) = temp(1)
    end 
end

%% optimization theory to determine locations

%% =========================================================================
% VISUALISATION
% =========================================================================

%combine all maskes of sources
sourceMask = zeros(Nx, Ny);
for i=1:length(source_set)
    sourceMask = sourceMask + source_set(i).p_mask;
end

% plot the initial pressure and sensor distribution
figure;
imagesc(kgrid.y_vec * 1e3, kgrid.x_vec * 1e3, sensor.mask + sourceMask, [-1, 1]);
colormap(getColorMap);
ylabel('x-position [mm]');
xlabel('y-position [mm]');
axis image;

% plot the simulated sensor data
% figure;
% imagesc(sensor_data, [-1, 1]);
% colormap(getColorMap);
% ylabel('Sensor Position');
% xlabel('Time Step');
% colorbar;
% 
% % plot the mesh value
% figure;
% mesh(sensor_data);
% ylabel("Sensor Position")
% xlabel("Time step")

% figure
% subplot(2,2,1)
% imagesc(sensor_left, [-1, 1]);
% colormap(getColorMap);
% ylabel('Sensor Position');
% xlabel('Time Step');
% title("Array left");
% colorbar;
% 
% subplot(2,2,3)
% imagesc(sensor_right, [-1, 1]);
% colormap(getColorMap);
% ylabel('Sensor Position');
% xlabel('Time Step');
% title("Array right");
% colorbar;
% 
% subplot(2,2,2)
% plot(response_left)
% xlabel('Time Step')
% ylabel('Amplitude measured')
% title("Left array response")
% 
% subplot(2,2,4)
% plot(response_right)
% xlabel('Time Step')
% ylabel('Amplitude measured')
% title("Right array response")
% 
% figure
% subplot(2,1,1)
% plot(f,P1) 
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')
% subplot(2,1,2)
% plot(f,P3) 
% xlabel('f (Hz)')
% ylabel('Angle(P1(f))')