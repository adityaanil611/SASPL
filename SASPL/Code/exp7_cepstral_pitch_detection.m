% EXPERIMENT 7: Cepstrum-based pitch detection
[audio, Fs] = audioread('speech.wav'); if size(audio,2)>1, audio = mean(audio,2); end
audio = audio - mean(audio);
% select voiced frame
frameLen = round(0.03*Fs);
startIdx = floor(length(audio)/2);
segment = audio(startIdx:startIdx+frameLen-1) .* hamming(frameLen);

% spectrum, log, IFFT -> cepstrum
NFFT = 2^nextpow2(2*length(segment));
spectrum = fft(segment, NFFT);
logSpectrum = log(abs(spectrum) + eps);
cep = real(ifft(logSpectrum));

% search quefrency range corresponding to 50-400 Hz
minF = 50; maxF = 400;
minQuef = floor(Fs/maxF); maxQuef = ceil(Fs/minF);
[~, qIdx] = max(cep(minQuef:maxQuef));
pitchPeriod = qIdx + minQuef - 1;
pitchHz = Fs / pitchPeriod;

fprintf('Cepstral pitch estimate: %.2f Hz\n', pitchHz);

% plot
figure;
subplot(3,1,1); plot(segment); title('Segment');
subplot(3,1,2); plot(cep); xlim([0 200]); title('Cepstrum (quefrency samples)');
subplot(3,1,3); plot((0:NFFT-1)*Fs/NFFT,20*log10(abs(spectrum))); title('Spectrum');
