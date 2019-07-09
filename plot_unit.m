function [user_comm,RESPtype,comnt]=plot_unit(ui,unit_list,RelTrials,do_odors,RelCuts,dates,sites,units,pval,do_stims)
%%%%%%%%%%%%%%%%%%%
RelCuts=6;
%%%%%%%%%%%%%%%%
unit_location=unit_list(ui);
rel_trials_strc=RelTrials{ui};
sstring=[dates{ui}, '-s' ,num2str(sites(ui))];
fn2=['H:\MATLAB\Michals_data\CutData\cutdata_TrialEpochs_(' sstring ')_sorted_michalV10' ]; %
D2=load(fn2);
spike_times=D2.spike_times;
binned_spike_times=D2.S_binned_spike_times;
Tbs=D2.Tbs; Tas=D2.Tas;
k = 0;
all_spike_times=[];
Ntrials=0;
fig=figure;
for oi = 1:length(do_odors)
    curr_trials = rel_trials_strc{do_odors(oi)};
    Ntrials = Ntrials+length(curr_trials);
    clear X Y Xtime Ytime
    all_resps = [];
    tmp_spike_trials = [];
    tmp_spike_times = [];
    tmp_binned_St=[];
    for i = 1:length(curr_trials)%Ntrials
        trial = curr_trials(i);
        St = spike_times{trial}{RelCuts}{unit_location};
        bSt=binned_spike_times{trial}{RelCuts}{unit_location};
        all_spike_times=[all_spike_times; D2.spike_times{trial}{RelCuts}{unit_location}];
        all_resps(i,:) = D2.binned_spike_times{trial}{RelCuts}{unit_location};
        tmp_spike_times =  [tmp_spike_times ; St];
        tmp_spike_trials = [tmp_spike_trials (Ntrials+1-i)*ones(1,length(St))];
        tmp_binned_St=[tmp_binned_St; bSt];
        k = k + 1;
        if RelCuts==6
        lh_2 = line([20 20 ],[0 Ntrials+1]);
        lh_1 = line([0 0 ],[0 Ntrials+1]);
        else 
                lh_1 = line([-20 -20 ],[0 Ntrials+1]);
        lh_2 = line([0 0 ],[0 Ntrials+1]);
        end
        set(lh_1,'color','b','linestyle',':','LineWidth',2)
        set(lh_2,'color','r','linestyle',':','LineWidth',2)
        hold on
    end
    line([-40 80],[Ntrials-length(curr_trials)+0.33 Ntrials-length(curr_trials)+0.33],'color','k','LineStyle',':');
    
    if ~isempty(tmp_spike_trials)
        
        Y(1,:) = tmp_spike_trials-0.3;
        Y(2,:) = tmp_spike_trials+0.3;
        Y(3,:) = nan(1,size(Y,2));
        
        
        X(1,:) = tmp_spike_times;
        X(2,:) = tmp_spike_times;
        X(3,:) = nan(1,size(X,2));
        
        nX = reshape(X,1,prod(size(X)));
        nY = reshape(Y,1,prod(size(Y)));
        %         subplot(2,1,1);
        plot(nX,nY,'k','LineStyle','-');
        hold on
        set(gca,'xlim',[-Tbs(RelCuts) Tas(RelCuts)])
        set(gca,'ylim',[0 Ntrials+1])
        set(gca,'ytick',[])
        box on
    end
end

loc=3;
for lb=1:length(do_odors)
    ylabels{lb}=[do_stims{do_odors(lb)},' P=' num2str(pval(ui,do_odors(lb)))];
    ylabels{lb} = strrep(ylabels{lb},'_',' ');
    ytickloc(lb)=loc;
    loc=loc+length(rel_trials_strc{do_odors(lb)});
    if pval(ui,do_odors(lb))<0.05
        ylabels{lb}= ['\color{red}' ylabels{lb}];
    end
    
end
xlabel('time(s)');
ax=gca;
set(ax, 'YTick',ytickloc,'YTickLabel',ylabels,'TickLabelInterpreter','tex','FontSize',14);

yyaxis right
binrange=-Tbs(RelCuts):1:Tas(RelCuts);
[bincount]=histc(all_spike_times,binrange);
normalized_PSTH=(bincount./max(bincount))*Ntrials;% length(do_odors)*5;
plot(binrange,normalized_PSTH,'color','r','LineWidth',2 );
y_ax=bincount./Ntrials;%(length(do_odors)*5);
yticks=min(y_ax):(max(y_ax)-min(y_ax))/5:max(y_ax);
yticks=round(yticks,2);
set(ax, 'YTick',0:length(do_odors):Ntrials,'YTickLabel',(yticks),'FontSize',14);%length(do_odors)*5

ylabel('Firing Rate (HZ)','FontSize',14,'Color','r')
title(['unit ', num2str(units(ui)),' session ',sstring]);
xlabel('time(s)');

comnt = uicontrol(gcf,'Style','popupmenu','Position',[100 35 60 20],'String',{'not sure','good','not good'});
uicontrol('Style','text','Position',[10 35 60 20],'String','grade','FontSize',12)

RESPtype = uicontrol(gcf,'Style','popupmenu','Position',[100 10 60 20],'String',{'not sure','app','stim'});
uicontrol('Style','text','Position',[10 10 60 20],'String','response','FontSize',12)
user_comm=uicontrol('Style','edit','Position',[200,10,60,20]);
