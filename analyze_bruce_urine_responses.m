function analyze_bruce_urine_responses
PLOT_UNIST_FOR_MANUAL_SELECTION = 1;
SHOW_SINGLE_SESSION_CORRS = 0;
% General response properties
DO_POPULATION_RESPONSE = 0;
%CLUST_DIST = 'euclidean';
CLUST_DIST = 'correlation';

DO_PAIRWISE = 0;
DO_THREEWAY = 0;
COMPARE_BASELINES=0;

basepath='H:\MATLAB\Michals_data\';

stim_set= 'normal_trials';
% stim_set= 'no_wash';

% TAKE_EPOCH = 'FULL';
% TAKE_EPOCH = 'BEST';
TAKE_EPOCH = 'STIM';
% TAKE_EPOCH = 'SHORT_STIM';

% minimal number of required trials
MINTRIALREQUIREMENT = 4;
% minimal p value for including a response
PTHRESH = 0.05;
%% unit grade to include
% take_units = 'Single';
take_units = 'MUA+Single';

% take_units = 'everything';
%% whether to take only the good units upon visual selection
% manual_selection = 'take only good';
% manual_selection = 'exclude bad';
manual_selection = 'ignore';
%%
mating_male_strain='ANY';
%% Define the dataset
switch stim_set
    case 'normal_trials'
        datafile = [basepath ,'michals_dataV3'];
        
        % Defines the entire set of stimuli to analyze
        do_stims{1} = 'F_BC';
        do_stims{2} = 'F_C57';
        do_stims{3} = 'M1_BC';
        do_stims{4} = 'M1_C57';
        do_stims{5} = 'M2_BC';
        do_stims{6} = 'M2_C57';
        do_stims{7} = 'P';
        do_stims{8} = 'cas_BC';
        do_stims{9} = 'cas_C57';
        
        % do_pairwise_comparison(SESSION_IDS,UNIT_NUMS,GRADES,PVAL,PTHRESH,MODS,do_stims,INFO_STR,1);
        %         pairwise_comp{1} = {{'M1_C57','M2_C57'},{'M1_BC','M2_BC'}};
        pairwise_comp{1} = {{'M1_BC','M2_BC'},{'M1_C57','M2_C57'}};
       
        
        % %         pairwise_comp{1} = {{'WM','M_C57','M_BC'},{'WF','F_C57','F_BC'}};
        % %         % wild vs inbred
        % %         pairwise_comp{2} = {{'WM','WF'},{'M_C57','M_BC','F_C57','F_BC'}};
        
        PLOT_NO_WASH_DATA=0;
    case 'no_wash'
        
        datafile = [basepath ,'michals_dataV3'];
        
        % Defines the entire set of stimuli to analyze
        do_stims{3} = 'MM';
        do_stims{4} = 'MFP';
        do_stims{1} = 'NoWash_MFP';
        do_stims{2} = 'NoWash_MM';
        
        MINTRIALREQUIREMENT = 1;
        % do_pairwise_comparison(SESSION_IDS,UNIT_NUMS,GRADES,PVAL,PTHRESH,MODS,do_stims,INFO_STR,1);
        %         pairwise_comp{1} = {{'M1_C57','M2_C57'},{'M1_BC','M2_BC'}};
        %         pairwise_comp{1} = {{'M1_BC','M2_BC'},{'M1_C57','M2_C57'}};
        pairwise_comp{1} = {{'NoWash_MM','MM'},{'NoWash_MFP','MFP'}};
        
        PLOT_NO_WASH_DATA=1;
        
end


%% get the data with the specified filtering
DATA_STRUCT = prepare_data_for_michals_analysis(datafile,do_stims,mating_male_strain,TAKE_EPOCH,MINTRIALREQUIREMENT,PTHRESH,take_units,manual_selection);
UNIT_NUMS        = DATA_STRUCT.UNIT_NUMS;
SESSION_DATES    = DATA_STRUCT.SESSION_DATES;
SESSION_SITES    = DATA_STRUCT.SESSION_SITES;
MODS             = DATA_STRUCT.MODS;
STDS             = DATA_STRUCT.STDS;
GRADES           = DATA_STRUCT.GRADES;
% SESSION_STRAINS  = DATA_STRUCT.SESSION_STRAINS;
PVAL             = DATA_STRUCT.PVAL;
ALL_BASELINES    = DATA_STRUCT.ALL_BASELINES;
Sa               = DATA_STRUCT.Sa;
SESSION_IDS      = DATA_STRUCT.SESSION_IDS;
INFO_STR         = DATA_STRUCT.INFO_STR;
SESSION_MALE_NUM = DATA_STRUCT.SESSION_MALE_NUM;
TRIALS           = DATA_STRUCT.TRIALS;
UNIT_ORDER       = DATA_STRUCT.UNIT_ORDER;
ALL_MODS         = DATA_STRUCT.ALL_MODS;

if PLOT_UNIST_FOR_MANUAL_SELECTION
    %in order to mark good and not good cells for manual selection:
    plot_units_for_manual_selection(PVAL,PTHRESH,DATA_STRUCT,TAKE_EPOCH,TRIALS,UNIT_ORDER,do_stims,basepath)
end
GroupMembership=zeros(size(SESSION_MALE_NUM));
GroupMembership(strcmp(SESSION_MALE_NUM,'naive female'))=1;
GroupMembership(strcmp(SESSION_MALE_NUM,'mated with bc#1'))=2;
GroupMembership(strcmp(SESSION_MALE_NUM,'mated with bc#2'))=2;
GroupMembership(strcmp(SESSION_MALE_NUM,'mated with bc'))=2;
GroupMembership(strcmp(SESSION_MALE_NUM,'mated with c57#1'))=3;
GroupMembership(strcmp(SESSION_MALE_NUM,'mated with c57#2'))=3;



% % report number of units of each type
% for i = 1:length(GRADES)
%     disp(['session : ' SESSION_IDS{i} ' ' num2str(UNIT_NUMS(i)) ' ' GRADES{i} ]);
% end


% % report number of units for each grade
un_grades = unique(GRADES);
for i = 1:length(un_grades)
    disp([num2str(sum(strcmp(un_grades{i},GRADES))) ' ' un_grades{i} ' units']);
end
%
% % % % %
% % % % % % general analysis functions  - the last argument if for single only
%show_correlation_among_units(SESSION_IDS,UNIT_NUMS,GRADES,PVAL,PTHRESH,MODS,do_stims,INFO_STR,1);
if SHOW_SINGLE_SESSION_CORRS
    show_correlation_among_units(SESSION_IDS,UNIT_NUMS,GRADES,PVAL,PTHRESH,MODS,do_stims,INFO_STR,0);
end

% General response properties
% CLUST_DIST = 'correlation';
if DO_POPULATION_RESPONSE
    show_population_response_features(PVAL,PTHRESH,MODS,GRADES,do_stims,INFO_STR,CLUST_DIST);
end

% % % % %
if DO_PAIRWISE
    for i =1:length(pairwise_comp)
        do_pairwise_comparison_mf(MODS,STDS,PVAL,PTHRESH,GRADES,do_stims,pairwise_comp{i},GroupMembership,INFO_STR);
        %[mean,median,ttestpval,signpval] =
    end
end

if DO_THREEWAY
    for i =1:length(threeway_comp)
        do_threeway_comparison(MODS,STDS,PVAL,PTHRESH,GRADES,do_stims,threeway_comp{i},INFO_STR)
    end
end

if COMPARE_BASELINES
    plot_baselines(GroupMembership,ALL_BASELINES,PVAL,PTHRESH)
end

if strcmp(stim_set,'no_wash')
    if PLOT_NO_WASH_DATA
        plot_no_wash_data(ALL_MODS,PVAL,PTHRESH,GroupMembership,do_stims)
    end
end

return