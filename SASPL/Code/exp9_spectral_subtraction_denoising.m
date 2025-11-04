% EXPERIMENT 9: Simple spectral subtraction denoising
[noisy, fs] = audioread('noisy_speech.wav'); if size(noisy,2)>1, noisy = mean(noisy,2); end
noisy = noisy - mean(noisy);

frame_len = 256; overlap = 128; window = hamming(frame_len);
% Assume first 0.25s is noise-only
noise_dur = 0.25; n_noise = round(noise_dur * fs);
noise_sig = noisy(1:n_noise);

% estimate noise spectrum
noise_frames = buffer(noise_sig, frame_len, overlap, 'nodelay');
noise_spec = zeros(frame_len,1);
for i=1:size(noise_frames,2)
    f = noise_frames(:,i).*window;
    noise_spec = noise_spec + abs(fft(f));
end
noise_spec = noise_spec / size(noise_frames,2);

% process all frames
frames = buffer(noisy, frame_len, overlap, 'nodelay');
num_frames = size(frames,2);
output = zeros(length(noisy)+frame_len,1); idx = 1;

for i=1:num_frames
    frame = frames(:,i).*window;
    S = fft(frame);
    mag = abs(S); ph = angle(S);
    sub_mag = mag - noise_spec;
    % floor negative magnitudes and apply over-subtraction factor alpha
    alpha = 1.0; % tune >1 helps reduce residual noise
    sub_mag = max(mag - alpha*noise_spec, 0.001*noise_spec);
    S_hat = sub_mag .* exp(1j*ph);
    frame_hat = real(ifft(S_hat));
    output(idx:idx+frame_len-1) = output(idx:idx+frame_len-1) + frame_hat;
    idx = idx + (frame_len - overlap);
end

output = output(1:length(noisy));
output = output / max(abs(output)+eps);
audiowrite('enhanced_speech.wav', output, fs);

% plotting
t = (0:length(noisy)-1)/fs;
figure; subplot(2,1,1); plot(t,noisy); title('Noisy');
subplot(2,1,2); plot(t,output); title('Enhanced (spectral subtraction)');
