function Qmr_AFQ_PlotPatientMean(savefig)
% Plot patient data against controls
%
%
% Example:
%
% load /biac4/wandell/data/WH/analysis/AFQ_WestonHavens_Full.mat
% afq_controls = afq;
% load /biac4/wandell/data/WH/kalanit/PS/AFQ_PS.mat
% afq = afq;
% AFQ_PlotPatientMeans(afq,afq_controls,'T1_map_lsq_2DTI',[],'age', [53 73])
% AFQ_PlotPatientMeans(afq,afq_controls,'fa',[],'age', [53 73])
% AFQ_PlotPatientMeans(afq,afq_controls,'md',[],'age', [53 73])
%
% See original; AFQ_PlotPatientMeans


%% load afq structure /Qmr folder

load afq

%%
if notDefined('savefig')
    savefig =0;
end

%% Which nodes and vals to analyze

% exclude first and last 10 nodes from fibers
nodes = 21:80;

% define vals
valname = fieldnames(afq.vals);

% Get number of fiber groups and their names
nfg = AFQ_get(afq,'nfg');% nfg = 28;
fgNames = AFQ_get(afq,'fgnames');

% Set the colormap and color range for the renderings
cmap = AFQ_colormap('bgr');

crange = [-4 4];

%% Loop over the different values

% get control data
pVals = afq.patient_data;
cVals = afq.control_data;

%% scatter

% loop over patient
for k = 1:sum(afq.sub_group)
    for v = 1:length(valname)
        figure; hold('on');
        
        % Open a new figure window for the mean plot
        
        % Loop over each fiber group
        for ii = 1:nfg
            % Get the values for the patient and compute the mean
            vals_p = pVals(ii).(upper(valname{v}))(k,:);
            
            % Get the value for each control and compute the mean
            vals_c = cVals(ii).(upper(valname{v}));
            vals_c = vals_c(:,nodes);
            vals_cm = nanmean(vals_c,2);
            
            % Compute control group mean and sd
            m = nanmean(vals_cm);
            sd = nanstd(vals_cm);
            
            % Plot control group means and sd
            x = [ii-.2 ii+.2 ii+.2 ii-.2 ii-.2];
            y1 = [m-sd m-sd m+sd m+sd m-sd];
            y2 = [m-2*sd m-2*sd m+2*sd m+2*sd m-2*sd];
            fill(x,y2, [.6 .6 .6],'edgecolor',[0 0 0]);
            fill(x,y1,[.4 .4 .4] ,'edgecolor',[0 0 0]);
            
            %         % plot individual means
            %         for jj = 1:sum(afq.sub_group)
            vals_cur = vals_p(:,nodes);
            m_curr   = nanmean(vals_cur);
            % Define the color of the point for the fiber group based on its zscore
            tractcol = vals2colormap((m_curr - m)./sd,cmap,crange);
            
            % Plot patient mean as a circle
            plot(ii, m_curr,'ko', 'markerfacecolor',tractcol,'MarkerSize',6);
            %         end
        end
        
        
        %% make fgnames shorter
        %     newfgNames = {'l-TR','r-TR','l-C','r-C','l-CC','r-CC','l-CH','r-CH','CFMa',...
        %         'CFMi','l-IFOF','r-IFOF','l-ILF','r-ILF','l-SLF','r-SLF','l-U','r-U',...
        %         'l-A','r-A'};
        
        %     set(gca,'xtick',1:nfg,'xticklabel',newfgNames,'xlim',[0 nfg+1],'fontname','times','fontsize',11);
        set(gca,'xtick',1:nfg,'xticklabel',fgNames,'xlim',[0 nfg+1],'fontname','times','fontsize',11);
        set(gca, 'XTickLabelRotation',90)
        ylabel(upper(valname{v}));
        
        subnames = afq.sub_dirs(afq.sub_group==1);
        [p, ~]= fileparts(subnames{k});
        [~,f]= fileparts(p);
        
        title(f)
        
        h = colorbar('AxisLocation','out');
        h.Label.String = 'z score';
        
        if savefig ==1;
            saveas(gca,sprintf('%s.eps',upper(valname{v})),'psc2')
            saveas(gca,sprintf('%s.png',upper(valname{v})))
        end
        hold off
    end
end

%% barplot

% loop over valname
for v = 1:length(valname)
    figure; hold('on');
    
    % loop over
    %     for k = 1:sum(afq.sub_group)
    
    % Loop over each fiber group
    for ii = 1:nfg
        % Get the values for the patient and compute the mean
        vals_p = pVals(ii).(upper(valname{v}));
        vals_p = vals_p(:,nodes);
        vals_pm = nanmean(vals_p,2);
        
        % Get the value for each control and compute the mean
        vals_c = cVals(ii).(upper(valname{v}));
        vals_c = vals_c(:,nodes);
        vals_cm = nanmean(vals_c,2);
        
        % Compute control group mean and sd
        m = nanmean(vals_cm);
        sd = nanstd(vals_cm);
        
        % Plot control group means and sd
        %             x = [ii-.4 ii-.2 ii+.2 ii+.4];
        y(ii,:) = [vals_pm',m];
    end
    
    %% bar plot
    bar(y,0.3)
    
    y1 = [m-sd m-sd m+sd m+sd m-sd];
    y2 = [m-2*sd m-2*sd m+2*sd m+2*sd m-2*sd];
    fill(x,y2, [.6 .6 .6],'edgecolor',[0 0 0]);
    fill(x,y1,[.4 .4 .4] ,'edgecolor',[0 0 0]);
    
    % get subj name
    clear f
    f = {};
    subnames = afq.sub_dirs(afq.sub_group==1);
    for l = 1:length(subnames)
        [p, ~]= fileparts(subnames{l});
        [~,f{l}]= fileparts(p);
        find(f,'-')
    end
    
    h = legend(subnames);
    
    %         % plot individual means
    %         for jj = 1:sum(afq.sub_group)
    vals_cur = vals_p(:,nodes);
    m_curr   = nanmean(vals_cur);
    % Define the color of the point for the fiber group based on its zscore
    tractcol = vals2colormap((m_curr - m)./sd,cmap,crange);
    
    % Plot patient mean as a circle
    plot(ii, m_curr,'ko', 'markerfacecolor',tractcol,'MarkerSize',6);
    %         end
end


%% make fgnames shorter
%     newfgNames = {'l-TR','r-TR','l-C','r-C','l-CC','r-CC','l-CH','r-CH','CFMa',...
%         'CFMi','l-IFOF','r-IFOF','l-ILF','r-ILF','l-SLF','r-SLF','l-U','r-U',...
%         'l-A','r-A'};

%     set(gca,'xtick',1:nfg,'xticklabel',newfgNames,'xlim',[0 nfg+1],'fontname','times','fontsize',11);
set(gca,'xtick',1:nfg,'xticklabel',fgNames,'xlim',[0 nfg+1],'fontname','times','fontsize',11);
set(gca, 'XTickLabelRotation',90)
ylabel(upper(valname{v}));

subnames = afq.sub_dirs(afq.sub_group==1);
[p, ~]= fileparts(subnames{k});
[~,f]= fileparts(p);

title(f)

h = colorbar('AxisLocation','out');
h.Label.String = 'z score';

if savefig ==1;
    saveas(gca,sprintf('%s.eps',upper(valname{v})),'psc2')
    saveas(gca,sprintf('%s.png',upper(valname{v})))
end
hold off
end



