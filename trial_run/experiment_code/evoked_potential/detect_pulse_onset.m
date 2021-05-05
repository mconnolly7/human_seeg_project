function pulse_onset_times = detect_pulse_onset(pulse_data, t_start, frequency, sampling_rate, threshold)
%DETECT_PULSE_ONSET Summary of this function goes here

% n_pulses                    = floor(train_interval_on * frequency);

d_pulse_data            = diff(pulse_data);

if nargin < 6
    threshold = std(d_pulse_data);
end

ttl_start_idx               = floor((t_start - .07) * sampling_rate);
ttl_end_idx                 = floor((t_start + .07) * sampling_rate);

d_pulse_segment             = d_pulse_data(ttl_start_idx:ttl_end_idx);

onset_idx                   = find(d_pulse_segment > 2*threshold, 1);

index                       = 1;

while ~isempty(onset_idx)
    pulse_onset_times(index)    = (ttl_start_idx + onset_idx)/sampling_rate;

    ttl_start_idx               = floor((pulse_onset_times(index) + 1/frequency - .07) * sampling_rate);
    ttl_end_idx                 = floor((pulse_onset_times(index) + 1/frequency + .07) * sampling_rate);
    
    d_pulse_segment             = d_pulse_data(ttl_start_idx:ttl_end_idx);

    onset_idx                   = find(d_pulse_segment > threshold, 1);
    index                       = index + 1;
end
end
