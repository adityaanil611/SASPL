% EXPERIMENT 6: MFCC extraction (frame->mel filterbank->log->DCT)
[audio, Fs] = audioread('speech.wav'); if size(audio,2)>1, audio = mean(audio,2); end
audio = audio - mean(audio); audio = audio / max(abs(audio)+eps);
preEmph = 0.97; audio = filter([1 -preEmph],1,audio);

frameSize = 0.025; frameStep = 0.010;
frameLen = round(frameSize*Fs); frameStepSamp = round(frameStep*Fs);
frames = buffer(audio, frameLen, frameLen - frameStepSamp, 'nodelay')';
% apply window
frames = frames .* (hamming(frameLen)');

NFFT = 512;
magFrames = abs(fft(frames, NFFT, 2));
powFrames = (1/NFFT)*(magFrames.^2);

% mel filterbank
numFilters = 26;
lowFreq = 0; highFreq = Fs/2;
hz2mel = @(hz) 2595*log10(1+hz/700);
mel2hz = @(mel) 700*(10.^(mel/2595)-1);
lowMel = hz2mel(lowFreq); highMel = hz2mel(highFreq);
melPoints = linspace(lowMel, highMel, numFilters+2);
hzPoints = mel2hz(melPoints);
bin = floor((NFFT+1)*hzPoints/Fs);

fbank = zeros(numFilters, NFFT/2+1);
for m=2:numFilters+1
    f_m_minus = bin(m-1); f_m = bin(m); f_m_plus = bin(m+1);
    for k = f_m_minus:f_m
        fbank(m-1,k+1) = (k - bin(m-1)) / (bin(m) - bin(m-1) + eps);
    end
    for k = f_m:f_m_plus
        fbank(m-1,k+1) = (bin(m+1) - k) / (bin(m+1) - bin(m) + eps);
    end
end

filterBankEnergies = powFrames(:,1:NFFT/2+1) * fbank';
filterBankEnergies(filterBankEnergies==0) = eps;
logE = log(filterBankEnergies);

% DCT -> MFCCs
numCoeffs = 13;
mfccs = dct(logE, [], 2);
mfccs = mfccs(:,1:numCoeffs);

% plot MFCCs
figure; imagesc(mfccs'); axis xy; xlabel('Frame'); ylabel('MFCC index'); title('MFCCs');
