% Parameters for the beamforming and scattering channel
Nt = 256;
NtRF = 16;
Nr = 64;
NrRF = 16;
rng(4096);
c = 3e8;
fc = 28e9;
lambda = c / fc;

% Create Partitioned Arrays for Transmission and Reception
txarray = phased.PartitionedArray(...
    'Array', phased.URA([sqrt(Nt) sqrt(Nt)], lambda / 2), ...
    'SubarraySelection', ones(NtRF, Nt), 'SubarraySteering', 'Custom');
rxarray = phased.PartitionedArray(...
    'Array', phased.URA([sqrt(Nr) sqrt(Nr)], lambda / 2), ...
    'SubarraySelection', ones(NrRF, Nr), 'SubarraySteering', 'Custom');

% Scatterer cluster parameters
Ncl = 6;
Nray = 8;
Nscatter = Nray * Ncl;
angspread = 5;

% Randomly placed scatterer clusters
txclang = [rand(1, Ncl) * 120 - 60; rand(1, Ncl) * 60 - 30];
rxclang = [rand(1, Ncl) * 120 - 60; rand(1, Ncl) * 60 - 30];
txang = zeros(2, Nscatter);
rxang = zeros(2, Nscatter);

% Compute rays within each cluster
for m = 1:Ncl
    txang(:, (m-1) * Nray + (1:Nray)) = randn(2, Nray) * sqrt(angspread) + txclang(:, m);
    rxang(:, (m-1) * Nray + (1:Nray)) = randn(2, Nray) * sqrt(angspread) + rxclang(:, m);
end

% Channel and array responses
g = (randn(1, Nscatter) + 1i * randn(1, Nscatter)) / sqrt(Nscatter);
txpos = getElementPosition(txarray) / lambda;
rxpos = getElementPosition(rxarray) / lambda;
H = scatteringchanmtx(txpos, rxpos, txang, rxang, g);
F = diagbfweights(H);
F = F(1:NtRF, :);

% First part: Plot with optimal weights
pattern(txarray, fc, -90:90, -90:90, 'Type', 'efield', ...
    'ElementWeights', F', 'PropagationSpeed', c);

At = steervec(txpos, txang);
Ar = steervec(rxpos, rxang);
Ns = NtRF;
[Fbb, Frf] = omphybweights(H, Ns, NtRF, At);
pattern(txarray, fc, -90:90, -90:90, 'Type', 'efield', ...
    'ElementWeights', Frf' * Fbb', 'PropagationSpeed', c);

% Second part: Hybrid and optimal weights computation
snr_param = -40:10:30;
Nsnr = numel(snr_param);
Ns_param = [1 2];
NNs = numel(Ns_param);
NtRF = 16;
NrRF = 16;

Ropt = zeros(Nsnr, NNs);
Rhyb = zeros(Nsnr, NNs);
Niter = 50;

for m = 1:Nsnr
    snr = db2pow(snr_param(m));
    for n = 1:Niter
        % Channel realization
        txang = [rand(1, Nscatter) * 60 - 30; rand(1, Nscatter) * 20 - 10];
        rxang = [rand(1, Nscatter) * 180 - 90; rand(1, Nscatter) * 90 - 45];
        At = steervec(txpos, txang);
        Ar = steervec(rxpos, rxang);
        g = (randn(1, Nscatter) + 1i * randn(1, Nscatter)) / sqrt(Nscatter);
        H = scatteringchanmtx(txpos, rxpos, txang, rxang, g);

        for k = 1:NNs
            Ns = Ns_param(k);
            % Compute optimal weights and its spectral efficiency
            [Fopt, Wopt] = helperOptimalHybridWeights(H, Ns, 1 / snr);
            Ropt(m, k) = Ropt(m, k) + helperComputeSpectralEfficiency(H, Fopt, Wopt, Ns, snr);

            % Compute hybrid weights and its spectral efficiency
            [Fbb, Frf, Wbb, Wrf] = omphybweights(H, Ns, NtRF, At, NrRF, Ar, 1 / snr);
            Rhyb(m, k) = Rhyb(m, k) + helperComputeSpectralEfficiency(H, Fbb * Frf, Wrf * Wbb, Ns, snr);
        end
    end
end

Ropt = Ropt / Niter;
Rhyb = Rhyb / Niter;

% Plotting the results
figure;
plot(snr_param, Ropt(:, 1), '--sr', ...
    snr_param, Ropt(:, 2), '--b', ...
    snr_param, Rhyb(:, 1), '-sr', ...
    snr_param, Rhyb(:, 2), '-b');
xlabel('SNR (dB)');
ylabel('Spectral Efficiency (bits/s/Hz)');
legend('Ns=1 optimal', 'Ns=2 optimal', 'Ns=1 hybrid', 'Ns=2 hybrid', 'Location', 'best');
grid on;

% Parameters for the 8x8 Rectangular Array with Chebyshev Tapering
numRows = sqrt(Nt);
numCols = sqrt(Nt);
sidelobeLevel = 30;  % Chebyshev sidelobe level in dB
frequency = 3e8;     % Operating frequency (1 GHz)
c = 3e8;             % Speed of light (m/s)
lambda = c / frequency;

% Create the rectangular array
array = phased.URA('Size', [numRows, numCols], ...
                   'ElementSpacing', [0.5 * lambda 0.5 * lambda], ...
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
title([num2str(numRows), 'x', num2str(numCols), 'Rectangular Array 3D Pattern with Chebyshev Tapering']);

% Visualize the azimuth pattern at 0-degree elevation
figure;
pattern(array, frequency, azimuthAngles, 0, ...
        'Type', 'directivity', ...
        'Weights', taperWeights(:));
title('Azimuth Pattern with Chebyshev Tapering');