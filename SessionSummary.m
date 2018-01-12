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
    GUIHandles.Figs.MainFig = figure('Position', [200, 200, 1000, 400],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
    GUIHandles.Axes.SessionLong.MainHandle = axes('Position', [.06 .15 .91 .3]); hold on
    GUIHandles.Axes.Matching.MainHandle = axes('Position', [[1 0]*[.06;.12] .6 .12 .3]); hold on
%     GUIHandles.Axes.PRTHraster.MainHandle = axes('Position', [[2 1]*[.06;.12] .75 .12 .15]); axis off, hold on
%     GUIHandles.Axes.PSTHraster.MainHandle = axes('Position', [[3 2]*[.06;.12] .75 .12 .15]); axis off, hold on
%     GUIHandles.Axes.PCTHraster.MainHandle = axes('Position', [[4 3]*[.06;.12] .75 .12 .15]); axis off, hold on
    GUIHandles.Axes.PRTH.MainHandle = axes('Position', [[2 1]*[.06;.12] .6 .12 .3],'XLimMode','Auto','YLimMode','Auto');hold on
    GUIHandles.Axes.PRTH.MainHandle.Title.String = 'xcorr(Reward,Checks)';
    GUIHandles.Axes.PRTH.MainHandle.YLim = [0 0.0001];
    GUIHandles.Axes.PSTH.MainHandle = axes('Position', [[3 2]*[.06;.12] .6 .12 .3]);hold on
    GUIHandles.Axes.PSTH.MainHandle.Title.String = 'xcorr(SwitchOvers,Checks)';
    GUIHandles.Axes.PSTH.MainHandle.YLim = [0 0.0001];
    GUIHandles.Axes.PCTH.MainHandle = axes('Position', [[4 3]*[.06;.12] .6 .12 .3]);hold on
    GUIHandles.Axes.PCTH.MainHandle.Title.String = 'autocorr(Checks)';
    GUIHandles.Axes.PCTH.MainHandle.YLim = [0 0.0001];
    
    for iPatch = 1:3
%         eval(['lambda = TaskParameters.GUI.Mean' ABC(iPatch)]);
%         GUIHandles.Axes.SessionLong.Pr(iPatch) = plot(GUIHandles.Axes.SessionLong.MainHandle,linspace(0,60,100),1-exp(-1*linspace(0,60,100)/TaskParameters.GUI.(['Mean' ABC(iPatch)])), 'color',artist(iPatch,:));
        GUIHandles.Axes.SessionLong.Pr(iPatch) = plot(GUIHandles.Axes.SessionLong.MainHandle,linspace(0,60,100),1-exp(-1*linspace(0,60,100)/iPatch), 'color',artist(iPatch,:));
        GUIHandles.Axes.Matching.X(iPatch) = plot(GUIHandles.Axes.Matching.MainHandle,rand,rand,'o','color',artist(iPatch,:),'markersize',8);
%         GUIHandles.Axes.PRTHraster.Raster(iPatch) = plot(GUIHandles.Axes.PRTHraster.MainHandle,rand,rand,'.','color',artist(iPatch,:));
%         GUIHandles.Axes.PSTHraster.Raster(iPatch) = plot(GUIHandles.Axes.PCTHraster.MainHandle,rand,rand,'.','color',artist(iPatch,:));
%         GUIHandles.Axes.PCTHraster.Raster(iPatch) = plot(GUIHandles.Axes.PSTHraster.MainHandle,rand,rand,'.','color',artist(iPatch,:));
%         GUIHandles.Axes.PRTH.Hist(iPatch) = histogram(GUIHandles.Axes.PRTH.MainHandle,[],'EdgeColor',artist(iPatch,:),'FaceColor','none','DisplayStyle','stairs');
%         GUIHandles.Axes.PSTH.Hist(iPatch) = histogram(GUIHandles.Axes.PCTH.MainHandle,[],'EdgeColor',artist(iPatch,:),'FaceColor','none','DisplayStyle','stairs');
%         GUIHandles.Axes.PCTH.Hist(iPatch) = histogram(GUIHandles.Axes.PSTH.MainHandle,[],'EdgeColor',artist(iPatch,:),'FaceColor','none','DisplayStyle','stairs');
        GUIHandles.Axes.PRTH.Hist(iPatch) = plot(GUIHandles.Axes.PRTH.MainHandle,rand,rand,'Color',artist(iPatch,:));
        GUIHandles.Axes.PSTH.Hist(iPatch) = plot(GUIHandles.Axes.PCTH.MainHandle,rand,rand,'Color',artist(iPatch,:));
        GUIHandles.Axes.PCTH.Hist(iPatch) = plot(GUIHandles.Axes.PSTH.MainHandle,rand,rand,'Color',artist(iPatch,:));
    end
    %%
else
    global TaskParameters
end
%%
if nargin > 0
    %% PRTH
    pokes = [];
    for iPatch = 1:numel(Data.Custom.PokeIn)
        his(iPatch).rewards = histcounts(Data.Custom.Rewards{iPatch},'BinMethod','integers');
        his(iPatch).checks = histcounts(Data.Custom.PokeIn{iPatch},'BinMethod','integers');
        pokes = [pokes; [ones(numel(Data.Custom.PokeIn{iPatch}),1)*iPatch, Data.Custom.PokeIn{iPatch}(:)]];
    end
    [~,ndxSort] = sort(pokes(:,2));
    ndxSwitchOver = [true; diff(pokes(ndxSort,1))~=0];
    for iPatch = 1:numel(Data.Custom.PokeIn)        
        his(iPatch).switches = histcounts(pokes(ndxSwitchOver & pokes(:,1)==iPatch,2),'BinMethod','integers');
    end
    %%
    GUIHandles.Axes.PRTH.MainHandle.YLim = [0 0.0001];
    GUIHandles.Axes.PSTH.MainHandle.YLim = [0 0.0001];
    GUIHandles.Axes.PCTH.MainHandle.YLim = [0 0.0001];
    for iPatch = 1:numel(Data.Custom.PokeIn)
        maxlag = ceil(TaskParameters.GUI.(['Mean' ABC(iPatch)])*1.5);
        %%
        GUIHandles.Axes.PRTH.Hist(iPatch).XData = -maxlag:maxlag;
        GUIHandles.Axes.PRTH.Hist(iPatch).YData = xcorr(his(iPatch).rewards,his(iPatch).checks,maxlag);
        GUIHandles.Axes.PRTH.Hist(iPatch).YData = GUIHandles.Axes.PRTH.Hist(iPatch).YData/sum(GUIHandles.Axes.PRTH.Hist(iPatch).YData);
        GUIHandles.Axes.PRTH.MainHandle.XLim = [-.1 1.1]*maxlag;
        GUIHandles.Axes.PRTH.MainHandle.YLim(2) = max(GUIHandles.Axes.PRTH.MainHandle.YLim(2), 1.1*max(GUIHandles.Axes.PRTH.Hist(iPatch).YData));
        GUIHandles.Axes.PRTH.MainHandle.YLim = [-.1 1]*GUIHandles.Axes.PRTH.MainHandle.YLim(2);
        
        GUIHandles.Axes.PSTH.Hist(iPatch).XData = -maxlag:maxlag;
        GUIHandles.Axes.PSTH.Hist(iPatch).YData = xcorr(his(iPatch).switches,his(iPatch).checks,maxlag);
        GUIHandles.Axes.PSTH.Hist(iPatch).YData = GUIHandles.Axes.PSTH.Hist(iPatch).YData/sum(GUIHandles.Axes.PSTH.Hist(iPatch).YData);
        GUIHandles.Axes.PSTH.MainHandle.XLim = [-.1 1.1]*maxlag;
        GUIHandles.Axes.PSTH.MainHandle.YLim(2) = max(GUIHandles.Axes.PSTH.MainHandle.YLim(2), 1.1*max(GUIHandles.Axes.PSTH.Hist(iPatch).YData));
        GUIHandles.Axes.PSTH.MainHandle.YLim = [-.1 1]*GUIHandles.Axes.PSTH.MainHandle.YLim(2);
        
        GUIHandles.Axes.PCTH.Hist(iPatch).XData = -maxlag:maxlag;
        GUIHandles.Axes.PCTH.Hist(iPatch).YData = xcorr(his(iPatch).checks,maxlag);
        GUIHandles.Axes.PCTH.Hist(iPatch).YData(maxlag+1) = 0;
        GUIHandles.Axes.PCTH.Hist(iPatch).YData = GUIHandles.Axes.PCTH.Hist(iPatch).YData;
        GUIHandles.Axes.PCTH.Hist(iPatch).YData = GUIHandles.Axes.PCTH.Hist(iPatch).YData/sum(GUIHandles.Axes.PCTH.Hist(iPatch).YData);
        GUIHandles.Axes.PCTH.MainHandle.XLim = [-1.1 1.1]*maxlag;
        GUIHandles.Axes.PCTH.MainHandle.YLim(2) = max(GUIHandles.Axes.PCTH.MainHandle.YLim(2), 1.1*max(GUIHandles.Axes.PCTH.Hist(iPatch).YData));
        GUIHandles.Axes.PCTH.MainHandle.YLim = [-.1 1]*GUIHandles.Axes.PCTH.MainHandle.YLim(2);
    end
end
end