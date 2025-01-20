clc;
clear;

% Parameters
numRows = 8;
numCols = 8;
sidelobeLevel = 30;  % Chebyshev sidelobe level in dB
frequency = 3e8;     % Operating frequency (1 GHz)
c = 3e8;             % Speed of light (m/s)
lambda = c / frequency;

% Create the rectangular array
array = phased.URA('Size', [numRows, numCols], ...
                   'ElementSpacing', [0.5*lambda 0.5*lambda], ...
                   'Element', phased.IsotropicAntennaElement('FrequencyRange', [3e8 30e8]));

% Generate Chebyshev tapering weights
taperRow = chebwin(numRows, sidelobeLevel);
taperCol = chebwin(numCols, sidelobeLevel);
taperWeights = taperRow * taperCol.';

% Compute Array Response
azimuthAngles = -180:1:180;
elevationAngles = -90:1:90;

% Visualize the 3D beam pattern
figure;
pattern(array, frequency, azimuthAngles, elevationAngles, ...
        'CoordinateSystem', 'polar', ...
        'Type', 'directivity', ...
        'Weights', taperWeights(:));
title('8x8 Rectangular Array 3D Pattern with Chebyshev Tapering');

% Visualize the azimuth pattern at 0-degree elevation
figure;
pattern(array, frequency, azimuthAngles, 0, ...
        'Type', 'directivity', ...
        'Weights', taperWeights(:));
title('Azimuth Pattern with Chebyshev Tapering');
