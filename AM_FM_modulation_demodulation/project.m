% DSP Project: AM and FM Modulation and Demodulation (Optimized & Fixed)
% Toolbox-free, vectorized, and memory-efficient version

clear; clc; close all;

%% 1. Signal Parameters
Fs = 1e5;              % Sampling frequency (Hz)
T  = 0.1;              % Duration (seconds)
t  = linspace(0, T, Fs*T); % Time vector
Fc = 1e4;              % Carrier frequency (Hz)
Fm = 100;              % Message frequency (Hz)

% Message & Carrier
Am = 1; 
Ac = 1;
m_t = Am * cos(2*pi*Fm*t);
c_t = Ac * cos(2*pi*Fc*t);

% Noise
SNR_dB = 20;
noise = sqrt(Ac^2 / (2 * 10^(SNR_dB/10))) * randn(size(t));

fprintf('\n----------------------------------------------------\n');
fprintf('Starting AM and FM Modulation/Demodulation Simulation\n');
fprintf('----------------------------------------------------\n');

%% 2. AM Modulation and Demodulation
fprintf('2. AM Simulation...\n');
mu = 1;
s_AM = Ac * (1 + mu * m_t) .* c_t;
r_AM = s_AM + noise;

% Envelope Detection (using abs + moving average LPF)
window_size = 2*round(Fs/(4*Fc)) + 1;   % Force odd number
b = ones(1, window_size) / window_size;  % Moving average FIR
m_demod_AM = conv(abs(r_AM), b, 'same'); % Envelope smoothing

% Normalize
m_demod_AM = m_demod_AM - mean(m_demod_AM);
m_demod_AM = m_demod_AM / max(abs(m_demod_AM)) * Am;

fprintf('   AM Demodulation Complete.\n');

%% 3. FM Modulation and Demodulation
fprintf('3. FM Simulation...\n');
Kf = 5000; 
m_int = cumsum(m_t) / Fs;                 % Integral of message
s_FM = Ac * cos(2*pi*Fc*t + 2*pi*Kf*m_int);
r_FM = s_FM + noise;

% Frequency Discriminator (differentiate + envelope detect)
diff_FM = diff(r_FM);
env_diff_FM = abs(diff_FM);

% Filter and normalize
m_demod_FM = conv(env_diff_FM, b, 'same');
m_demod_FM = m_demod_FM - mean(m_demod_FM);
m_demod_FM = m_demod_FM / max(abs(m_demod_FM)) * Am;

% Adjust time vector to match diff_FM size
t_FM = t(1:end-1);

fprintf('   FM Demodulation Complete.\n');
fprintf('----------------------------------------------------\n');

%% 4. Plot Results
figure('Name', 'AM and FM Modulation/Demodulation (Optimized)', 'NumberTitle', 'off');

subplot(2,3,1);
plot(t, m_t, 'b');
title('1a. Message Signal m(t)'); xlabel('Time (s)'); ylabel('Amplitude');

subplot(2,3,2);
plot(t, s_AM, 'r');
xlim([0 0.01]);
title('1b. AM Modulated Signal'); xlabel('Time (s)');

subplot(2,3,3);
plot(t, m_demod_AM, 'g');
title('1c. AM Demodulated Signal'); xlabel('Time (s)');

subplot(2,3,4);
plot(t, m_t, 'b');
title('2a. Message Signal m(t)'); xlabel('Time (s)');

subplot(2,3,5);
plot(t, s_FM, 'r');
xlim([0 0.01]);
title('2b. FM Modulated Signal'); xlabel('Time (s)');

subplot(2,3,6);
plot(t_FM, m_demod_FM, 'g');
title('2c. FM Demodulated Signal'); xlabel('Time (s)');
