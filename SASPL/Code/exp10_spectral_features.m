% EXPERIMENT 10: Extract SC, SF, and Spectral Roll-off
[audio, Fs] = audioread('audio_sample.wav'); if size(audio,2)>1, audio = mean(audio,2); end
audio = audio / max(abs(audio)+eps);

frameSize = 1024; hopSize = 512;
numFrames = floor((length(audio)-frameSize)/hopSize) + 1;
spectralCentroid = zeros(numFrames,1);
spectralFlux = zeros(numFrames,1);
spectralRollOff = zeros(numFrames,1);

prevSpec = zeros(frameSize/2+1,1);
for i=1:numFrames
    startIdx = (i-1)*hopSize + 1;
    frame = audio(startIdx : startIdx+frameSize-1) .* hamming(frameSize);
    magSpec = abs(fft(frame));
    magSpec = magSpec(1:frameSize/2+1);
    freqAxis = (0:frameSize/2)' * (Fs/frameSize);
    
    % Spectral Centroid
    spectralCentroid(i) = sum(freqAxis .* magSpec) / (sum(magSpec)+eps);
    % Spectral Flux (squared Euclidean difference)
    diffSpec = magSpec - prevSpec;
    spectralFlux(i) = sum(diffSpec.^2);
    prevSpec = magSpec;
    % Roll-off (85% energy)
    totalEnergy = sum(magSpec.^2);
    threshold = 0.85 * totalEnergy;
    cumsumE = cumsum(magSpec.^2);
    idxRoll = find(cumsumE >= threshold, 1, 'first');
    spectralRollOff(i) = freqAxis(idxRoll);
end

timeVec = (0:numFrames-1)*(hopSize/Fs);
figure;
subplot(4,1,1); plot((1:length(audio))/Fs, audio); title('Audio');
subplot(4,1,2); plot(timeVec, spectralCentroid); title('Spectral Centroid (Hz)');
subplot(4,1,3); plot(timeVec, spectralFlux); title('Spectral Flux');
subplot(4,1,4); plot(timeVec, spectralRollOff); title('Spectral Roll-off (85%)');
