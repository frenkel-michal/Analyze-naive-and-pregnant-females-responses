function DATA_STRUCT = prepare_data_for_michals_analysis(datafilename,do_stims,mating_male_strain,TAKE_EPOCH,MINTRIALREQUIREMENT,PTHRESH,take_units,manual_selection)

load(datafilename);

% Construct arrays to include all relevant response properties
BASELINES = [];
SHAPES = [];
MODS = [];
PEAKS = [];
RESP = [];
PVAL = [];
ALL_MODS  = [];
SESSION_SIDE = [];
GRADES = [];
UNIT_NUMS = [];
UNIT_COMMENTS = [];  % march 2018
SESSION_SITES = [];
SESSION_DATES = [];
SESSION_MALE_NUM = []; % mar 2019 MF
SESSION_IDS = []; %June 2018
APP_MODS = [];
STM_MODS = [];
FULL_MODS = [];
S_STM_MODS = [];
APP_PEAKS = [];
STM_PEAKS = [];
S_STM_PEAKS = [];
FULL_PEAKS = [];
APP_PVAL = [];
STM_PVAL = [];
S_STM_PVAL = [];
FULL_PVAL = [];
ALL_APP_MODS  = [];
ALL_STM_MODS = [];
ALL_S_STM_MODS = [];
ALL_FULL_MODS = [];
APP_Sa  = [];  
STM_Sa  =  []; 
FULL_Sa =  []; 
S_STM_Sa  =  []; 
ALL_BASELINES =  []; 
TRIALS=[];
UNIT_ORDER=[];


% run over all sessions included in the data file
Nsessions = length(meanM);
for i = 1:Nsessions
    
    % Determine the columns containing the required stimuli
    % necessary because we cannot assume that the order is identical in all
    % sessions
    colord = [];
    
    % Check that the dataset contains all the stimuli required
    all_good = 1;
    for oi = 1:length(do_stims)
        tmp = strmatch(do_stims{oi},odors{i},'exact');
        if isempty(tmp)
            all_good = 0;
        else
            colord(oi) = tmp;
        end
    end
    
    % If you do have all the stimuli, start compiling this data
    if all_good
        Nunits = size(meanM{i}{1},1);
        % This rearrangement of the date facilitates looking for the data for a
        % particular unit
        clear thesedates  thesesites thesesmalenum;
        for k = 1:Nunits
            thesedates{k}   = session_date{i};
            thesesites(k)   = session_site(i);
            thesesmalenum{k}= session_male_num{i};            
        end
        SESSION_DATES   =  [SESSION_DATES;  thesedates'];
        SESSION_SITES   =  [SESSION_SITES   thesesites];
        SESSION_MALE_NUM=  [SESSION_MALE_NUM thesesmalenum];
        

        % Get the response modulations for each of the cuts
        % The fact that 1,2 and 3 are app, stm and full are defined in the
        % variable do_cuts in make_data_for_GIF_mixed_urine_responses
        APP_MODS   = [APP_MODS ;  meanM{i}{1}(:,colord)];
        STM_MODS   = [STM_MODS ;  meanM{i}{2}(:,colord)];
        FULL_MODS  = [FULL_MODS ; meanM{i}{3}(:,colord)];
        S_STM_MODS = [S_STM_MODS ;meanM{i}{4}(:,colord)];

        % spike rates associated with each of the epochs
        APP_Sa   = [APP_Sa ;  meanSa{i}{1}(:,colord)];
        STM_Sa   = [STM_Sa ;  meanSa{i}{2}(:,colord)];
        FULL_Sa  = [FULL_Sa ; meanSa{i}{3}(:,colord)];
        S_STM_Sa = [S_STM_Sa ;meanSa{i}{4}(:,colord)];
        
        % individual modulations for all of the epochs
        ALL_APP_MODS   = [ALL_APP_MODS ;  AllMods{i}{1}(:,colord)];
        ALL_STM_MODS   = [ALL_STM_MODS ;  AllMods{i}{2}(:,colord)];
        ALL_FULL_MODS  = [ALL_FULL_MODS;  AllMods{i}{3}(:,colord)];
        ALL_S_STM_MODS = [ALL_S_STM_MODS; AllMods{i}{4}(:,colord)];
        
        % mean peak responses
        APP_PEAKS   = [APP_PEAKS ;  meanP{i}{1}(:,colord)];
        STM_PEAKS   = [STM_PEAKS ;  meanP{i}{2}(:,colord)];
        FULL_PEAKS  = [FULL_PEAKS ; meanP{i}{3}(:,colord)];
        S_STM_PEAKS = [S_STM_PEAKS; meanP{i}{4}(:,colord)];

        % pvalue associated with each of the responses, for each of the
        % epochs
        APP_PVAL  =  [APP_PVAL  ; pval_allbs{i}{1}(:,colord)];%pval_np_allbs
        STM_PVAL  =  [STM_PVAL  ; pval_allbs{i}{2}(:,colord)];%pval_np_allbs
        FULL_PVAL =  [FULL_PVAL ; pval_allbs{i}{3}(:,colord)];%pval_np_allbs
        S_STM_PVAL=  [S_STM_PVAL; pval_allbs{i}{4}(:,colord)];%pval_np_allbs
        
        
        % All baselines - for each of the units
        ALL_BASELINES =  [ALL_BASELINES; unit_AllBaselines{i}'];
        
        %
        UNIT_NUMS         = [UNIT_NUMS ; unit_nums{i}];
        GRADES            = [GRADES unit_grades{i}];
        SHAPES            = [SHAPES unit_shapes{i}];
        BASELINES         = [BASELINES unit_baselines{i}];
        UNIT_COMMENTS     = [UNIT_COMMENTS unit_comments{i}];
        for od=1:length(colord)
            curr_trials{od}=rel_trials{i}{1}{colord(od)};
        end
        TRIALS            = [TRIALS   repmat({curr_trials},1,length(unit_nums{i}))];
        UNIT_ORDER        = [UNIT_ORDER 1:length(unit_nums{i})];
    end % over "if all good"
end % over all sessions

% Get values for analysis, depending on the selected epoch
% VNS_EPOCH = [];
[R, C] = size(APP_MODS);
switch TAKE_EPOCH
    case 'BEST'
        for i = 1:R
            for j = 1:C             
                if  STM_MODS(i,j) < APP_MODS(i,j)
                    PVAL(i,j)    = APP_PVAL(i,j);
                    MODS(i,j)    = APP_MODS(i,j);
                    ALL_MODS{i,j} = ALL_APP_MODS{i,j};
                    PEAKS(i,j)   = APP_PEAKS(i,j);
                    EPOCHS(i,j)  = 1;
                    TRIAL_N(i,j) = length(ALL_APP_MODS{i,j});                    
                    Sa(i,j) = APP_Sa(i,j); % March 2018 
                    STDS(i,j)    = std(ALL_APP_MODS{i,j});
                else
                    PVAL(i,j)    = STM_PVAL(i,j);
                    MODS(i,j)    = STM_MODS(i,j);                    
                    PEAKS(i,j)   = STM_PEAKS(i,j);
                    EPOCHS(i,j)  = 2;
                    TRIAL_N(i,j) = length(ALL_STM_MODS{i,j});
                    Sa(i,j)      = STM_Sa(i,j); % March 2018
                    STDS(i,j)    = std(ALL_STM_MODS{i,j});
                    ALL_MODS{i,j} = ALL_STM_MODS{i,j};

                end
            end
        end
    case 'STIM'
        for i = 1:R
            for j = 1:C
                PVAL(i,j)    = STM_PVAL(i,j);
                MODS(i,j)    = STM_MODS(i,j);
                PEAKS(i,j)   = STM_PEAKS(i,j);
                EPOCHS(i,j)  = 2;
                TRIAL_N(i,j) = length(ALL_STM_MODS{i,j});
                Sa(i,j)      = STM_Sa(i,j); % March 2018
                STDS(i,j)    = std(ALL_STM_MODS{i,j});
                ALL_MODS{i,j} = ALL_STM_MODS{i,j};

            end
        end
    case 'FULL'
        for i = 1:R
            for j = 1:C
                PVAL(i,j)    = FULL_PVAL(i,j);
                MODS(i,j)    = FULL_MODS(i,j);
                PEAKS(i,j)   = FULL_PEAKS(i,j);
                EPOCHS(i,j)  = 3;
                TRIAL_N(i,j) = length(ALL_FULL_MODS{i,j});                
                STDS(i,j)    = std(ALL_FULL_MODS{i,j});
                Sa(i,j)      = FULL_Sa(i,j); % March 2018
                ALL_MODS{i,j} = ALL_FULL_MODS{i,j};

            end
        end
    case 'SHORT_STIM'
         for i = 1:R
            for j = 1:C
                PVAL(i,j)    = S_STM_PVAL(i,j);
                MODS(i,j)    = S_STM_MODS(i,j);
                PEAKS(i,j)   = S_STM_PEAKS(i,j);
                EPOCHS(i,j)  = 4;
                TRIAL_N(i,j) = length(ALL_S_STM_MODS{i,j});
                Sa(i,j)      = S_STM_Sa(i,j); % March 2018
                STDS(i,j)    = std(ALL_S_STM_MODS{i,j});
                ALL_MODS{i,j} = ALL_S_STM_MODS{i,j};

            end
        end
       
end


%% Unit selection criteria
for i = 1:length(GRADES)
    if contains(lower(GRADES{i}),'single')
        SINGLE_IND(i) = 1;
    else
        SINGLE_IND(i) = 0;
    end
end
for i = 1:length(GRADES)
    if contains(upper(GRADES{i}),'MUA')
        MUA_IND(i) = 1;
    else
        MUA_IND(i) = 0;
    end
end

switch take_units
    case 'Single'
        rel_unit_inds = find(SINGLE_IND);
    case 'MUA+Single'
        rel_unit_inds = find(SINGLE_IND + MUA_IND);
    case 'everything'
        rel_unit_inds = 1:length(MUA_IND);
end



%% selection based on user defined criterion (March 2018)
switch manual_selection
    case 'take only good'
        manually_selected_units = startsWith(lower(UNIT_COMMENTS),'good');
        Ntot = length(manually_selected_units);
        Ninc = sum(manually_selected_units);
        Nexc = Ntot - Ninc;
        disp(['manual selection: including ''good'' units. ' num2str(Nexc) ' excluded of ' num2str(Ntot)])        
    case 'exclude bad'
        manually_selected_units = ~startsWith(lower(UNIT_COMMENTS),'not good');
        Ntot = length(manually_selected_units);
        Ninc = sum(manually_selected_units);
        Nexc = Ntot - Ninc;
        disp(['manual selection: excluding ''not good'' units. ' num2str(Nexc) ' excluded of ' num2str(Ntot)])
    case 'ignore'
        manually_selected_units = true(1,length(UNIT_COMMENTS));
        disp(['manual selection: no selection applied, all units included'])
end


%% get the indices corresponding to subjects - should be separated for strain and sex
% The switch only works for a single string, so we have to check if the
% first one is 'ANY'
 SESSION_MALE_NUM=string(SESSION_MALE_NUM);
switch mating_male_strain
       case 'ANY'
        rel_male_ind  = 1:length(SESSION_MALE_NUM);
    otherwise
        rel_male_ind  = find(contains(SESSION_MALE_NUM,mating_male_strain));
end


% Apply all selection criteria
% minimal number of trials
mintrials = min(TRIAL_N'); 
enough_trials = find(mintrials>=MINTRIALREQUIREMENT);
rel_inds      = intersect(rel_unit_inds, enough_trials);
% select based on manually selected units
rel_inds = intersect(rel_inds,find(manually_selected_units));
% Select based on male strain 
rel_inds = intersect(rel_inds,rel_male_ind);

[~,stim_set,~] = fileparts(datafilename);

INFO_STR = ['dataset: ' '''' stim_set '''' ' epoch: ' '''' TAKE_EPOCH ''''  ' units: ' '''' take_units ''''];

%% leave only relevant units
% based on selection of enough trials, unit types and user selected units
DATA_STRUCT.UNIT_NUMS       = UNIT_NUMS(rel_inds);
DATA_STRUCT.SESSION_DATES   = SESSION_DATES(rel_inds);
DATA_STRUCT.SESSION_SITES   = SESSION_SITES(rel_inds);
DATA_STRUCT.MODS            = MODS(rel_inds,:);
DATA_STRUCT.STDS            = STDS(rel_inds,:);
DATA_STRUCT.GRADES          = GRADES(rel_inds);
DATA_STRUCT.PVAL            = PVAL(rel_inds,:);
% also the other measures should be filtered (App_Sa etc ...)
DATA_STRUCT.ALL_BASELINES   = ALL_BASELINES(rel_inds); % baselines
DATA_STRUCT.Sa              = Sa(rel_inds); % spikes after
SESSION_MALE_NUM=string(SESSION_MALE_NUM);
DATA_STRUCT.SESSION_MALE_NUM = SESSION_MALE_NUM(rel_inds);
DATA_STRUCT.TRIALS           = TRIALS(rel_inds); 
DATA_STRUCT.UNIT_ORDER           = UNIT_ORDER(rel_inds); 
DATA_STRUCT.ALL_MODS=ALL_MODS(rel_inds,:);


% Construct unique session identifiers
SESSION_DATES   = SESSION_DATES(rel_inds);
SESSION_SITES   = SESSION_SITES(rel_inds);

for i = 1:length(SESSION_DATES)
    SESSION_IDS{i} = [SESSION_DATES{i} '_s' num2str(SESSION_SITES(i))];
end
DATA_STRUCT.SESSION_IDS = SESSION_IDS;
DATA_STRUCT.INFO_STR = INFO_STR;

