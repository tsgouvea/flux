function Flux
% Reproduction on Bpod of protocol used in the PatonLab, MATCHINGvFix

global BpodSystem
global TaskParameters
global Latent
global sessionTimer

%% Task parameters
TaskParameters = BpodSystem.ProtocolSettings;
if isempty(fieldnames(TaskParameters))
    
    TaskParameters.GUI.MeanA = 3;
    TaskParameters.GUI.MeanB = 9;
    TaskParameters.GUI.MeanC = 27;
    TaskParameters.GUI.VI = false; % random ITI
    TaskParameters.GUIMeta.VI.Style = 'checkbox';
    TaskParameters.GUI.IntA = NaN;
    TaskParameters.GUI.IntB = NaN;
    TaskParameters.GUI.IntC = NaN;
    TaskParameters.GUIMeta.IntA.Style = 'text';
    TaskParameters.GUIMeta.IntB.Style = 'text';
    TaskParameters.GUIMeta.IntC.Style = 'text';
    TaskParameters.GUIPanels.Intervals = {'MeanA','IntA','MeanB','IntB','MeanC','IntC','VI'};
    
    %% General
    TaskParameters.GUI.Ports_ABC = '123';
    TaskParameters.GUI.rewardAmount = 100;
    TaskParameters.GUIPanels.General = {'Ports_ABC','rewardAmount'};
    TaskParameters.GUI = orderfields(TaskParameters.GUI);
end
BpodParameterGUI('init', TaskParameters);

%% Trial type vectors

% BpodSystem.Data.Custom.Intervals1 = exprnd(TaskParameters.GUI.MeanA,500,1);
% BpodSystem.Data.Custom.Intervals2 = exprnd(TaskParameters.GUI.MeanB,500,1);
% BpodSystem.Data.Custom.Intervals3 = exprnd(TaskParameters.GUI.MeanC,500,1);

Latent.SetUp = '000';
if TaskParameters.GUI.VI
    Latent.Ints = exprnd([TaskParameters.GUI.MeanA, TaskParameters.GUI.MeanB, TaskParameters.GUI.MeanC]);
else
    Latent.Ints = [TaskParameters.GUI.MeanA, TaskParameters.GUI.MeanB, TaskParameters.GUI.MeanC];
end
TaskParameters.GUI.IntA = Latent.Ints(1);
TaskParameters.GUI.IntB = Latent.Ints(2);
TaskParameters.GUI.IntC = Latent.Ints(3);
Latent.IntSma = Latent.Ints(:)';

BpodSystem.Data.Custom.SetUps = cell(1,3);
BpodSystem.Data.Custom.PokeIn = cell(1,3);
BpodSystem.Data.Custom.Rewards = cell(1,3);

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
    
    updateCustomDataFields()
%     iTrial = iTrial + 1;
    BpodSystem.GUIHandles = SessionSummary(BpodSystem.Data, BpodSystem.GUIHandles);
end
end