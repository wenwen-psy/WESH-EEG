ReadSubj

%% eeg preprocessing
clear;
load("subs_ibl_eeg.mat")
addpath(genpath(ibl.path.eeglab))
addpath(ibl.path.ana)
for i =1%:length(ibl.subs)
    subname = ibl.subs{i};
    loadRaw(subname)
    CurrentLeakICA(subname)
    CurrentLeakICA_post
    epochData(subname)
    rmvArtifact(subname)
    %
    % doICA(subname)
    %
    % postICA %
    % genCleanData(subname)% will generate new data set
    % sanityCheck(subname)% ERP and time freq
    % singleRT_feedback_ratio(subname)
end
