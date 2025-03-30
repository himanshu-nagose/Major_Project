% Step 3: Load the trained model and make predictions
load('beamforming_model.mat', 'net');
Nt = 64;      % Number of transmit antennas
NtRF = 4;     % Number of RF chains at transmitter
Nr = 16;      % Number of receive antennas
Ns = NtRF; % Number of data streams
NrRF = 4;     % Number of RF chains at receiver
Ncl = 6; 
Nray = 8; 
c = 3e8;      % Speed of light
fc = 28e9;    % Carrier frequency
lambda = c / fc;  % Wavelength
Nscatter = Ncl * Nray; % Number of scatterers\

txarray = phased.PartitionedArray(...
    'Array', phased.URA([sqrt(Nt), sqrt(Nt)], lambda / 2), ...
    'SubarraySelection', eye(NtRF, Nt), ...  % 4 × 64 matrix
    'SubarraySteering', 'Custom');

rxarray = phased.PartitionedArray(...
    'Array', phased.URA([sqrt(Nr), sqrt(Nr)], lambda / 2), ...
    'SubarraySelection', eye(NrRF, Nr), ...  % 4 × 16 matrix
    'SubarraySteering', 'Custom');


% Generate a new test channel realization
txang = [rand(1, Nscatter) * 60 - 30; rand(1, Nscatter) * 20 - 10];
rxang = [rand(1, Nscatter) * 180 - 90; rand(1, Nscatter) * 90 - 45];
g_test = (randn(1, Nscatter) + 1i * randn(1, Nscatter)) / sqrt(Nscatter);
g = (randn(1, Nscatter) + 1i * randn(1, Nscatter)) / sqrt(Nscatter);
txpos = getElementPosition(txarray) / lambda;
rxpos = getElementPosition(rxarray) / lambda;
H_test = scatteringchanmtx(txpos, rxpos, txang, rxang, g_test);
H = scatteringchanmtx(txpos, rxpos, txang, rxang, g);


% Prepare the input features for prediction
features_test = [real(g_test), imag(g_test)];

% Predict the beamforming weights using the neural network
predicted_weights = predict(net, features_test);
Fml = reshape(predicted_weights(1:NtRF * NrRF), NtRF, NrRF);  % Reshape into NtRF x NrRF

[Fopt, ~] = helperOptimalHybridWeights(H, Ns, 1);  % Compute Fopt

if exist('Fopt', 'var') == 0
    error('Fopt is not defined. Check if helperOptimalHybridWeights is executed properly.');
end

pattern(txarray, fc, -90:90, -90:90, 'Type', 'efield', ...
        'ElementWeights', mean(Fopt, 2)'); % Convert Fopt into a 1x4 vector

title('Beam Pattern with ML-Based Predicted Weights');