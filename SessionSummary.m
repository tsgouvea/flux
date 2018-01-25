function GUIHandles = SessionSummary(Data, GUIHandles)

%global nTrialsToShow %this is for convenience
%global BpodSystem
%global TaskParameters
artist = lines(3);
ABC = 'ABC';

if nargin < 2 % plot initialized (either beginning of session or post-hoc analysis)
    if nargin > 0 % post-hoc analysis
        TaskParameters.GUI = Data.Settings.GUI;
    end
    %%
    GUIHandles = struct();
    
    GUIHandles.Figs.MainFig = figure('Position', [1500, 400, 1000, 400],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
    
    GUIHandles.Axes.SessionLong.MainHandle = axes('Position', [.06 .15 .91 .3]); hold on
    GUIHandles.Axes.SessionLong.CumRwd = text(GUIHandles.Axes.SessionLong.MainHandle,10,.5,'0mL','verticalalignment','bottom','horizontalalignment','center');
        
    GUIHandles.Axes.Matching.MainHandle = axes('Position', [[1 0]*[.06;.12] .6 .12 .3],'xlim',[0 1],'ylim',[0 1]); hold on
    GUIHandles.Axes.Matching.MainHandle.XLabel.String = 'Fraction visits';
    GUIHandles.Axes.Matching.MainHandle.YLabel.String = 'Fraction rewards';
    
    GUIHandles.Axes.PRTHraster.MainHandle = axes('Position', [[2 1]*[.06;.12] .75 .12 .15]); axis off, hold on
    GUIHandles.Axes.PRTHraster.MainHandle.Title.String = 'Pokes since last reward';
    
    GUIHandles.Axes.PSTHraster.MainHandle = axes('Position', [[3 2]*[.06;.12] .75 .12 .15]); axis off, hold on
    GUIHandles.Axes.PSTHraster.MainHandle.Title.String = 'Pokes since last switch';
    
%     GUIHandles.Axes.PCTHraster.MainHandle = axes('Position', [[4 3]*[.06;.12] .75 .12 .15]); axis off, hold on
%     GUIHandles.Axes.PCTHraster.MainHandle.Title.String = 'autocorr(Checks)';
    
    GUIHandles.Axes.PRTH.MainHandle = axes('Position', [[2 1]*[.06;.12] .6 .12 .15],'XLimMode','Auto','YLimMode','Auto');hold on
    GUIHandles.Axes.PRTH.MainHandle.YLim = [0 0.0001];
    
    GUIHandles.Axes.PSTH.MainHandle = axes('Position', [[3 2]*[.06;.12] .6 .12 .15]);hold on
    GUIHandles.Axes.PSTH.MainHandle.YLim = [0 0.0001];
    
    GUIHandles.Axes.PCTH.MainHandle = axes('Position', [[4 3]*[.06;.12] .6 .12 .3]);hold on
    GUIHandles.Axes.PCTH.MainHandle.YLim = [0 0.0001];
    
    GUIHandles.Axes.Switches.MainHandle = axes('Position', [[5 4]*[.06;.12] .6 .12 .3]);hold on
    view(GUIHandles.Axes.Switches.MainHandle,ones(1,3))
    GUIHandles.Axes.Switches.MainHandle.XLabel.String = 'time since r_1';
    GUIHandles.Axes.Switches.MainHandle.YLabel.String = 'time since r_2';
    GUIHandles.Axes.Switches.MainHandle.ZLabel.String = 'time since r_3';
    
    for iPatch = 1:3
        %         eval(['lambda = TaskParameters.GUI.Mean' ABC(iPatch)]);
        %         GUIHandles.Axes.SessionLong.Pr(iPatch) = plot(GUIHandles.Axes.SessionLong.MainHandle,linspace(0,60,100),1-exp(-1*linspace(0,60,100)/TaskParameters.GUI.(['Mean' ABC(iPatch)])), 'color',artist(iPatch,:));
        GUIHandles.Axes.SessionLong.Pr(iPatch) = plot(GUIHandles.Axes.SessionLong.MainHandle,linspace(0,60,100),1-exp(-1*linspace(0,60,100)/iPatch), 'color',artist(iPatch,:));
        GUIHandles.Axes.Matching.X(iPatch) = plot(GUIHandles.Axes.Matching.MainHandle,rand,rand,'o','color',artist(iPatch,:),'markersize',8);
        GUIHandles.Axes.PRTHraster.Raster(iPatch) = plot(GUIHandles.Axes.PRTHraster.MainHandle,nan,nan,'.','color',artist(iPatch,:));
        GUIHandles.Axes.PSTHraster.Raster(iPatch) = plot(GUIHandles.Axes.PSTHraster.MainHandle,nan,nan,'.','color',artist(iPatch,:));
%         GUIHandles.Axes.PCTHraster.Raster(iPatch) = plot(GUIHandles.Axes.PCTHraster.MainHandle,nan,nan,'.','color',artist(iPatch,:));
        %         GUIHandles.Axes.PRTH.Hist(iPatch) = histogram(GUIHandles.Axes.PRTH.MainHandle,[],'EdgeColor',artist(iPatch,:),'FaceColor','none','DisplayStyle','stairs');
        %         GUIHandles.Axes.PSTH.Hist(iPatch) = histogram(GUIHandles.Axes.PCTH.MainHandle,[],'EdgeColor',artist(iPatch,:),'FaceColor','none','DisplayStyle','stairs');
        %         GUIHandles.Axes.PCTH.Hist(iPatch) = histogram(GUIHandles.Axes.PSTH.MainHandle,[],'EdgeColor',artist(iPatch,:),'FaceColor','none','DisplayStyle','stairs');
        GUIHandles.Axes.PRTH.Hist(iPatch) = plot(GUIHandles.Axes.PRTH.MainHandle,nan,nan,'Color',artist(iPatch,:));
        GUIHandles.Axes.PSTH.Hist(iPatch) = plot(GUIHandles.Axes.PSTH.MainHandle,nan,nan,'Color',artist(iPatch,:));
        GUIHandles.Axes.PCTH.Hist(iPatch) = plot(GUIHandles.Axes.PCTH.MainHandle,nan,nan,'Color',artist(iPatch,:));
        
        GUIHandles.Axes.Switches.Scatter(iPatch) = plot3(GUIHandles.Axes.Switches.MainHandle,nan,nan,nan,'o','color',artist(iPatch,:));
    end
    %%
else
    global TaskParameters
end
%%
if nargin > 0
    try
        Data = recomputeCustomDataFields(Data);
    catch
        error('Failed to recompute Data.Custom')
    end
    %% Matching
    for iPatch = 1:numel(Data.Custom.PokeIn)
        GUIHandles.Axes.Matching.X(iPatch).XData = sum(Data.Custom.ndxSwitch&Data.Custom.IdPoke==iPatch)/sum(Data.Custom.ndxSwitch);
        GUIHandles.Axes.Matching.X(iPatch).YData = sum(Data.Custom.IdRew==iPatch)/numel(Data.Custom.IdRew);
    end    
    %% PRTH raster
    binEdges = [-20:10:240];
    rowOffset = 0;
    GUIHandles.Axes.PRTH.MainHandle.XLim = [min(binEdges) max(binEdges)];
    GUIHandles.Axes.PRTHraster.MainHandle.XLim = [min(binEdges) max(binEdges)];
    for iPatch = 1:numel(Data.Custom.PokeIn)
        tempRastX = [];
        tempRastY = [];
        tempPRTHy = zeros(0,numel(binEdges)-1);
        for iRew = 1:numel(Data.Custom.Rewards{iPatch})-1
            ndxCho = Data.Custom.PokeIn{iPatch} > Data.Custom.Rewards{iPatch}(iRew) & Data.Custom.PokeIn{iPatch} < Data.Custom.Rewards{iPatch}(iRew+1);
            tempRastX = [tempRastX; Data.Custom.PokeIn{iPatch}(ndxCho)' - Data.Custom.Rewards{iPatch}(iRew)];
            tempRastY = [tempRastY; ones(numel(Data.Custom.PokeIn{iPatch}(ndxCho)),1)*(iRew+rowOffset)];
            tempPRTHy = [tempPRTHy; histcounts(Data.Custom.PokeIn{iPatch}(ndxCho) - Data.Custom.Rewards{iPatch}(iRew),binEdges)];
        end
        %%
        GUIHandles.Axes.PRTHraster.Raster(iPatch).YData = tempRastY;
        GUIHandles.Axes.PRTHraster.Raster(iPatch).XData = tempRastX;
        
        GUIHandles.Axes.PRTH.Hist(iPatch).YData = sum(tempPRTHy)./sum(tempPRTHy(:));
        GUIHandles.Axes.PRTH.Hist(iPatch).XData = binEdges(1:end-1);
        GUIHandles.Axes.PRTH.MainHandle.YLim(2) = max(GUIHandles.Axes.PRTH.MainHandle.YLim(2),max(GUIHandles.Axes.PRTH.Hist(iPatch).YData));
        %%
        rowOffset = rowOffset + iRew;
    end
    
    %% Switches and PSTW
    tsAllRewards = 0;
    for iPatch = 1:3
        tsAllRewards = max(tsAllRewards,min(Data.Custom.TsRew(Data.Custom.IdRew==iPatch))); % time from when all ports have been rewarded
    end
    
    if ~isempty(tsAllRewards)
        temp1 = nan(0,3);
        
        rowOffset = 0;
        GUIHandles.Axes.PSTH.MainHandle.XLim = [min(binEdges) max(binEdges)];
        GUIHandles.Axes.PSTHraster.MainHandle.XLim = [min(binEdges) max(binEdges)];
        GUIHandles.Axes.PSTH.MainHandle.YLim(2) = .001;
        for iPatch = 1:3
            tsSwi = Data.Custom.TsPoke(Data.Custom.IdPoke==iPatch & Data.Custom.ndxSwitch & Data.Custom.TsPoke>tsAllRewards);
            
            temp2 = nan(numel(tsSwi),3);
            
            tempRastX = [];
            tempRastY = [];
            tempPSTHy = zeros(0,numel(binEdges)-1);
            
            for iSwi = 1:numel(tsSwi)-1
                temp2(iSwi,1) = tsSwi(iSwi) - max(Data.Custom.TsRew(Data.Custom.IdRew==1&Data.Custom.TsRew<tsSwi(iSwi)));
                temp2(iSwi,2) = tsSwi(iSwi) - max(Data.Custom.TsRew(Data.Custom.IdRew==2&Data.Custom.TsRew<tsSwi(iSwi)));
                temp2(iSwi,3) = tsSwi(iSwi) - max(Data.Custom.TsRew(Data.Custom.IdRew==3&Data.Custom.TsRew<tsSwi(iSwi)));
                
                ndxCho = Data.Custom.TsPoke > tsSwi(iSwi) & Data.Custom.TsPoke < tsSwi(iSwi)+max(binEdges) & Data.Custom.IdPoke==iPatch;
                tempRastX = [tempRastX; Data.Custom.TsPoke(ndxCho) - tsSwi(iSwi)];
                tempRastY = [tempRastY; ones(sum(ndxCho),1)*(iSwi+rowOffset)];
                tempPSTHy = [tempPSTHy; histcounts(Data.Custom.TsPoke(ndxCho) - tsSwi(iSwi),binEdges)];
            end
            GUIHandles.Axes.Switches.Scatter(iPatch).XData = temp2(:,1);
            GUIHandles.Axes.Switches.Scatter(iPatch).YData = temp2(:,2);
            GUIHandles.Axes.Switches.Scatter(iPatch).ZData = temp2(:,3);
            temp1 = [temp1;temp2];
            clear temp
            
            GUIHandles.Axes.PSTHraster.Raster(iPatch).YData = tempRastY;
            GUIHandles.Axes.PSTHraster.Raster(iPatch).XData = tempRastX;
            
            GUIHandles.Axes.PSTH.Hist(iPatch).YData = sum(tempPSTHy)/sum(tempPSTHy(:));
            GUIHandles.Axes.PSTH.Hist(iPatch).XData = binEdges(1:end-1);
            GUIHandles.Axes.PSTH.MainHandle.YLim(2) = max(GUIHandles.Axes.PSTH.MainHandle.YLim(2),max(GUIHandles.Axes.PSTH.Hist(iPatch).YData));
            rowOffset = rowOffset + iSwi;
        end
        try
            pcs = pca(temp1);
            view(GUIHandles.Axes.Switches.MainHandle,pcs(:,3))
%             view(GUIHandles.Axes.Switches.MainHandle,[1 1 1])
        end
        clear temp2
    end
    %% autocorr(choices{iPatch})
    maxlag = max(binEdges);
    GUIHandles.Axes.PCTH.MainHandle.YLim(2) = .001;
    for iPatch = 1:3
        GUIHandles.Axes.PCTH.Hist(iPatch).XData = -maxlag:maxlag;
        GUIHandles.Axes.PCTH.Hist(iPatch).YData = xcorr(histcounts(Data.Custom.TsPoke(Data.Custom.IdPoke==iPatch),'BinMethod','integers'),maxlag);
        GUIHandles.Axes.PCTH.Hist(iPatch).YData(maxlag+1) = 0;
        GUIHandles.Axes.PCTH.Hist(iPatch).YData = smooth(GUIHandles.Axes.PCTH.Hist(iPatch).YData,10);
        GUIHandles.Axes.PCTH.Hist(iPatch).YData = GUIHandles.Axes.PCTH.Hist(iPatch).YData/sum(GUIHandles.Axes.PCTH.Hist(iPatch).YData);
        GUIHandles.Axes.PCTH.MainHandle.YLim(2) = max(GUIHandles.Axes.PCTH.MainHandle.YLim(2), 1.1*max(GUIHandles.Axes.PCTH.Hist(iPatch).YData));
%         GUIHandles.Axes.PCTH.MainHandle.YLim = [-.1 1]*GUIHandles.Axes.PCTH.MainHandle.YLim(2);
    end
    GUIHandles.Axes.PCTH.MainHandle.XLim = [-1.1 1.1]*maxlag;
% [~,ndxSort] = sort(pokes(:,2));
% ndxSwitchOver = [true; diff(pokes(ndxSort,1))~=0];
% for iPatch = 1:numel(Data.Custom.PokeIn)
%     his(iPatch).switches = histcounts(pokes(ndxSwitchOver & pokes(:,1)==iPatch,2),'BinMethod','integers');
% end
% %%
% GUIHandles.Axes.PRTH.MainHandle.YLim = [0 0.0001];
% GUIHandles.Axes.PSTH.MainHandle.YLim = [0 0.0001];
% GUIHandles.Axes.PCTH.MainHandle.YLim = [0 0.0001];
% for iPatch = 1:numel(Data.Custom.PokeIn)
%     maxlag = ceil(TaskParameters.GUI.(['Mean' ABC(iPatch)])*1.5);
%     %%
%     GUIHandles.Axes.PRTH.Hist(iPatch).XData = -maxlag:maxlag;
%     GUIHandles.Axes.PRTH.Hist(iPatch).YData = xcorr(his(iPatch).rewards,his(iPatch).checks,maxlag);
%     GUIHandles.Axes.PRTH.Hist(iPatch).YData = GUIHandles.Axes.PRTH.Hist(iPatch).YData/sum(GUIHandles.Axes.PRTH.Hist(iPatch).YData);
%     GUIHandles.Axes.PRTH.MainHandle.XLim = [-.1 1.1]*maxlag;
%     GUIHandles.Axes.PRTH.MainHandle.YLim(2) = max(GUIHandles.Axes.PRTH.MainHandle.YLim(2), 1.1*max(GUIHandles.Axes.PRTH.Hist(iPatch).YData));
%     GUIHandles.Axes.PRTH.MainHandle.YLim = [-.1 1]*GUIHandles.Axes.PRTH.MainHandle.YLim(2);
%     
%     GUIHandles.Axes.PSTH.Hist(iPatch).XData = -maxlag:maxlag;
%     GUIHandles.Axes.PSTH.Hist(iPatch).YData = xcorr(his(iPatch).switches,his(iPatch).checks,maxlag);
%     GUIHandles.Axes.PSTH.Hist(iPatch).YData = GUIHandles.Axes.PSTH.Hist(iPatch).YData/sum(GUIHandles.Axes.PSTH.Hist(iPatch).YData);
%     GUIHandles.Axes.PSTH.MainHandle.XLim = [-.1 1.1]*maxlag;
%     GUIHandles.Axes.PSTH.MainHandle.YLim(2) = max(GUIHandles.Axes.PSTH.MainHandle.YLim(2), 1.1*max(GUIHandles.Axes.PSTH.Hist(iPatch).YData));
%     GUIHandles.Axes.PSTH.MainHandle.YLim = [-.1 1]*GUIHandles.Axes.PSTH.MainHandle.YLim(2);
%     
%     GUIHandles.Axes.PCTH.Hist(iPatch).XData = -maxlag:maxlag;
%     GUIHandles.Axes.PCTH.Hist(iPatch).YData = xcorr(his(iPatch).checks,maxlag);
%     GUIHandles.Axes.PCTH.Hist(iPatch).YData(maxlag+1) = 0;
%     GUIHandles.Axes.PCTH.Hist(iPatch).YData = GUIHandles.Axes.PCTH.Hist(iPatch).YData;
%     GUIHandles.Axes.PCTH.Hist(iPatch).YData = GUIHandles.Axes.PCTH.Hist(iPatch).YData/sum(GUIHandles.Axes.PCTH.Hist(iPatch).YData);
%     GUIHandles.Axes.PCTH.MainHandle.XLim = [-1.1 1.1]*maxlag;
%     GUIHandles.Axes.PCTH.MainHandle.YLim(2) = max(GUIHandles.Axes.PCTH.MainHandle.YLim(2), 1.1*max(GUIHandles.Axes.PCTH.Hist(iPatch).YData));
%     GUIHandles.Axes.PCTH.MainHandle.YLim = [-.1 1]*GUIHandles.Axes.PCTH.MainHandle.YLim(2);
% end
    set(GUIHandles.Axes.SessionLong.CumRwd,'string', ...
        [num2str(Data.nTrials*TaskParameters.GUI.rewardAmount/1000) ' mL']);
end
