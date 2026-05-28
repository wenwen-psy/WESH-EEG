clear;
close all
load('subs.mat');
addpath(genpath(Dir.eeglab))
%------ inphase
% 03-06
% S0102, removed IC 29 30, worse
% S0102 ,reverse, add 35, 03-07, worse
% S0102, [ 1     2     3     7     8    11    15], is the best
% S0102, redo ICA
% S0102, [ 1     2     3     7     8    11    15]

% S0202, removed IC 41 44 45, even worse
% S0202, removed IC 45 03-07, not changes
% S0202, redo ICA
% S0202,[1 5 14 48], bad
% S0202,redo ICA
% S0202, [1     5    14    48], worse
% S0202,redo ICA
% S0202,[1 2 7 19 25]

% S25, postICA [1 2 7], PLV over right posterior
% S25, postICA [1 2 7 21 42]

% S31, post ICA [1 7], PLV all over brain
% S31, postICA [1 7 18 28 29]

% S35, postICA [ 1     2     8    26    34]
% S35, [ 1     2     8   17  20  26    34 50 62]

% S36, post ICA [1     2     3     4     5     9    13]
% S36, postICA [1     2     3     4     5     9    13 18 22 24 55]

% S39: postICA [1 10 12]
% S39: [1 10 12 37 38 51 55 56 59]

% S40: [1 9 22]
% S40: [1 9 19 21 22 25 27 30 62]
% S43: [1     3     4    16]

% S62 [1 17]
% S62 [1 17 20 33]

% S64 [1 2 3 6]
% S64 [1 2 3 6 27 30]

% S65 [1     5     7     9    15    17]
% S65 [1 15 17 28 56]
sn = 93
% S2102, removed IC 17 34 35, 
% S2102, [1     2     4    16    17    18    28 ] worse
% S2102, [1     2     4    16    17    18  ]
% S2102, redo ICA
% S2102,[1 2 4 16 17 18 25], bad
% S2102, redo ICA
% S2102, [1 2 4 16 17 18 35 ]
% S2102,redo ICA


% S2402 removed IC 26 36, better

% sn = 69
% S2702, [1 10 20], not good
% S2702, [1 10 20 25],
% S2702, redo ICA
% S2702, [1 10 20 32 33 55]
% S2702, redo ICA

% sn = 72
% S2902, [1    13    14    24    25], not good
% S2902, redo ICA
% S2902,[1 14 25]
% S2902, redo ICA
% S2902,[1 25]
% S2902, redo ICA

%------------------antiphase
% sn = 34
% S1302 

% sn = 51
% S1902, [1     2     3     4     7    10] plv too high
% S1902, [1     2     3     4     7    10 17 21 25]

genCleanData(sn)

%%
subname = subs.name{sn};

% if subs.excluded(sn)==1 || subs.stim(sn)==1
%     return
% end
set_name = fullfile(Dir.prepro,[subname,'_ICA.set']);
EEG = pop_loadset('filename',set_name);

EEG = pop_iclabel(EEG,'default');
% pop_selectcomps(EEG, [1:min([45 size(EEG.icaweights,1)])]);
pop_selectcomps(EEG,1:size(EEG.icaweights,1));
pop_eegplot( EEG, 0, 1, 1);

rejICA = fullfile(Dir.ana,'rmvICA',[subname,'_rmvID.mat']);
if isfile(rejICA)
    load(rejICA)
    disp(rmvd)
end

pause
rmvd  = input('enter to-be-rmvd cmp ID with brackets[]:');

EEG = pop_subcomp(EEG,rmvd,0); 

set_name = fullfile(Dir.prepro,[subname,'_postICA.set']);
pop_saveset(EEG,'filename',set_name);
save(rejICA,'rmvd')
genCleanData(sn)
