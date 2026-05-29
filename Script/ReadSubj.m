clear;
ibl.path.ana = '/Users/wenwen/Documents/BU/WESH/IBL_Resting_EEG/WESH-EEG/Script';
ibl.path.data = '/Users/wenwen/Documents/BU/WESH/IBL_Resting_EEG/Data';
ibl.path.Figs = '/Users/wenwen/Documents/BU/WESH/IBL_Resting_EEG/Figures';
ibl.path.prepro = '/Users/wenwen/Documents/BU/WESH/IBL_Resting_EEG/PreproEEG';


ibl.path.eeglab = "/Users/wenwen/Documents/MatlabToolbox/eeglab2026.0.0";
ibl.path.ft = "/Users/wenwen/Documents/MatlabToolbox/fieldtrip-20240704";

subjects = dir(fullfile(ibl.path.data,'S*'));
subjects = {subjects.name};
ibl.subs = subjects;


save(fullfile(ibl.path.ana,"subs_ibl_eeg.mat"),"ibl")