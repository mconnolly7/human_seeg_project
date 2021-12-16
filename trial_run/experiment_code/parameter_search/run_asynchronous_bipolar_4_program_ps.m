a1 = 0.1:.1:.8; f1 = 7 * ones(size(a1));
a2 = 0.1:.1:.6; f2 = 50 * ones(size(a2));
a3 = 0.1:.1:.4; f3 = 90 * ones(size(a3));
a4 = 0.1:.1:.5; f4 = 125 * ones(size(a4));

stimulation_parameters      = [a1 a2 a3 a4; f1 f2 f3 f4];
stimulation_parameters      = combvec(stimulation_parameters, [100 300 450])';

rng(0)
rand_idx                 	= randperm(size(stimulation_parameters,1));
stimulation_parameters      = stimulation_parameters(rand_idx,:);  

ps_helper(@asynchronous_bipolar_4_program, stimulation_parameters)