clear;
close all
load("subs_ibl_eeg.mat")
% subname = ibl.subs{i};
subname = 'S01';
addpath(genpath(ibl.path.eeglab));
files = {dir(fullfile(ibl.path.prepro,[subname,'*raw_leakICA*.set'])).name}';

for i = 1:length(files)
    fprintf('\n\n\n\n---------- %s ---------\n\n\n\n', files{i});
    sub_file = extractBefore(files{i}, '_raw_leakICA');
    set_name = fullfile(ibl.path.prepro,files{i});
    EEG = pop_loadset('filename',set_name);

    EEG = pop_iclabel(EEG,'default');

    artefactN = 15;
    pop_selectcomps(EEG,1:artefactN);
    ica_activations = eeg_getdatact(EEG, 'component', 1:artefactN);

    % =====================================================================
    % PLOT: Mean vs. Max Absolute ICA Activity
    % =====================================================================

    mean_activity = mean(abs(ica_activations), 2);
    max_activity = max(abs(ica_activations), [], 2);

    fig_mean = figure('Color', 'w','Position', [100, 100, 1000, 400]);

    subplot(1, 2, 1);axis square
    bar(1:artefactN, mean_activity, 'FaceColor', [0.2 0.4 0.6], 'EdgeColor', 'none');
    % Apply the 100 threshold line to the Max plot to match our detection logic
    yline(100, '--', 'Peak Threshold', 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left');
    box off;
    set(gca, 'TickDir', 'out', 'FontSize', 12, 'LineWidth', 1);
    title('Mean Absolute Amplitude', 'FontSize', 14);
    xlabel('Independent Component ID', 'FontSize', 12);
    ylabel('Amplitude (\muV)', 'FontSize', 12);
    xlim([0 artefactN+1]);

    subplot(1, 2, 2);axis square
    bar(1:artefactN, max_activity, 'FaceColor', [0.8 0.4 0.4], 'EdgeColor', 'none');
    yline(100, '--', 'Peak Threshold', 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left');
    box off;
    set(gca, 'TickDir', 'out', 'FontSize', 12, 'LineWidth', 1);
    title('Max (Peak) Absolute Amplitude', 'FontSize', 14);
    xlabel('Independent Component ID', 'FontSize', 12);
    xlim([0 artefactN+1]);
    sgtitle(sprintf('ICA Activation Profiling - %s', sub_file), 'Interpreter', 'none');
    subj_fig = fullfile(ibl.path.Figs,'Preproc',subname);

    exportgraphics(fig_mean, fullfile(subj_fig, [sub_file, '_ICA_ActivityProfile.png']));

    % =====================================================================
    % Automated Suggestion Logic
    % =====================================================================
    suggested_rmv = [];
    for c = 1:artefactN
        % Check if the maximum absolute peak of the component exceeds 100
        if mean(abs(ica_activations(c, :))) > 100
            suggested_rmv = [suggested_rmv, c];
        end
    end

    fprintf('\n========================================================\n');
    if ~isempty(suggested_rmv)
        fprintf('💡 AUTOMATED SUGGESTION:\n');
        fprintf('Components [%s] have peak activations > 100.\n', num2str(suggested_rmv));
        fprintf('These are highly likely to be the TI current leakage.\n');
    else
        fprintf('💡 AUTOMATED SUGGESTION:\n');
        fprintf('No top components exceeded the 100 threshold.\n');
    end
    fprintf('========================================================\n\n');
    % =====================================================================

    % Plot just those components
    eegplot(ica_activations, ...
        'srate', EEG.srate, ...
        'title', 'Top ICA Components', ...
        'dispchans', artefactN, ...
        'events', EEG.event);

    rejICA = fullfile(ibl.path.ana,'rmvICA',[sub_file,'_leakICA_rmvID.mat']);
    if isfile(rejICA)
        load(rejICA)
        disp(rmvd)
    end

    pause
    rmvd  = input('enter to-be-rmvd cmp ID with brackets[]:');
    EEG = pop_subcomp(EEG,rmvd,0);

    % Plot the cleaned physical channel data to verify
    pop_eegplot(EEG,1,0,1);
    drawnow;
    fig = gcf;
    exportgraphics(fig, fullfile(subj_fig,[sub_file '_postLeakICA.png']));
    pause

    set_name = [sub_file,'_postLeakICA.set'];
    EEG = pop_saveset(EEG, 'filename', set_name, 'filepath', ibl.path.prepro);
    save(rejICA,'rmvd')
end