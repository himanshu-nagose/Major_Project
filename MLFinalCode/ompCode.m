clear; clc;

% Load Ns=3 dataset
load('Ns=3.mat'); % Ensure the file exists and is in the current directory
Ns = 3;
NRF = 3;

SNR_dB = -35:5:5; % SNR in dB
SNR = 10.^(SNR_dB ./ 10); % Convert to linear scale
realization = size(H, 3); % Number of channel realizations
smax = length(SNR);

% Preallocate results
R = zeros(smax, realization);
R_o = zeros(smax, realization);

% Calculate achievable rate for Ns=3
for reali = 1:realization
    [FRF, FBB] = OMP(Fopt(:, :, reali), NRF, At(:, :, reali));
    FBB = sqrt(Ns) * FBB / norm(FRF * FBB, 'fro');
    [WRF, WBB] = OMP(Wopt(:, :, reali), NRF, Ar(:, :, reali));
    for s = 1:smax
        R(s, reali) = log2(det(eye(Ns) + SNR(s) / Ns * ...
            pinv(WRF * WBB) * H(:, :, reali) * FRF * FBB * ...
            FBB' * FRF' * H(:, :, reali)' * WRF * WBB));
        R_o(s, reali) = log2(det(eye(Ns) + SNR(s) / Ns * ...
            pinv(Wopt(:, :, reali)) * H(:, :, reali) * ...
            Fopt(:, :, reali) * Fopt(:, :, reali)' * ...
            H(:, :, reali)' * Wopt(:, :, reali)));
    end
end

% Plot results for Ns=3
figure();
plot(SNR_dB, sum(R, 2) / realization, 'Marker', '^', 'LineWidth', 1.5, ...
    'Color', [0 0.498 0]);
grid on;
hold on;
plot(SNR_dB, sum(R_o, 2) / realization, 'r-o', 'LineWidth', 1.5);
title('Achievable Rate for Ns=3');
xlabel('SNR (dB)');
ylabel('Achievable Rate (bits/s/Hz)');
legend('Hybrid Beamforming', 'Optimal Beamforming');

% Clear and load Ns=6 dataset
clearvars -except OMP;
clc;
load('Ns=6.mat'); % Ensure the file exists and is in the current directory
Ns = 6;
NRF = 6:11;
SNR_dB = 0; % Single SNR value
SNR = 10.^(SNR_dB ./ 10);
realization = size(H, 3);

% Preallocate results
R = zeros(length(NRF), realization);
R_o = zeros(length(NRF), realization);

% Calculate achievable rate for Ns=6
for r = 1:length(NRF)
    for reali = 1:realization
        [FRF, FBB] = OMP(Fopt(:, :, reali), NRF(r), At(:, :, reali));
        FBB = sqrt(Ns) * FBB / norm(FRF * FBB, 'fro');
        [WRF, WBB] = OMP(Wopt(:, :, reali), NRF(r), Ar(:, :, reali));
        R(r, reali) = log2(det(eye(Ns) + SNR / Ns * ...
            pinv(WRF * WBB) * H(:, :, reali) * FRF * FBB * ...
            FBB' * FRF' * H(:, :, reali)' * WRF * WBB));
        R_o(r, reali) = log2(det(eye(Ns) + SNR / Ns * ...
            pinv(Wopt(:, :, reali)) * H(:, :, reali) * ...
            Fopt(:, :, reali) * Fopt(:, :, reali)' * ...
            H(:, :, reali)' * Wopt(:, :, reali)));
    end
end

% Plot results for Ns=6
figure();
plot(NRF, sum(R_o, 2) / realization, 'r-o', 'LineWidth', 1.5);
grid on;
hold on;
plot(NRF, sum(R, 2) / realization, 'Marker', '^', 'LineWidth', 1.5, ...
    'Color', [0 0.498 0]);
title('Achievable Rate for Ns=6');
xlabel('Number of RF Chains (NRF)');
ylabel('Achievable Rate (bits/s/Hz)');
legend('Optimal Beamforming', 'Hybrid Beamforming');

% Function: OMP Algorithm
function [FRF, FBB] = OMP(Fopt, NRF, At)
    FRF = [];
    Fres = Fopt;
    for k = 1:NRF
        PU = At' * Fres;
        [~, bb] = max(sum(abs(PU).^2, 2));
        FRF = [FRF, At(:, bb)];
        FBB = pinv(FRF) * Fopt; % Pseudoinverse
        Fres = Fopt - FRF * FBB;
        Fres = Fres / norm(Fres, 'fro');
    end
end
