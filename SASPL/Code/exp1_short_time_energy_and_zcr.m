% EXPERIMENT 1: Short-Time Energy and ZCR at multiple frame sizes
% Usage: run. The script records ~5s of speech (or load a file), computes
% energy and ZCR per frame for multiple frame lengths, and plots results.

%% Parameters & Record / Load
Fs_default = 16000;
useRecording = true;  % set false to load file below
if useRecording
    recSec = 5;
    recObj = audiorecorder(Fs_default, 16, 1);
    disp('Start speaking...');
    recordblocking(recObj, recSec);
    disp('End of recording.');
    y = getaudiodata(recObj);
    Fs = recObj.SampleRate;
else
    [y, Fs] = audioread('speech.wav');
    if size(y,2)>1, y = mean(y,2); end
end

y = y - mean(y);           % remove DC
y = y / max(abs(y));       % normalize

%% Frame sizes to test (seconds)
frameRates = [0.01, 0.02, 0.04, 0.08];   % 10ms, 20ms, 40ms, 80ms
overlap_s = 0.005;                       % 5 ms overlap common baseline

figure('Name','Energy and ZCR for different frame sizes');
for idx = 1:length(frameRates)
    win_s = frameRates(idx);
    win_len = round(win_s * Fs);
    overlap_len = round(overlap_s * Fs);
    hop = win_len - overlap_len;
    % frame using buffer (columns are frames)
    frames = buffer(y, win_len, overlap_len, 'nodelay');
    nFrames = size(frames,2);
    
    energy = sum(frames.^2);                    % vector, energy per frame
    zcr = sum(abs(diff(sign(frames)))==2 )/ (2*size(frames,1)); % per-frame ZCR
    % time vector = center of each frame
    t = ((0:nFrames-1)*hop + win_len/2) / Fs;
    
    subplot(length(frameRates),2,(idx-1)*2+1);
    plot(t, energy);
    ylabel('Energy'); title(sprintf('Energy (frame=%.0f ms)', win_s*1000));
    xlabel('Time (s)');
    
    subplot(length(frameRates),2,(idx-1)*2+2);
    plot(t, zcr);
    ylabel('ZCR'); title(sprintf('ZCR (frame=%.0f ms)', win_s*1000));
    xlabel('Time (s)');
end
sgtitle('Short-Time Energy and ZCR — multiple frame sizes');
