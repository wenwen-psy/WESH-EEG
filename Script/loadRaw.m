function loadRaw(subname)

%%
load('subs_ibl_eeg.mat')
sesN = length({dir(fullfile(ibl.path.data,subname,'EEG','*Baseline*.vhdr')).name});
for ses_i = 1:sesN

    all_ses = dir(fullfile(ibl.path.data,subname,'EEG',['*Session',num2str(ses_i),'*.vhdr']));
    for p = 1:length(all_ses)
        tmp_ses = all_ses(p);
        sub_file = tmp_ses.name(1:end-5);
        set_name = fullfile(ibl.path.prepro,[sub_file,'_raw.set']);

        if ~isfile(set_name)
            EEG = pop_loadbv(tmp_ses.folder,tmp_ses.name);
            EEG = pop_resample(EEG,500);
            EEG = pop_chanedit(EEG, 'lookup',fullfile(ibl.path.eeglab,'plugins','dipfit5.4','standard_BESA','standard-10-5-cap385.elp'));

            % TP10 was online reference for eeg recording, add a dummy TP10
            chanID = 64;
            EEG.nbchan      = chanID;
            EEG.data(chanID,:)  = zeros(1,EEG.pnts);
            EEG.chanlocs(chanID).labels = 'TP10';
            EEG = pop_chanedit(EEG, 'changefield',{chanID 'labels' 'TP10'},'lookup',fullfile(ibl.path.eeglab,'plugins','dipfit5.4','standard_BESA','standard-10-5-cap385.elp'), ...
                'eval','chans = pop_chancenter( chans, [],[]);');
            pop_saveset(EEG,'filename',set_name);

        else
            EEG = pop_loadset('filename',set_name);
            pop_eegplot(EEG,1,0,1)
            drawnow;
            fig = gcf;
            subj_dir = fullfile(ibl.path.Figs,'Preproc',subname);
            if ~isfolder(subj_dir)
                mkdir(subj_dir)
            end
            exportgraphics(fig, fullfile(subj_dir,[sub_file '_Raw.png']));
        end
        continue
        %% filter data
        set_name = fullfile(ibl.path.prepro,[sub_file,'_rawFiltered.set']);

        if ~isfile(set_name)
            EEG = pop_eegfiltnew(EEG,'locutoff', 1, 'plotfreqz', 0);% 1Hz high-pass removes slow sweat/drift artifacts
            % note,

        else
            EEG = pop_loadset('filename',set_name);
            pop_eegplot( EEG, 1, 0, 1);
            drawnow;
            fig = gcf;
            subj_dir = fullfile(ibl.path.Figs,'Preproc',subname);
            exportgraphics(fig, fullfile(subj_dir,[sub_file '_rawFiltered.png']));
            continue
        end

        %% epoching
        set_name = fullfile(ibl.path.prepro,[sub_file,'_rawFiltered.set']);
        EEG = pop_loadset('filename',set_name);
        if contains(sub_file,'Baseline','IgnoreCase',true)
            % Baseline_start  = 201;
            % Baseline_end    = 202;
            markers = {'S201'}; % onset
            timelimits = [0 60*5];% 5min for baseline

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

            % if session == strcmp('A',session) % sham
            %     % Baseline beginning and end
            % StimOn_Start  = 181;
            % StimOn_End    = 182;
            % StimOFF_End = 184;
            % elseif session == strcmp('B',session) % dual
            %     % dual beginning and end
            %     StimOn_Start  = 161;
            %     StimOn_End    = 162;
            %     StimOFF_End = 164;

            % dual-5Hz
            %     StimOn_Start  = 191;
            %     StimOn_End    = 192;
            %     StimOFF_End = 194;

            % % elseif session == strcmp('C',session) % str
            %     % str beginning and end
            % StimOn_Start  = 171;
            % StimOn_End    = 172;
            % StimOFF_End = 174;
            % elseif session == strcmp('D',session) % temp
            %     % temp beginning and end
            % StimOn_Start  = 131;
            % StimOn_End    = 132;
            % StimOFF_End = 134;
            % end

        elseif contains(sub_file,'Post','IgnoreCase',true)
            % Baseline_start  = 201;
            % Baseline_end    = 202;
            markers = {'S201'}; % onset
            timelimits = [0 60*5];% 5min for baseline

            EEG = pop_epoch(EEG,markers,timelimits);
            set_name = fullfile(ibl.path.prepro,[sub_file,'_epoch.set']);
            pop_saveset(EEG,'filename',set_name);

        end
    end
end