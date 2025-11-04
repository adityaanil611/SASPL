% EXPERIMENT 4: Wideband vs Narrowband spectrogram
[audio, Fs] = audioread('speech.wav'); if size(audio,2)>1, audio = mean(audio,2); end
audio = audio - mean(audio); audio = audio / max(abs(audio));

% Narrowband: long window -> good frequency resolution
win_narrow = round(0.03*Fs); % 30-50 ms
noverlap = round(0.75*win_narrow);
nfft = 2048;
figure;
subplot(2,1,1);
spectrogram(audio, hamming(win_narrow), noverlap, nfft, Fs, 'yaxis');
title('Narrowband Spectrogram (good freq resolution, poorer time)');

% Wideband: short window -> good time resolution
win_wide = round(0.01*Fs); % 10 ms
noverlap2 = round(0.5*win_wide);
subplot(2,1,2);
spectrogram(audio, hamming(win_wide), noverlap2, nfft, Fs, 'yaxis');
title('Wideband Spectrogram (good time resolution, poorer freq)');
