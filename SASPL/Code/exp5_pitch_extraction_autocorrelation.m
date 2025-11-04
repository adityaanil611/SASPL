% EXPERIMENT 5: Pitch estimation by autocorrelation with peak refinement
recObj = audiorecorder(16000,16,1);
disp('Record ~3s voiced speech'); recordblocking(recObj,3);
signal = getaudiodata(recObj); Fs = recObj.SampleRate;
signal = signal - mean(signal); signal = signal / max(abs(signal)+eps);

% Manually select a voiced segment or use voiced detection
startSample = 1 + round(0.5*Fs); % example middle
segLen = round(0.03*Fs); % 30 ms
segment = signal(startSample:startSample+segLen-1) .* hamming(segLen);

% Autocorr
R = xcorr(segment);
R = R(segLen:end);

% search for peak in plausible pitch lags
minF0 = 70; maxF0 = 400;
minLag = floor(Fs/maxF0); maxLag = ceil(Fs/minF0);
searchR = R(minLag:maxLag);
[peaks, locs] = findpeaks(searchR);

if isempty(locs)
    error('No pitch found — unvoiced or noisy');
end

% take highest peak and refine with parabolic interpolation
[~,I] = max(peaks);
peakLoc = locs(I) + minLag - 1;
% interpolate to sub-sample accuracy
if peakLoc>1 && peakLoc < length(R)
    alpha = R(peakLoc-1); beta = R(peakLoc); gamma = R(peakLoc+1);
    p = 0.5*(alpha - gamma) / (alpha - 2*beta + gamma);
    refinedLag = peakLoc + p;
else
    refinedLag = peakLoc;
end
pitchFreq = Fs / refinedLag;

% display
fprintf('Estimated Pitch: %.2f Hz (lag %.3f samples)\n', pitchFreq, refinedLag);
figure; subplot(2,1,1); plot((1:length(segment))/Fs, segment); title('Segment');
subplot(2,1,2); plot((0:length(R)-1)/Fs, R); hold on; xline(refinedLag/Fs, '--r'); title('Autocorrelation');
