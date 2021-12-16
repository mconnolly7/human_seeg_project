function  ps_helper(waveform_function, stimulation_parameters)

stimulation_table   = [];

[data_file_name, data_file_path]  = uigetfile('C:\Users\User\Documents\BLACKROCK_LOCAL_FILE_STORAGE\*');
log_path            = [data_file_path data_file_name(1:end-4) '_stimulation_table.mat'];

if isempty(data_file_name)
    return;
end

% param_f             = [ 7 12 31 62.5 72];
% 
% n_reps              = 10;
% param_f_rand        = [];
% rng(0)

% for c1 = 1:n_reps
%     rand_idx        = randperm(size(param_f,2));
%     param_f_rand    = [param_f_rand param_f(rand_idx)];   
% end

train_interval_on   = 5;
train_interval_off  = 5;
duration            = 10;

for c1 = 1:size(stimulation_parameters,2)
    fprintf('Sample: %d\n', c1)
   
    amplitude           = stimulation_parameters(c1,1);
    asynch_frequency    = stimulation_parameters(c1,2);
    pulse_width         = stimulation_parameters(c1,3);
    
    stimulation_row     = waveform_function(train_interval_on, train_interval_off, amplitude, duration, asynch_frequency, pulse_width);
    
    stimulation_table   = [stimulation_table; stimulation_row];
    
    save(log_path,'stimulation_table')

end

end

