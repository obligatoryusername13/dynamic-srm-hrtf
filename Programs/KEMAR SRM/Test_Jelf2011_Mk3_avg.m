%% SRM Simulation: KEMAR Database (Single HRTF)
% Computes Spatial Release from Masking (SRM) using Jelfs2011 model
% Compares world-fixed vs head-locked sources across head orientations
%
% Setup:
% - Database: KEMAR HRTF
% - Targets: -30°, 0°, +30° 
% - Interferers: ±15°, ±30°, ±60° (excluding target position)
% - Head yaw: -60° to +60° (15° steps)
% - Trials: 50 per configuration
%
% Outputs:
% - Polar plot: Mean SRM vs head orientation
% - Line plot: Mean SRM vs head orientation
%
% Author: Kevin Anil Varghese | Date: 14/12/2025
% Dependencies: AMT 1.6.0 toolbox (jelfs2011 function)

%addpath(genpath('...\amtoolbox-full-1.6.0'))
amt_start; % start tb

%%

%initialize

clear; clc; 
% close all;
intfr_angles = [-30 -15 0 15 30];  %Interferer speakers positioned at -30, -15, 0, 15 & 30 degrees
tgt_angles = [-30 0 30];           %Targets at -30, 0 and 30
trials = 50;                       %Number of trials
head_angles = -60:15:60;           %Head orientations
db = 'kemar';

snr_fixed = zeros(trials, length(head_angles));
snr_moving = zeros(trials, length(head_angles)); % Only one SNR for headlocked, per target

mean_snr_fixed = zeros(length(tgt_angles), length(head_angles));
mean_snr_moving = zeros(length(tgt_angles), length(head_angles));

final_snr_moving = zeros(1,length(head_angles));
final_snr_fixed = zeros(1,length(head_angles));

for tgt_cnt = 1:length(tgt_angles)
    tgt = tgt_angles(tgt_cnt);
    intfr = intfr_angles(intfr_angles ~= tgt); %intfr cannot be from tgt speaker
    
    for i = 1:length(head_angles)
        head_angle = head_angles(i);
        
        for n = 1:trials
            %Case 1: World-Fixed (depends on head angle)
            tgt_fixed = mod(tgt - head_angle,360);
            intfr_fixed = mod(intfr - head_angle,360);
            snr_fixed(n,i) = jelfs2011({tgt_fixed, db}, {intfr_fixed, db});
            
            %Case 1: Head-Locked (constant across head angles)
            tgt_headlocked = mod(tgt,360);
            intfr_headlocked = mod(intfr,360);
            snr_moving(n,i) = jelfs2011({tgt_headlocked, db}, {intfr_headlocked, db});
        end

        mean_snr_moving(tgt_cnt,i) = mean(snr_moving(:,i));
        mean_snr_fixed(tgt_cnt,i) = mean(snr_fixed(:,i));
    end
end

%%
for i = 1:length(head_angles)
    final_snr_moving(1,i) = mean(mean_snr_moving(:,i));
    final_snr_fixed(1,i) = mean(mean_snr_fixed(:,i));
end

%% 

% Polar plots
angles_rad = deg2rad(head_angles);
figure;
pax = polaraxes;  
hold(pax, 'on');

polarplot(pax, angles_rad, final_snr_moving, '--k','DisplayName', 'Head-Locked Sources', 'LineWidth', 1.5);

polarplot(pax, angles_rad, final_snr_fixed, '-r','DisplayName', 'World-Locked Sources', 'LineWidth', 1.5);

legend(pax, 'Location', 'bestoutside');
title(pax, 'SRM with Head Orientation');
hold(pax, 'off');
set(gca,'ThetaZeroLocation','top');% optional: 0° at top instead of right
thetaticks([0 15 30 45 60 300 315 330 345]);        % positions on circle
thetaticklabels({'0','15', '30','45', '60', '-60', '-45', '-30', '-15'});  % what you *show*
set(gca,'ThetaZeroLocation','top','ThetaDir','clockwise');

% Line graph

figure;
hold on;
colors = lines(length(tgt_angles));

% Plot world-fixed (varying with head angle)
plot(head_angles, final_snr_moving, '--k', 'DisplayName', 'Head-Locked Sources');
plot(head_angles, final_snr_fixed, '-r', 'DisplayName', 'World-Locked Sources');


hold off;
legend('Location','best');
xlabel('Head Orientation Angles [Degrees]');
ylabel('Mean Benefit [dB]')
title('SRM with Head Orientation');