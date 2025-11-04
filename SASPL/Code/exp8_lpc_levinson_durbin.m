% EXPERIMENT 8: Compute LPC via Levinson-Durbin
[audio, Fs] = audioread('speech.wav'); if size(audio,2)>1, audio = mean(audio,2); end
audio = audio - mean(audio); audio = audio / max(abs(audio)+eps);

% Frame selection
frameLen = round(0.03*Fs);
startIdx = floor(length(audio)/2);
frame = audio(startIdx:startIdx+frameLen-1) .* hamming(frameLen);

p = 12; % LPC order
% autocorrelation up to lag p
R_full = xcorr(frame, p, 'biased');
R = R_full(p+1:end); % lags 0..p

% Levinson-Durbin via built-in
[a, E, k] = levinson(R, p); % returns coefficients a (length p+1)
% a(1) = 1, a(2:end) negative the predictor coefficients
disp('LPC coefficients (a):'); disp(a);
disp(['Prediction error E = ', num2str(E)]);
disp('Reflection (PARCOR) coefficients:'); disp(k);

% Plot poles -> formants
rootsA = roots(a);
% keep roots with imag>0 and reasonable freq
formantFreqs = sort(atan2(imag(rootsA(imag(rootsA)>0)), real(rootsA(imag(rootsA)>0))) * Fs/(2*pi));
disp('Estimated formants from LPC roots:'); disp(formantFreqs);
