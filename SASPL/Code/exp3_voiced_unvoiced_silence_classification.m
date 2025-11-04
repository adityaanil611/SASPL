% EXPERIMENT 3: Voiced/Unvoiced/Silence segmentation
% Reads a signal, frames, computes energy and ZCR, and assigns labels with
% adaptive thresholds (automatic threshold estimation).

[audio, Fs] = audioread('speech.wav'); 
if size(audio,2)>1, audio = mean(audio,2); end
audio = audio - mean(audio); audio = audio / max(abs(audio)+eps);

frameDur = 0.02; frameLen = round(frameDur*Fs);
overlap = round(0.5*frameLen); hop = frameLen - overlap;
frames = buffer(audio, frameLen, overlap, 'nodelay');
numFrames = size(frames,2);

% features
energy = sum(frames.^2);
zcr = sum(abs(diff(sign(frames)))==2) ./ (2*frameLen);

% Automatic thresholding using median and MAD (robust)
energy_med = median(energy); energy_mad = mad(energy,1);
zcr_med = median(zcr); zcr_mad = mad(zcr,1);

energyThresh = max(energy_med + 0.5*energy_mad, 1e-6);
zcrVoicedThresh = zcr_med - 0.5*zcr_mad;
zcrSilenceThresh = zcr_med - 1.0*zcr_mad;

labels = strings(1,numFrames);
for i=1:numFrames
    if energy(i) < energyThresh && zcr(i) < zcrSilenceThresh
        labels(i) = "Silence";
    elseif zcr(i) < zcrVoicedThresh
        labels(i) = "Voiced";
    else
        labels(i) = "Unvoiced";
    end
end

% Plot
timeAxis = ((0:numFrames-1)*hop + frameLen/2)/Fs;
figure; subplot(3,1,1); plot((1:length(audio))/Fs, audio); title('Signal');
subplot(3,1,2); plot(timeAxis, energy); title('Short-Time Energy');
subplot(3,1,3); plot(timeAxis, zcr); title('ZCR');

% Annotated region plot
figure; plot((1:length(audio))/Fs, audio, 'k'); hold on;
colors = struct('Voiced',[0 0.8 0],'Unvoiced',[0 0.45 1],'Silence',[1 0 0]);
for i=1:numFrames
    x0 = (i-1)*hop/Fs;
    rectangle('Position',[x0, -1, frameDur, 2], 'FaceColor', colors.(char(labels(i))), 'EdgeColor','none');
end
alpha(0.25); title('Detected Regions (green=voiced, blue=unvoiced, red=silence)');
