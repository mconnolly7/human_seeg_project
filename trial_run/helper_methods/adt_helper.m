function adt_helper(waveform_function)

stimulation_table   = [];

amplitude           = inputdlg('Stimulation Amplitude (uA):','ADT',1, {'100'});
amplitude           = str2double(amplitude{1});

asynch_frequency    = inputdlg('Asynchronous Frequency (Hz):','ADT',1, {'7'});
asynch_frequency    = str2double(asynch_frequency{1});

[data_file_name, data_file_path]  = uigetfile('C:\Users\User\Documents\BLACKROCK_LOCAL_FILE_STORAGE\*');
log_path            = [data_file_path data_file_name(1:end-4) '_stimulation_table.mat'];

train_interval_on   = 5;
train_interval_off  = 5;
duration            = 120;
pulse_width         = 200;

stimulation_row     = waveform_function(train_interval_on, train_interval_off, amplitude, duration, asynch_frequency, pulse_width);
stimulation_table   = [stimulation_table; stimulation_row];

save(log_path,'stimulation_table')

end

