function Flux
% Reproduction on Bpod of protocol used in the PatonLab, MATCHINGvFix

global BpodSystem
global TaskParameters
global Latent
global sessionTimer

%% Task parameters
TaskParameters = BpodSystem.ProtocolSettings;
if isempty(fieldnames(TaskParameters))
    
    TaskParameters.GUI.MeanA = 60;
    TaskParameters.GUI.MeanB = 90;
    TaskParameters.GUI.MeanC = 120;
    TaskParameters.GUI.VI = false; % random ITI
    TaskParameters.GUIMeta.VI.Style = 'checkbox';
    TaskParameters.GUI.IntA = NaN;
    TaskParameters.GUI.IntB = NaN;
    TaskParameters.GUI.IntC = NaN;
    TaskParameters.GUIMeta.IntA.Style = 'text';
    TaskParameters.GUIMeta.IntB.Style = 'text';
    TaskParameters.GUIMeta.IntC.Style = 'text';
    TaskParameters.GUIPanels.Intervals = {'MeanA','IntA','MeanB','IntB','MeanC','IntC','VI'};
    
    %% Reward
    TaskParameters.GUI.rewFirst = 76;
    TaskParameters.GUI.rewLast = 5;
    TaskParameters.GUI.rewN = 3;
    TaskParameters.GUI.rewSum = round(sum(TaskParameters.GUI.rewFirst*(TaskParameters.GUI.rewLast/TaskParameters.GUI.rewFirst).^([0:TaskParameters.GUI.rewN-1]/(TaskParameters.GUI.rewN-1))));
    TaskParameters.GUIMeta.rewSum.Style = 'text';
    TaskParameters.GUI.IRI = 1;
    TaskParameters.GUI.rewA = TaskParameters.GUI.rewFirst;
    TaskParameters.GUIMeta.rewA.Style = 'text';
    TaskParameters.GUI.rewB = TaskParameters.GUI.rewFirst;
    TaskParameters.GUIMeta.rewB.Style = 'text';
    TaskParameters.GUI.rewC = TaskParameters.GUI.rewFirst;
    TaskParameters.GUIMeta.rewC.Style = 'text';
    TaskParameters.GUIPanels.Reward = {'rewFirst','rewLast','rewN','rewSum','IRI','rewA','rewB','rewC'};
    
    %% General
    TaskParameters.GUI.Cued = true; % light on when reward available
    TaskParameters.GUIMeta.Cued.Style = 'checkbox';
    TaskParameters.GUI.Ports_ABC = '123';
    TaskParameters.GUIPanels.General = {'Ports_ABC','Cued'};
    
    %%
    TaskParameters.GUI = orderfields(TaskParameters.GUI);
    
end
BpodParameterGUI('init', TaskParameters);

%% Trial type vectors

% Latent.SetUp = '111';
Latent.State1 = 'setup111';
if TaskParameters.GUI.VI
    Latent.Ints = exprnd([TaskParameters.GUI.MeanA, TaskParameters.GUI.MeanB, TaskParameters.GUI.MeanC]);
else
    Latent.Ints = [TaskParameters.GUI.MeanA, TaskParameters.GUI.MeanB, TaskParameters.GUI.MeanC];
end
TaskParameters.GUI.IntA = Latent.Ints(1);
TaskParameters.GUI.IntB = Latent.Ints(2);
TaskParameters.GUI.IntC = Latent.Ints(3);
Latent.ClocksSMA = Latent.Ints(:)';

Latent.rewA = TaskParameters.GUI.rewFirst;
Latent.rewB = TaskParameters.GUI.rewFirst;
Latent.rewC = TaskParameters.GUI.rewFirst;
Latent.ListX = native2unicode([48:57,65:90,97:122]);

% ValveATime  = GetValveTimes(TaskParameters.GUI.rewFirst*(TaskParameters.GUI.rewLast/...
%     TaskParameters.GUI.rewFirst)^(str2double(stateName(7))/TaskParameters.GUI.rewN), PortA);
% ValveBTime  = GetValveTimes(TaskParameters.GUI.rewFirst*(TaskParameters.GUI.rewLast/...
%     TaskParameters.GUI.rewFirst)^(str2double(stateName(8))/TaskParameters.GUI.rewN), PortB);
% ValveCTime  = GetValveTimes(TaskParameters.GUI.rewFirst*(TaskParameters.GUI.rewLast/...
%     TaskParameters.GUI.rewFirst)^(str2double(stateName(9))/TaskParameters.GUI.rewN), PortC);

% BpodSystem.Data.Custom.SetUps = cell(1,3);
% BpodSystem.Data.Custom.PokeIn = cell(1,3);
% BpodSystem.Data.Custom.Rewards = cell(1,3);

%% Server data
BpodSystem.Data.Custom.Rig = getenv('computername');
[~,BpodSystem.Data.Custom.Subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.DataPath))));

BpodSystem.Data.Custom = orderfields(BpodSystem.Data.Custom);

%% Initialize plots
temp = SessionSummary();
for i = fieldnames(temp)'
    BpodSystem.GUIHandles.(i{1}) = temp.(i{1});
end
clear temp
BpodNotebook('init');

%% User Session Start-Script
temp = randsample([TaskParameters.GUI.MeanA, TaskParameters.GUI.MeanB, TaskParameters.GUI.MeanC],3);
TaskParameters.GUI.MeanA = temp(1);
TaskParameters.GUI.MeanB = temp(2);
TaskParameters.GUI.MeanC = temp(3);
clear temp

set(BpodSystem.GUIHandles.ParameterGUI.Params{strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'MeanA')}, 'String', TaskParameters.GUI.MeanA);
set(BpodSystem.GUIHandles.ParameterGUI.Params{strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'MeanB')}, 'String', TaskParameters.GUI.MeanB);
set(BpodSystem.GUIHandles.ParameterGUI.Params{strcmp(BpodSystem.GUIData.ParameterGUI.ParamNames,'MeanC')}, 'String', TaskParameters.GUI.MeanC);

%% Main loop
RunSession = true;
% iTrial = 1;
sessionTimer = tic;

while RunSession
    
    TaskParameters = BpodParameterGUI('sync', TaskParameters);
    
    sma = stateMatrix();
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents))
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        SaveBpodSessionData;
    end
    
    
%     timeStamps = BpodSystem.Data.RawData.OriginalStateTimestamps{:};
%     if strcmp(Latent.SetUp(1),'0')
% %         elapsedA = max(timeStamps)-min(timeStamps)

%     end
    
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.BeingUsed == 0
        return
    end
    
    updateControlVars()
%     iTrial = iTrial + 1;
    try
        BpodSystem.GUIHandles = SessionSummary(BpodSystem.Data, BpodSystem.GUIHandles);
    end
end
end