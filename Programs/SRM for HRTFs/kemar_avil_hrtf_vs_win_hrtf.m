%% SRM Simulation: Fixed-World vs Head-Locked Sources
% Compares Spatial Release from Masking (SRM) across head orientations
% using Jelfs2011 model with KEMAR, win_HRTF, avil_hrtf databases
%
% Setup:
% - Targets: -30°, 0°, +30°
% - Interferers: ±15°, ±30°, ±60° (excluding target position)
% - Head yaw: -60° to +60° (15° steps)
% - Trials: 50 per configuration
%
% Outputs:
% - Polar plot: SRM vs head orientation (Fig 1)
% - Line plot: SRM vs head orientation (Fig 2)
%
% Author: Kevin Anil Varghese | Date: 14/12/2025
% Dependencies: AMT 1.6.0 toolbox

%addpath(genpath('...\amtoolbox-full-1.6.0'))
amt_start; % Start AMT toolbox

% Initialize
clear; clc; close all;
intfr_angles = [-30 -15 0 15 30];  %Interferer speakers positioned at -30, -15, 0, 15 & 30 degrees
tgt_angles = [-30 0 30];           %Targets at -30, 0 and 30
trials = 50;                       %trials
head_angles = -60:15:60;           %Head orientations
db_list      = {'kemar', 'win_HRTF', 'avil_hrtf'};    %all databases

angles_rad = deg2rad(head_angles);

%results for each database
mean_snr_fixed_all   = cell(length(db_list),1);
mean_snr_moving_all  = cell(length(db_list),1);
final_snr_moving_all = cell(length(db_list),1);

for db_idx = 1:length(db_list)
    db = db_list{db_idx};

    snr_fixed      = zeros(trials, length(head_angles));
    snr_moving     = zeros(trials, length(head_angles));
    mean_snr_fixed = zeros(length(tgt_angles), length(head_angles));
    mean_snr_moving= zeros(length(tgt_angles), length(head_angles));
    final_snr_moving = zeros(1,length(head_angles));

    for tgt_cnt = 1:length(tgt_angles)
        tgt = tgt_angles(tgt_cnt);
        intfr = intfr_angles(intfr_angles ~= tgt); %intfr cannot be from tgt speaker
        for i = 1:length(head_angles)
            head_angle = head_angles(i);
            for n = 1:trials
                %World-Fixed (depends on head angle)
                tgt_fixed   = mod(tgt - head_angle,360);      
                intfr_fixed = mod(intfr - head_angle,360);   
                snr_fixed(n,i) = jelfs2011({tgt_fixed, db}, {intfr_fixed, db});

                %Head-Locked (constant across head angles)
                tgt_headlocked   = mod(tgt,360);              
                intfr_headlocked = mod(intfr,360);            
                snr_moving(n,i) = jelfs2011({tgt_headlocked, db}, {intfr_headlocked, db});
            end
            mean_snr_moving(tgt_cnt,i) = mean(snr_moving(:,i));
            mean_snr_fixed(tgt_cnt,i)  = mean(snr_fixed(:,i));
        end
    end
    for i = 1:length(head_angles)
        final_snr_moving(1,i) = mean(mean_snr_moving(:,i));
    end

    mean_snr_fixed_all{db_idx}   = mean_snr_fixed;
    mean_snr_moving_all{db_idx}  = mean_snr_moving;
    final_snr_moving_all{db_idx} = final_snr_moving;
end

%%
%Polar plots
colors     = lines(length(tgt_angles));      
ls         = {'-','--',':'};               
mark_list = {'o','x', '^'};
hl_colors  = [0 0 0; 0 0 0; 0 0 0];         % all head-locked in black (simplest)

figure(1);
pax = polaraxes; hold(pax,'on');

for db_idx = 1:length(db_list)
    db = db_list{db_idx};
    mean_snr_fixed   = mean_snr_fixed_all{db_idx};
    final_snr_moving = final_snr_moving_all{db_idx};

    for tgt_cnt = 1:length(tgt_angles)
        polarplot(pax, angles_rad, mean_snr_fixed(tgt_cnt,:), ...
            'LineStyle', ls{db_idx}, ...
            'Color',     colors(tgt_cnt,:), ...
            'LineWidth', 1.5, ...
            'DisplayName', sprintf('%s: Fixed Target %d°', db, tgt_angles(tgt_cnt)));
    end

    polarplot(pax, angles_rad, final_snr_moving, ...
        'LineStyle', ls{db_idx}, ...
        'Color',     hl_colors(db_idx,:), ...
        'LineWidth', 1.5, ...
        'DisplayName', sprintf('%s: Head-Locked Sources', db));
end
legend(pax, 'Location','bestoutside', 'Interpreter','none');
title(pax,'SRM with Head Orientation');
hold(pax,'off');

%oreientation of polar graph, 0 at top
set(gca,'ThetaZeroLocation','top');
thetaticks([0 15 30 45 60 300 315 330 345]);        
thetaticklabels({'0','15', '30','45', '60', '-60', '-45', '-30', '-15'}); %map -60 to 300, -45 to 315, etc
set(gca,'ThetaZeroLocation','top','ThetaDir','clockwise');

%Line graph
figure(2); hold on;
for db_idx = 1:length(db_list)
    db = db_list{db_idx};
    mean_snr_fixed   = mean_snr_fixed_all{db_idx};
    final_snr_moving = final_snr_moving_all{db_idx};

    for tgt_cnt = 1:length(tgt_angles)
        plot(head_angles, mean_snr_fixed(tgt_cnt,:), ...
            ls{db_idx}, ...
            'DisplayName', sprintf('%s: Fixed Target %d°', db, tgt_angles(tgt_cnt)), ...
            'Marker', mark_list{db_idx}, ...
            'Color', colors(tgt_cnt,:), ...
            'LineWidth', 1.2);
    end

    plot(head_angles, final_snr_moving, ...
        ls{db_idx}, ...
        'DisplayName', sprintf('%s: Head-Locked Sources', db), ...
        'Color', hl_colors(db_idx,:), ...
        'LineWidth', 1.7);
end
hold off;
legend('Location','best', 'Interpreter', 'none');
xlabel('Head Orientation Angles [Degrees]');
ylabel('Mean Benefit [dB]');
title('SRM with Head Orientation');

% setfig(1, 12, 10);
