function epochData(subname)

load('subs_ibl_eeg.mat')

% 1. Find all raw files for this subject to establish the base names
raw_files = dir(fullfile(ibl.path.prepro, [subname, '*_raw.set']));

for i = 1:length(raw_files)
    
    % Extract the base name (e.g., 'S01_BaselineSession1_STR')
    sub_file = extractBefore(raw_files(i).name, '_raw.set');
    
    % Define the target file paths
    postLeakICA_path = fullfile(ibl.path.prepro, [sub_file, '_postLeakICA.set']);
    raw_path         = fullfile(ibl.path.prepro, [sub_file, '_raw.set']);
    
    % =====================================================================
    % 2. DYNAMIC LOADING LOGIC: Check for cleaned data, fallback to raw
    % =====================================================================
    if isfile(postLeakICA_path)
        fprintf('\n--- Found cleaned leakage data. Loading: %s ---\n', [sub_file, '_postLeakICA.set']);
        EEG = pop_loadset('filename', [sub_file, '_postLeakICA.set'], 'filepath', ibl.path.prepro);
        
    elseif isfile(raw_path)
        fprintf('\n--- No leakage cleaning found. Loading raw fallback: %s ---\n', [sub_file, '_raw.set']);
        EEG = pop_loadset('filename', [sub_file, '_raw.set'], 'filepath', ibl.path.prepro);
        
    else
        warning('Neither postLeakICA nor raw file found for %s. Skipping...', sub_file);
        continue;
    end
    % =====================================================================
    
    
    %% 3. Epoching
    if contains(sub_file,'Baseline','IgnoreCase',true)
        markers = {'S201'}; % onset
        timelimits = [0 60*5]; % 5min for baseline
        
        EEG = pop_epoch(EEG,markers,timelimits);
        set_name = fullfile(ibl.path.prepro,[sub_file,'_epoch.set']);
        pop_saveset(EEG,'filename',set_name);
        
    elseif contains(sub_file,'Stim','IgnoreCase',true)
        markers_on = {'S181','S171','S161','S131','S191'};
        timelimits = [0 60*3]; % stim on
        EEG_on = pop_epoch(EEG,markers_on,timelimits);
        set_name = fullfile(ibl.path.prepro,[sub_file,'_on_epoch.set']);
        pop_saveset(EEG_on,'filename',set_name);
        
        markers_off = {'S182','S172','S162','S132','S192'};
        timelimits = [0 60*2]; % stim off
        EEG_off = pop_epoch(EEG,markers_off,timelimits);
        set_name = fullfile(ibl.path.prepro,[sub_file,'_off_epoch.set']);
        pop_saveset(EEG_off,'filename',set_name);
        
    elseif contains(sub_file,'Post','IgnoreCase',true)
        markers = {'S201'}; % onset
        timelimits = [0 60*5]; % 5min for baseline
        
        EEG = pop_epoch(EEG,markers,timelimits);
        set_name = fullfile(ibl.path.prepro,[sub_file,'_epoch.set']);
        pop_saveset(EEG,'filename',set_name);
    end
    
end
end