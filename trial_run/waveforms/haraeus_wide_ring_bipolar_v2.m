function  stimulation_table = haraeus_wide_ring_bipolar_v2(train_interval_on, train_interval_off, amplitude, duration, asynch_frequency)

%%%%%%%%%%
% Set experiment parameters
%%%%%%%%%%
if nargin < 5
    train_interval_on   = 5;
    train_interval_off  = 5;
    duration            = 120;
    amplitude           = 100;
    asynch_frequency   	= 100;
end

%%%%%%%%%%
% Set pulse parameters
%%%%%%%%%%
pulse_width_a           = 200;
pulse_width_b        	= pulse_width_a;
amplitude_a             = amplitude;
amplitude_b             = amplitude_a;
interphase_interval     = 53;

% There is a timing issue with higher asynchronous frequencies where you
% have to overshoot to get what you want.
% The following switch gives the frequencies of interest

switch asynch_frequency
    case 7 % 14 Hz
        frequency = 16;
    case 12 % 24 Hz
        frequency = 24;
    case 31 % 62 Hz
        frequency = 63;
    case 62.5 % 125 Hz
        frequency = 127;
    case 72 % 144 Hz
        frequency = 146;
    case 100 % 200 Hz
        frequency = 205;

end

n_pulses        = 1;
AF              = 1;
CF              = 0;

n_programs      = 2;
n_repeats       = train_interval_on * frequency / n_programs;

electrode_configuration = {'wide_ring_bipolar'}; % Needs to be a cell for the table entry below
stimulation_table       = [];

%%%%%%%%%%
% Configure asynchronous pulse train
%%%%%%%%%%

% Default order of implanted electrode

n_modules               = 16;

% Configure asynchronous pulse train
anterior_ventral        = 1;
anterior_dorsal         = 13;
posterior_ventral       = 2;
posterior_dorsal        = 20;

%%%%%%%%%%
% Configure experiment
%%%%%%%%%%
n_repetitions           = floor(duration / (train_interval_on + train_interval_off)); % Times pulse train + interval are repeated

% Configure the stimulator
stimulator = configure_stimulator(n_modules);

% Setup the cleanUp function
finishup    = onCleanup(@() clean_up(stimulator));

% Program our stimulation waveform 
stimulator.setStimPattern('waveform',1,...  % We can define multiple waveforms and distinguish them by ID
    'polarity',CF,...                 % 0=CF, 1=AF
    'pulses',n_pulses,...                   % Number of pulses in stim pattern
    'amp1',amplitude_a,...                        % Amplitude in uA
    'amp2',amplitude_b,...                        % Amplitude in uA
    'width1',pulse_width_a,...                    % Width for first phase in us
    'width2',pulse_width_b,...                    % Width for second phase in us
    'interphase',interphase_interval,...             % Time between phases in us
    'frequency',frequency);                     % Frequency determines time between biphasic pulses

% Program our stimulation waveform 
stimulator.setStimPattern('waveform',2,...  % We can define multiple waveforms and distinguish them by ID
    'polarity',AF,...                           % 0=CF, 1=AF
    'pulses',n_pulses,...                       % Number of pulses in stim pattern
    'amp1',amplitude_a,...                      % Amplitude in uA
    'amp2',amplitude_b,...                      % Amplitude in uA
    'width1',pulse_width_a,...                  % Width for first phase in us
    'width2',pulse_width_b,...                  % Width for second phase in us
    'interphase',interphase_interval,...        % Time between phases in us
    'frequency',frequency);                     % Frequency determines time between biphasic pulses

% Create a program sequence using any previously defined waveforms (we only have one)

stimulator.beginSequence;                   % Begin program definition

stimulator.beginGroup
stimulator.autoStim(anterior_dorsal, 1);      
stimulator.autoStim(anterior_ventral, 2);
stimulator.endGroup

if asynch_frequency == 7
    stimulator.wait(9) 
end

stimulator.beginGroup
stimulator.autoStim(posterior_dorsal, 1);      
stimulator.autoStim(posterior_ventral, 2);
stimulator.endGroup

if asynch_frequency == 7
    stimulator.wait(9) 
end

stimulator.endSequence;                     % End program definition

% Log stimulation start
for c1 = 1:n_repetitions

    % Play our program; number of repeats
    cbmex('open')
    t_start = cbmex('time');
    
    stimulator.play(0);
    
    stimulation_row = table(t_start, duration, amplitude_a, amplitude_b, asynch_frequency, interphase_interval, ...
        pulse_width_a, pulse_width_b, train_interval_on, train_interval_off, electrode_configuration);
    
    stimulation_table = [stimulation_table; stimulation_row];
    stimulation_row
    
 	pause(train_interval_on)
    stimulator.stop();
    pause(train_interval_off)   
    
%     stimulator.play(floor(n_repeats));
%  	pause(train_interval_on)
% 
%     pause(train_interval_off)
% 
%     stimulation_row = table(t_start, duration, amplitude_a, amplitude_b, asynch_frequency, interphase_interval, ...
%         pulse_width_a, pulse_width_b, train_interval_on, train_interval_off, electrode_configuration);
%     
%     stimulation_table = [stimulation_table; stimulation_row];
%     stimulation_row

    cbmex('close')

end

% Close it all
cbmex('close')
stimulator.disconnect;
clear stimulator

end

function stimulator = configure_stimulator(n_modules)

% Create stimulator object
stimulator = cerestim96();

% Check for stimulation
DeviceList = stimulator.scanForDevices();

% Select a stimulator
stimulator.selectDevice(DeviceList(1));

% Connect to the stimulator
stimulator.connect; 

% Activate modules
d_info = stimulator.deviceInfo();
for c1 = 1:n_modules
    if d_info.moduleStatus(c1) ~= 1
        stimulator.enableModule(c1)
    end
end

end

function clean_up(stimulator)
if stimulator.isConnected()
    stimulator.stop()
    stimulator.disconnect
    cbmex('close')
end

end