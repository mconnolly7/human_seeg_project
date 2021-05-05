function  ps_helper(waveform_function, amplitude)

stimulation_table   = [];

[data_file_name, data_file_path]  = uigetfile('S:\ADMES\*');
log_path            = [data_file_path data_file_name(1:end-4) '_stimulation_table.mat'];

if isempty(data_file_name)
    return;
end

param_f             = [ 7 12 31 62.5 72];

n_reps              = 10;
param_f_rand        = [];
rng(0)

for c1 = 1:n_reps
    rand_idx        = randperm(size(param_f,2));
    param_f_rand    = [param_f_rand param_f(rand_idx)];   
end

train_interval_on   = 5;
train_interval_off  = 15;
duration            = 20;

for c1 = 1:size(param_f_rand,2)
    fprintf('Sample: %d\n', c1)
    
    asynch_frequency    = param_f_rand(c1);
    
    stimulation_row     = waveform_function(train_interval_on, train_interval_off, amplitude, duration, asynch_frequency);
    
    stimulation_table   = [stimulation_table; stimulation_row];
    
    save(log_path,'stimulation_table')

end

end

