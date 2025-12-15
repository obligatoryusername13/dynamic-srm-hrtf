%% HRTF to SOFA Converter: Measured Data to Standard Format
% Converts windowed binaural impulse responses (irEstimate) to SOFA file
% for compatibility with AMT toolbox and Jelfs2011 SRM simulations
%
% Input: 
% - irEstimate: [samples x ears x sources] from HRTF measurement script
% - 64-speaker array geometry: azimuth/elevation at 2.4m radius
%
% Processing:
% - Permutes to SOFA format: [sources x ears x samples]
% - SimpleFreeFieldHRIR convention with spherical coordinates
% - fs = 48kHz, ears at origin
%
% Output: 
% - win_hrtf.sofa (verified by sofaread)
%
% Author: Kevin Anil Varghese | Date: 14/12/2025
% Dependencies: SOFA toolbox (sofaconvention, sofawrite, sofaread)

close all; clear all; clc;
%%
% Load measured HRTF data
% addpath(genpath('D:\Acoustics\Special Course\Jelfs2011 Test\Mk_kem_myHrtf_labBRIR'))
% load('binauralIRs.mat'); %load measured data

hrir = permute(irEstimate, [3 2 1]); %sofawrite requires ir in measurements x channels x samples matrix format
fs = 48000;

% hrir = permute(irEstimate, [2 3 1]);

%azimuth, elevation
directions = [ ...
    0, 80;         % speaker 1
    180, 80;       % speaker 2
    0, 56;         % speaker 3
    60, 56;        % speaker 4
    120, 56;       % speaker 5
    180, 56;       % speaker 6
    240, 56;       % speaker 7
    300, 56;       % speaker 8
    0, 28;         % speaker 9
    30, 28;        % speaker 10
    60, 28;        % speaker 11
    90, 28;        % speaker 12
    120, 28;       % speaker 13
    150, 28;       % speaker 14
    180, 28;       % speaker 15
    210, 28;       % speaker 16
    240, 28;       % speaker 17
    270, 28;       % speaker 18
    300, 28;       % speaker 19
    330, 28;       % speaker 20
    0, 0;          % speaker 21
    15, 0;         % speaker 22
    30, 0;         % speaker 23
    45, 0;         % speaker 24
    60, 0;         % speaker 25
    75, 0;         % speaker 26
    90, 0;         % speaker 27
    105, 0;        % speaker 28
    120, 0;        % speaker 29
    135, 0;        % speaker 30
    150, 0;        % speaker 31
    165, 0;        % speaker 32
    180, 0;        % speaker 33
    195, 0;        % speaker 34
    210, 0;        % speaker 35
    225, 0;        % speaker 36
    240, 0;        % speaker 37
    255, 0;        % speaker 38
    270, 0;        % speaker 39
    285, 0;        % speaker 40
    300, 0;        % speaker 41
    315, 0;        % speaker 42
    330, 0;        % speaker 43
    345, 0;        % speaker 44
    0, -28;        % speaker 45
    30, -28;       % speaker 46
    60, -28;       % speaker 47
    90, -28;       % speaker 48
    120, -28;      % speaker 49
    150, -28;      % speaker 50
    180, -28;      % speaker 51
    210, -28;      % speaker 52
    240, -28;      % speaker 53
    270, -28;      % speaker 54
    300, -28;      % speaker 55
    330, -28;      % speaker 56
    30, -56;       % speaker 57
    90, -56;       % speaker 58
    150, -56;      % speaker 59
    210, -56;      % speaker 60
    270, -56;      % speaker 61
    330, -56;      % speaker 62
    90, -80;       % speaker 63
    270, -80;      % speaker 64
    ];

azimuth = directions(:,1);
elevation = directions(:,2);
dist = 2.4 * ones(64,1);

source_pos = [azimuth,elevation,dist]; %concatenate data, each 64x1

%form sofa structure

s = sofaconvention("SimpleFreeFieldHRIR");
s.Numerator = hrir; %64 x 2 x 14400
s.SourcePosition = source_pos; %64 x 3
s.SourcePositionType = "spherical";
s.ReceiverPosition = [0 0 0; 0 0 0]; %Ears at origin
s.ReceiverPositionType = "cartesian";
s.SamplingRate = fs; %48000

%write
sofawrite("win_hrtf.sofa", s);
s = sofaread("win_hrtf.sofa");
