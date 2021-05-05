function [file_path, log_path] = ep_helper(waveform_function, frequency, amplitude, phase, n_pulses)

stimulation_table   = [];

[data_file_name, data_file_path]  = uigetfile('D:\*');
if data_file_path == 0
    return;
end
log_path            = [data_file_path data_file_name(1:end-4) '_stimulation_table.mat'];
file_path           = [data_file_path data_file_name(1:end-4) '.ns6'];

train_interval_on   = floor(n_pulses / frequency);
train_interval_off  = 3;
duration            = floor(n_pulses / frequency) + 3;


stimulation_row     = waveform_function(train_interval_on, train_interval_off, amplitude, duration, frequency, phase);

stimulation_table   = [stimulation_table; stimulation_row];

save(log_path,'stimulation_table')

% end


end

