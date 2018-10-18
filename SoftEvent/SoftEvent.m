function SoftEvent

% Clear the command window
clc;

% Add the 'Stimulus' subfolder to tht path (temporarily)
addpath('Stimulus');

% Load global variables 
global BpodSystem     % default Bpod variable
global TaskParameters % custom structure to store only task related variables

% Specify the Softcode callback function that will be executed and trigger 
% the stimulus generation...
%BpodSystem.SoftCodeHandlerFunction = 'ThreatSoftcode';


%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.CurrentBlock = 1; % Training level % 1 = Direct Delivery at both ports 2 = Poke for delivery
    S.GUI.RewardAmount = 5; %ul
    S.GUI.PortOutRegDelay = 0.5; % How long the mouse must remain out before poking back in
end

% Initialize parameter GUI plugin
BpodParameterGUI('init', S);

%% Define trials
numTrials = 500;
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.

%% Initialize plots
% TrialType Outcome Plot (displays each future trial type, and scores completed trials as correct/incorrect
BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [200 200 1000 200],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.OutcomePlot = axes('Position', [.075 .3 .89 .6]);
%TrialTypeOutcomePlot(BpodSystem.GUIHandles.OutcomePlot,'init',TrialTypes);
% Bpod Notebook (to record text notes about the session or individual trials)
BpodNotebook('init');



%% Main trial loop
for currentTrial = 1:numTrials
    
    Change 4725 to whatever you want!!!
    
    
    [ds, dp, rx_timer] = UDPServerCreate('lo', 4725);
    
    TaskParameters.ds = ds;
    TaskParameters.rx_timer = rx_timer;

    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    
    sma = NewStateMatrix(); % Assemble state matrix
    
    sma = AddState(sma, 'Name', 'Port1LightOn', ...
        'Timer', 1,...
        'StateChangeConditions', {'SoftCode5', 'Port3LightOn'},...
        'OutputActions', {'PWM1', 255});
    sma = AddState(sma, 'Name', 'Port3LightOn', ...
        'Timer', 1,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'PWM3', 255});

        % Send sate matrix to Bpod hardware
    SendStateMatrix(sma);
    
    % Start the state matrix and wait for Bpod to come to an end
    % If in the meantime the user presses the stop button, the state matrix
    % will be terminated and no data for the current trial will be
    % collected
    RawEvents = RunStateMatrix;
    
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        %BpodSystem.Data.(currentTrial) = TrialTypes(currentTrial); % Adds the trial type of the current trial to data
        %UpdateOutcomePlot(TrialTypes, BpodSystem.Data);
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    end
    
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    
    if BpodSystem.BeingUsed == 0
        return
    end
    
    stop(rx_timer);
    UDPServerClose(ds);
end







function UpdateOutcomePlot(TrialTypes, Data)
% Determine outcomes from state data and score as the SideOutcomePlot plugin expects
    % global BpodSystem
    % Outcomes = zeros(1,Data.nTrials);
    % for x = 1:Data.nTrials
    %     if ~isnan(Data.RawEvents.Trial{x}.States.Drinking(1))
    %         Outcomes(x) = 1;
    %     else
    %         Outcomes(x) = 3;
    %     end
    % end
    % TrialTypeOutcomePlot(BpodSystem.GUIHandles.OutcomePlot,'update',Data.nTrials+1,TrialTypes,Outcomes);


