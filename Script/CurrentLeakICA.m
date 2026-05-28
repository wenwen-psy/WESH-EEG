function CurrentLeakICA(subname)
% not every subject had current leakage during baseline or post, run this
% when needed
load('subs_ibl_eeg.mat')
files = {dir(fullfile(ibl.path.prepro,[subname,'*raw*.set'])).name}';

for i = 1:length(files)
    sub_file = extractBefore(files{i}, '_raw');
    set_name = fullfile(ibl.path.prepro,[sub_file,'_raw_leakICA.set']);

    % run current leak ICA for baseline and post only
    if ~contains(sub_file,'Stim','IgnoreCase',true)
        if ~isfile(set_name)

            EEG = pop_loadset('filename', files{i}, 'filepath', ibl.path.prepro);

            % Using max absolute voltage to determine whether stimulator was connected.
            if max(abs(EEG.data(:))) > 50000
                fprintf('\n--- Massive Leakage Detected in %s: Running ICA ---\n', sub_file);
                pop_eegplot(EEG,1,0,1)
                drawnow
                pause

                % Check for rank deficiency if channels were rejected/interpolated
                dataRank = sum(eig(cov(double(EEG.data'))) > 1e-6);

                if dataRank < EEG.nbchan
                    fprintf('Rank deficiency detected. Running PCA-reduced ICA...\n');
                    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1, 'pca', dataRank);
                else
                    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1);
                end

                pop_saveset(EEG,'filename',set_name);
            end
        end
    end
end