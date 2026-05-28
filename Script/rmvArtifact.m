function rmvArtifact(subname)
close all
load('subs_ibl_eeg.mat')
files = {dir(fullfile(ibl.path.prepro,[subname,'*epoch*.set'])).name}';
%%
for i = 1:length(files)

    sub_file = extractBefore(files{i}, '_epoch');

    EEG = pop_loadset('filename',fullfile(ibl.path.prepro,files{i}));
    pop_eegplot(EEG,1,0,1)
    drawnow;
    fig = gcf;
    subj_dir = fullfile(ibl.path.Figs,'Preproc',subname);
    exportgraphics(fig, fullfile(subj_dir,[sub_file '_trace_before_cleanRaw.png']));

    %% depending on whether there's stimulation artefact, perform full or partial cleanning (bad channel interpolate only)
    % 1. Save the original, complete channel locations
    original_chanlocs = EEG.chanlocs;

    % 2. Detect Stimulation vs. Baseline/post
    % Using max absolute voltage. 50000 is experience based choice
    if max(abs(EEG.data(:))) > 50000

        fprintf('\n---Bypassing Time-Domain Cleaning ---\n');
        EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion', 6, 'ChannelCriterion', 0.8, ...
            'LineNoiseCriterion', 5, 'Highpass', 'off', 'BurstCriterion', 'off', ...
            'WindowCriterion', 'off', 'BurstRejection', 'off', 'Distance', 'Euclidian');

    else

        fprintf('\n---Running Full Cleaning ---\n');
        EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion', 6, 'ChannelCriterion', 0.8, ...
            'LineNoiseCriterion', 5, 'Highpass', 'off', 'BurstCriterion', 20, ...
            'WindowCriterion', 0.25, 'BurstRejection', 'on', 'Distance', 'Euclidian');
    end

    % 3. Interpolate the missing channels back into the dataset
    EEG = pop_interp(EEG, original_chanlocs, 'spherical');

    pop_eegplot(EEG,1,0,1)
    drawnow
    fig = gcf;
    exportgraphics(fig, fullfile(ibl.path.Figs,'Preproc',subname,[sub_file '_trace_after_cleanRaw.png']));

    set_name = fullfile(ibl.path.prepro,[sub_file,'_preICA.set']);
    pop_saveset(EEG,'filename',set_name);

end

