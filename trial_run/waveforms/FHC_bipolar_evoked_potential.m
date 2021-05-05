function  stimulation_table = FHC_bipolar_evoked_potential(train_interval_on, train_interval_off, amplitude, duration, frequency, phase)

%%%%%%%%%%
% Set experiment parameters
%%%%%%%%%%
if nargin < 5
    train_interval_on   = 60;
    train_interval_off  = 0;
    duration            = 60;
    amplitude           = 900;
    frequency           = 1;
end

%%%%%%%%%%
% Set pulse parameters for a 1:3 asymmetric biphasic pulse
%%%%%%%%%%
pulse_width_a           = 100;
pulse_width_b        	= 100;
amplitude_a             = amplitude;
amplitude_b             = amplitude_a;
interphase_interval     = 53;

n_pulses                = 1;
CF                      = 0;
AF                      = 1;

switch phase
    case 'inward'
        dorsal_phase    = CF;
        ventral_phase   = AF;
    case 'outward'
        dorsal_phase    = AF;
        ventral_phase   = CF;
    case 'monopolar'
        dorsal_phase    = CF;
        ventral_phase   = CF;
end

phase = {phase};
% n_programs              = 2;
% n_repeats               = train_interval_on * frequency;

electrode_configuration = {'bipolar evoked potential'}; % Needs to be a cell for the table entry below
stimulation_table       = [];

%%%%%%%%%%
% Configure  pulse train
%%%%%%%%%%

% Default order of implanted electrode
n_modules               = 2;

% Assign channels
stn_ventral             = 1;
stn_dorsal              = 2;

%%%%%%%%%%
% Configure experiment
%%%%%%%%%%
n_repetitions           = floor(duration / (train_interval_on + train_interval_off)); % Times pulse train + interval are repeated

% Configure the stimulator
stimulator = configure_stimulator(n_modules);

% Setup the cleanUp function
finishup    = onCleanup(@() clean_up(stimulator));

% Program our stimulation waveform 
stimulator.setStimPattern('waveform',1,...      % We can define multiple waveforms and distinguish them by ID
    'polarity',dorsal_phase,...                           % 0=CF, 1=AF
    'pulses',n_pulses,...                       % Number of pulses in stim pattern
    'amp1',amplitude_a,...                     	% Amplitude in uA
    'amp2',amplitude_b,...                     	% Amplitude in uA
    'width1',pulse_width_a,...                	% Width for first phase in us
    'width2',pulse_width_b,...                	% Width for second phase in us
    'interphase',interphase_interval,...      	% Time between phases in us
    'frequency',20);                           % Frequency determines time between biphasic pulses

% Program our stimulation waveform 
stimulator.setStimPattern('waveform',2,...      % We can define multiple waveforms and distinguish them by ID
    'polarity',ventral_phase,...                % 0=CF, 1=AF
    'pulses',n_pulses,...                       % Number of pulses in stim pattern
    'amp1',amplitude_a,...                      % Amplitude in uA
    'amp2',amplitude_b,...                      % Amplitude in uA
    'width1',pulse_width_a,...                  % Width for first phase in us
    'width2',pulse_width_b,...                  % Width for second phase in us
    'interphase',interphase_interval,...        % Time between phases in us
    'frequency',1500);                           % Frequency determines time between biphasic pulses


% Define program definition with configured waveforms
stimulator.beginSequence;                   % Begin program definition

stimulator.beginGroup
stimulator.autoStim(stn_dorsal, 1);      
stimulator.autoStim(stn_ventral, 2);
stimulator.endGroup

stimulator.wait(1000/frequency)
stimulator.endSequence;                     % End program definition

% Log stimulation start
for c1 = 1:n_repetitions

    % Play our program; number of repeats
    cbmex('open')
    t_start = cbmex('time');
    
    stimulator.play(0);
    
    stimulation_row = table(t_start, duration, amplitude_a, amplitude_b, frequency, interphase_interval, ...
        pulse_width_a, pulse_width_b, train_interval_on, train_interval_off, electrode_configuration, phase);
    
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