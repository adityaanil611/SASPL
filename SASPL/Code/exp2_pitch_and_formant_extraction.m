% EXPERIMENT 2: Pitch & Formant extraction for vowels (and unvoiced)
% Records multiple sounds and computes pitch (autocorr) and formants (LPC).

Fs = 16000;
duration = 2.0;                   % seconds per token
labels = {'a','e','i','o','u','s','sh','f'}; % vowels then unvoiced
numSounds = numel(labels);

pitchValues = zeros(1,numSounds);
formants = nan(numSounds,3);

for k = 1:numSounds
    fprintf('Prepare to pronounce /%s/ (recording %g s)...\n', labels{k}, duration);
    pause(0.5);
    recObj = audiorecorder(Fs,16,1);
    recordblocking(recObj, duration);
    y = getaudiodata(recObj);
    y = y(:,1);
    y = y - mean(y);
    y = y / max(abs(y)+eps);
    
    % Take a stable middle segment (avoid onset/offset)
    segLen = round(0.04*Fs); % 40ms segment for formant/pitch
    mid = floor(length(y)/2);
    seg = y(max(1,mid-segLen/2):min(length(y), mid+segLen/2));
    seg = seg .* hamming(length(seg));
    
    % Estimate pitch via autocorrelation
    pitchValues(k) = pitchFromAutocorr(seg, Fs);
    
    % Estimate formants using LPC on a longer voiced region (e.g., 30-50 ms)
    lpcOrder = 12; % typical for 16kHz
    a = lpc(seg, lpcOrder);
    rts = roots(a);
    rts = rts(imag(rts) >= 0.01); % keep upper-half plane roots
    angz = atan2(imag(rts), real(rts));
    formantFreqs = sort(angz * (Fs/(2*pi)));
    % keep first three formants if available
    nkeep = min(3, numel(formantFreqs));
    formants(k,1:nkeep) = formantFreqs(1:nkeep);
    
    % Optional: plot wave + spectrum for this token
    figure;
    subplot(2,1,1); plot((1:length(y))/Fs, y); title(['Waveform: /',labels{k},'/']);
    subplot(2,1,2);
    NFFT=2048; Y=abs(fft(seg,NFFT)); f=(0:NFFT-1)*Fs/NFFT;
    plot(f(1:NFFT/2),20*log10(Y(1:NFFT/2))); xlabel('Hz'); ylabel('Mag (dB)');
    title(sprintf('/%s/ Spectrum. Pitch=%.1f Hz', labels{k}, pitchValues(k)));
end

% display
fprintf('Sound\tPitch (Hz)\tF1 (Hz)\tF2 (Hz)\tF3 (Hz)\n');
for k=1:numSounds
    fprintf('/%s/\t%.1f\t\t%.1f\t%.1f\t%.1f\n', labels{k}, pitchValues(k), formants(k,1), ...
        formants(k,2), formants(k,3));
end

%% helper
function f0 = pitchFromAutocorr(x, Fs)
    x = x - mean(x);
    x = x / (max(abs(x))+eps);
    R = xcorr(x);
    R = R(length(x):end);
    % search lags corresponding to plausible pitch range
    minF0 = 70; maxF0 = 400;
    minLag = floor(Fs/maxF0); maxLag = ceil(Fs/minF0);
    [pks, locs] = findpeaks(R(minLag:maxLag));
    if isempty(locs)
        f0 = 0;
        return
    end
    [~,I] = max(pks);
    lag = locs(I) + minLag - 1;
    f0 = Fs / lag;
end
