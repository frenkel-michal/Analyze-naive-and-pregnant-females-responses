function plot_units_for_manual_selection(PVAL,PTHRESH,DATA_STRUCT,TAKE_EPOCH,TRIALS,UNIT_ORDER,do_stims,basepath)
SIGS     = PVAL <= PTHRESH;
anysigs         = sum(SIGS,2) > 0;  % any significant response
UNIT_NUMS        = DATA_STRUCT.UNIT_NUMS;
SESSION_DATES    = DATA_STRUCT.SESSION_DATES;
SESSION_SITES    = DATA_STRUCT.SESSION_SITES;
unit_list=UNIT_ORDER(anysigs);
units     = UNIT_NUMS(anysigs);
dates     = SESSION_DATES(anysigs);
sites     = SESSION_SITES(anysigs);
RelTrials = TRIALS(anysigs);
% sig_units=SIGS(anysigs,:);
pval_units=PVAL(anysigs,:);
do_odors=1:size(SIGS,2);
switch TAKE_EPOCH
    case 'STIM'
        RelCuts=2;
    case 'FULL'
        RelCuts=6;
    otherwise 
        RelCuts=2;
end

% [num,~,RAW]=xlsread([basepath,'\huji_cell_database']);
[num,~,RAW]=xlsread(['H:\tmp\tmp.xlsx']);
headers     = RAW(1,1:end);
date_col    = find(strcmp(headers,'date'));
unit_col    = find(strcmp(headers,'unit'));
site_col    = find(strcmp(headers,'session'));
comm_col    = find(strcmp(headers,'comment'));
resp_col    = find(strcmp(headers,'response time'));
user_col    = find(strcmp(headers,'overlaps with'));
alphabet    = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P'];
comm_letter = alphabet(comm_col);
resp_letter = alphabet(resp_col);
user_letter = alphabet(user_col);
units_list  = cell2mat(RAW(2:end,unit_col));
sites_list  = cell2mat(RAW(2:end,site_col));
for ui=1:length(units)
    units_row=find(units_list==units(ui))+1;%num is without the headers
    dates_row=find(strcmp(RAW(:,date_col),dates(ui)));
    site_row=find(sites_list==sites(ui))+1;
    rel_row=intersect(intersect(units_row,dates_row),site_row);
    if isnan(RAW{rel_row,comm_col})
    [user_comm,resp,comm]= plot_unit(ui,unit_list,RelTrials,do_odors,RelCuts,dates,sites,units,pval_units,do_stims);
    if size(rel_row)==1
        xlswrite(['H:\tmp\tmp.xlsx'],comm.String(comm.Value),1,[comm_letter, num2str(rel_row)])
        xlswrite(['H:\tmp\tmp.xlsx'],resp.String(resp.Value),1,[resp_letter, num2str(rel_row)])
        if ~isempty (user_comm.String)
        xlswrite(['H:\tmp\tmp.xlsx'],{user_comm.String},1,[user_letter, num2str(rel_row)])
        end
        close all
    end
    end
end
end
