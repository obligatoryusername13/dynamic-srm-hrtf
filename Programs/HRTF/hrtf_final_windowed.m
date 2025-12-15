%% HRTF Measurement: 64-Speaker Array Sweep Acquisition
% Measures binaural impulse responses (HRIRs) from 64 loudspeaker array
% using logarithmic sweeps with RedNet PCIe audio interface
%
% Setup:
% - Sweep: 6s log chirp (80-24kHz), -17dBFS, 300ms tail silence
% - Sampling: 48kHz, 24-bit
% - Recording: Channels 6/8 (L/R ears)
% - Processing: impzest deconvolution + 2ms direct sound window (6ms taper)
% - Visualization: IR time-domain + magnitude spectra for speakers #9, #45
%
% Outputs:
% - MAT file: irEstimate (windowed HRIRs), raw recordedSweep, parameters
%
% Author: Kevin Anil Varghese | Date: 14/12/2015
% Dependencies: AMT toolbox (for impzest), setfig

clear all;

pause(75);

%% Parameters from user input
fs = 48000; % sampling freq
fStart = 80; fStop = 24000; %freq range
duration = 6; % sweep len
endSilence = 300e-3; % silent after sweep
levelFS = -17; 

recChannels = [6 8]; % left right
playbackChannels = 1:64;

frameLength = 2048; % size for streaming

%% Init audio player/recorder
deviceName = 'RedNet PCIe';
playerRecorderObject = audioPlayerRecorder('Device', deviceName, ...
'SampleRate', fs, 'BitDepth', '24-bit integer', ...
'PlayerChannelMapping', [], 'RecorderChannelMapping', recChannels, 'SupportVariableSize',true);

%%
%  excitation
excitationSignal = sweeptone(duration, endSilence, fs, ...
'ExcitationLevel', levelFS, 'SweepFrequencyRange', [fStart fStop]);

dataLength = size(excitationSignal,1);
numFrames = ceil(dataLength/frameLength);

recordedSweep = zeros(dataLength, length(recChannels), length(playbackChannels));

%% loop
for nPlaybackChan = 1:length(playbackChannels)
ch = playbackChannels(nPlaybackChan);
disp(['Measuring speaker #' num2str(ch) '...'])

pause(1);

%set the output channel
playerRecorderObject.release;
playerRecorderObject.PlayerChannelMapping = ch;

recordedAudio = zeros(dataLength, length(recChannels));
nUnderruns = zeros(numFrames,1);
nOverruns  = zeros(numFrames,1);

%play & record
for kF = 1:numFrames-1
    s = frameLength*(kF-1)+1;
    e = frameLength*kF;
    [recordedAudio(s:e,:), nUnderruns(kF), nOverruns(kF)] = ...
        playerRecorderObject(excitationSignal(s:e,:));
end

%tail
if e < dataLength
    [recordedAudio(e+1:end,:), ~, ~] = playerRecorderObject(excitationSignal(e+1:end,:));
end

recordedSweep(:,:,nPlaybackChan) = recordedAudio;
close all
% estimate IR for this speaker
ir = impzest(excitationSignal, recordedAudio);
irEstimate(:,:,nPlaybackChan) = ir; 

end

%% 
% time window ir to avoid late reflections

keep_direct_ms = 2;      %direct sound
taper_ms       = 6;      %fade to 0

keep_direct = round(keep_direct_ms/1000*fs);
taper_len  = round(taper_ms/1000*fs);

for ch = 1:size(irEstimate,3)
  for ear = 1:2
    h = irEstimate(:,ear,ch);
    [~, idx_peak] = max(abs(h));

    % indices
    idx_keep_end = idx_peak + keep_direct - 1;
    idx_taper_end = min(idx_keep_end + taper_len - 1, length(h));

    w = ones(size(h));
    taper_window = hann(2*taper_len);        
    taper_window = taper_window(1:taper_len);% use rising half

    % apply taper only after fully kept region
    w(idx_keep_end+1:idx_taper_end) = flipud(taper_window(1:(idx_taper_end-idx_keep_end)));

    % zero after taper
    w(idx_taper_end+1:end) = 0;

    h_win = h .* w;
    irWin(:,ear,ch) = h_win;
  end
end


irEstimate = irWin;

%% Save results
FileName = ['HRTF_measure_', datestr(now, 'ddmmyy_HHMM'), '.mat'];
irEstimate = irEstimate; % keep as is
recordedSweep = recordedSweep;
save(FileName, 'irEstimate', 'recordedSweep', 'fStart', 'fStop', 'fs', 'duration', 'endSilence', 'excitationSignal', 'playbackChannels')

disp(['Data saved to ' FileName])

%%

spkr = [9 45];

% for nPlaybackChan = 1:length(playbackChannels)
%     ch = playbackChannels(nPlaybackChan);
  
for nPlaybackChan = 1:length(spkr)
    ch = spkr(nPlaybackChan);

    H_L = fft(squeeze(irEstimate(:,1, ch))); %mag spectrum for left channel
    H_R = fft(squeeze(irEstimate(:,2, ch))); %mag spectrum for right channel

    H_L = 20*log10(abs(H_L(1:(length(H_L)/2)+1,:))); %in dB
    H_R = 20*log10(abs(H_R(1:(length(H_R)/2)+1,:)));
    f = linspace(0,fs/2,length(H_R));

    % Impulse response
    IR_L = irEstimate(:,1, ch); %IR for right channel
    IR_R = irEstimate(:,2, ch); %IR for right channel

    t = linspace(0,2/fs,length(IR_R));

    figure(nPlaybackChan);
    
    subplot(2,1,1);

    plot(t, IR_L);
    hold on;
    plot(t, IR_R);
    
   
    legend('Left channel','Right channel', 'Location','best');
    xlabel('Time [s]');
    ylabel('Amplitude');
    %xlim([1.23e-5,1.265e-5]);
    %ylim([-0.07, 0.10])
    title(sprintf("Impulse Response from speaker #%d",ch));
    grid on;
    hold off;
    
    
    subplot(2,1,2);
    
    semilogx(f, H_L);
    hold on;
    semilogx(f, H_R);
    % semilogx(f2, Hs);
    
    legend('Left channel','Right channel', 'Location','best');
    xlabel('Frequency [Hz]');
    ylabel('Magnitude [dB]');
    %xlim([100,12000]);
    title(sprintf("HRTF magnitude spectrum from speaker #%d", ch));
    grid on;
    hold off;
    setfig(1, 12, 10);
end 