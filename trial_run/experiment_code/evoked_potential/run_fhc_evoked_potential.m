AMPLITUDE   = 300;
FREQUENCY   = 10;
% PHASE       = 'monopolar';
% PHASE       = 'inward';
PHASE       = 'outward';
N_PULSES    = 100;
file_path   = ep_helper(@FHC_bipolar_evoked_potential, FREQUENCY, AMPLITUDE, PHASE, N_PULSES);


%% %%%%%%% 
% Load and display EP
%%%%%%%%%
pause(1)

stim_table_path     = strrep(file_path, '.ns6', '_stimulation_table.mat');
load(stim_table_path);

% Load raw LFP data
raw_data_path       = file_path;
raw_data_struct   	= openNSx(raw_data_path);
sampling_rate       = raw_data_struct.MetaTags.SamplingFreq;

sync_data           = double(raw_data_struct.Data(16,:));

data                = double(raw_data_struct.Data(1:6,:))';
data                = lowpass(data,1000, sampling_rate, 'StopbandAttenuation', 500);

artifact_offset     = -0.001;
segment_length      = 0.2;
segment_length_idx  = segment_length * sampling_rate;

% Subtract out mean
data            = data - mean(data,2);

% Get TTL onset times
pulse_onset_times   = detect_pulse_onset(sync_data, ...
    stimulation_table.t_start(1), 10, sampling_rate);

t = artifact_offset*1000:1000/sampling_rate:(artifact_offset + segment_length)*1000;

clear pulse_segment
for c1 = 1:size(pulse_onset_times,2)
    segment_start_idx       = floor((pulse_onset_times(c1) + artifact_offset) * sampling_rate) ;
    segment_end_idx         = segment_start_idx + segment_length_idx;

    pulse_segment(c1,:,:)   = data(segment_start_idx:segment_end_idx,:) - mean(data(segment_start_idx:segment_end_idx,:),2);
end
%%
figure
ep_bipolar  = squeeze(pulse_segment(:,:,1) - pulse_segment(:,:,3));
%     ep_bipolar  = squeeze(pulse_segment(:,:,1));
ep_mean     = mean(ep_bipolar);

ep_std      = std(ep_bipolar);
ep_se       = ep_std / sqrt(size(pulse_segment,1));
ep_ci       = ep_se * 1.96;

hold on
plot(t, ep_mean, 'k')
plot(t, ep_mean + ep_ci, 'r')
plot(t, ep_mean - ep_ci, 'r')


% subplot(2,2,1)
% title(sprintf('Ch 1-3'))
% hold on
% plot(t,squeeze(pulse_segment(:,1,:) - pulse_segment(:,3,:)), 'color', .5*[1 1 1], 'LineWidth', 1)
% plot(t,squeeze(mean(pulse_segment(:,1,:) - pulse_segment(:,3,:),1)),  'LineWidth', 2)
% 
% subplot(2,2,2)
% title(sprintf('Ch 2-4'))
% hold on
% plot(t,squeeze(pulse_segment(:,2,:) - pulse_segment(:,4,:)), 'color', .5*[1 1 1], 'LineWidth', 1)
% plot(t,squeeze(mean(pulse_segment(:,2,:) - pulse_segment(:,4,:),1)),  'LineWidth', 2)
% 
% 
% subplot(2,2,3)
% title(sprintf('Ch 1-4'))
% hold on
% plot(t,squeeze(pulse_segment(:,1,:) - pulse_segment(:,4,:)), 'color', .5*[1 1 1], 'LineWidth', 1)
% plot(t,squeeze(mean(pulse_segment(:,1,:) - pulse_segment(:,4,:),1)),  'LineWidth', 2)
% 
% subplot(2,2,4)
% title(sprintf('Ch 2-3'))
% hold on
% plot(t,squeeze(pulse_segment(:,2,:) - pulse_segment(:,3,:)), 'LineWidth', 1)
% plot(t,squeeze(mean(pulse_segment(:,2,:) - pulse_segment(:,3,:),1)),  'LineWidth', 2)
% % plot(t,squeeze(pulse_segment(:,1,:)), 'color', .5*[1 1 1], 'LineWidth', 1)
% % plot(t,squeeze(mean(pulse_segment(:,1,:),1)),  'LineWidth', 2)
% 
