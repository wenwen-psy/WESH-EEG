function epochData(subname)

load('subs_ibl_eeg.mat')

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
