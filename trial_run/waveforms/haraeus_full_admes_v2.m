function  stimulation_table = haraeus_full_admes_v2(train_interval_on, train_interval_off, amplitude, duration, asynch_frequency)

%%%%%%%%%%
% Set experiment parameters
%%%%%%%%%%
if nargin < 5
    train_interval_on   = 5;
    train_interval_off  = 5;
    duration            = 120;
    amplitude           = 400;
    asynch_frequency   	= 72;
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
    case 7 % 84Hz
        frequency = 85;
    case 12 % 144Hz
        frequency = 147;
    case 31 % 480Hz
        frequency = 400;
    case 62.5 % 750Hz
        frequency = 810;
    case 72 % 864Hz
        frequency = 945;
end

n_pulses    = 1;
polarity    = 0;
n_channels  = 12;
n_repeats   = train_interval_on * frequency / n_channels;

electrode_configuration = {'full_admes'}; % Needs to be a cell for the table entry below
stimulation_table       = [];

%%%%%%%%%%
% Configure asynchronous pulse train
%%%%%%%%%%

% Default order of implanted electrode
electrode_ant           = 1:2:24;
electrode_pst           = 2:2:24;

n_modules               = 2;
n_channels              = size(electrode_ant,2);

% Seed the random number generator
rng(0)
stim_order_ant              = randperm(n_channels);
stim_order_pst              = randperm(n_channels);

%%%%%%%%%%
% Configure experiment
%%%%%%%%%%
n_repetitions           = floor(duration / (train_interval_on + train_interval_off)); % Times pulse train + interval are repeated

%%% Example Experiment Sequence %%%
% train_duration          = 3; % Duration of asynchronous pulse train (seconds)
% inter_train_duration    = 3; % Duration of inter-pulse-train-interval (seconds)
%
%             EXPERIMENT 1                      
% ***---***---***--- ------------------  
%

% Configure the stimulator
stimulator = configure_stimulator(n_modules);

% Setup the cleanUp function
finishup    = onCleanup(@() clean_up(stimulator));

% Program our stimulation waveform 
stimulator.setStimPattern('waveform',1,...  % We can define multiple waveforms and distinguish them by ID
    'polarity',polarity,...                 % 0=CF, 1=AF
    'pulses',n_pulses,...                   % Number of pulses in stim pattern
    'amp1',amplitude_a,...                        % Amplitude in uA
    'amp2',amplitude_b,...                        % Amplitude in uA
    'width1',pulse_width_a,...                    % Width for first phase in us
    'width2',pulse_width_b,...                    % Width for second phase in us
    'interphase',interphase_interval,...             % Time between phases in us
    'frequency',frequency);                 % Frequency determines time between biphasic pulses

% Create a program sequence using any previously defined waveforms (we only have one)

stimulator.beginSequence;                   % Begin program definition

for c1 = 1:n_channels
    stimulator.beginGroup
    
    channel_1 = electrode_ant(stim_order_ant(c1));
    channel_2 = electrode_pst(stim_order_pst(c1));
    
    stimulator.autoStim(channel_1, 1);      
    stimulator.autoStim(channel_2, 1);

    stimulator.endGroup
end

stimulator.endSequence;         % End program definition

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