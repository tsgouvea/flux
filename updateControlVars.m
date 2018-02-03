function updateCustomDataFields()
%% Define variables
global BpodSystem
global TaskParameters
global Latent
ABC = 'ABC';

%% Compute visited states
listStates = BpodSystem.Data.RawData.OriginalStateNamesByNumber{end};
visited = BpodSystem.Data.RawData.OriginalStateData(end); visited = visited{:};
if numel(visited) == 1
    return
end
try
    assert(strncmp('setup',listStates{visited(end-1)}(1:5),5))
catch
    warning('Second to last state expected to be a setup state. This might be a rare case of reward during IRI. List of visited states:')
    display(listStates(visited))
end

%% Set State1 for next trial
if strncmp('water',listStates{visited(end)},5)
    ndxRwdArm = listStates{visited(end)}(end)==ABC;
    Latent.State1 = ['IRI_' ABC(ndxRwdArm) '_' ...
        sprintf('%03i',str2double(listStates{visited(end-1)}(end-2:end))+10^(3-find(ndxRwdArm)))];
    assert(numel(Latent.State1)==9);
%     if strcmp(Latent.State1(6+find(ndxRwdArm)),num2str(TaskParameters.GUI.rewN+1))
%         Latent.State1(6+find(ndxRwdArm)) = '0';
%         Latent.State1 = ['setup' Latent.State1(end-2:end)];
%     end
    for iPatch = find(~ndxRwdArm)
        assert(~isnan(str2double(Latent.State1(end-3+iPatch))))
        if str2double(Latent.State1(end-3+iPatch)) ~= 1
            Latent.State1(end-3+iPatch) = '0'; % with exception of last visited arm, all others must be set to either 0 or 1
        end
    end
else
    Latent.State1 = 'setup111';
    warning('Previous trial expected to end on a water state. State1 reinitialized to setup111. List of visited states:')
    display(listStates(visited))
end

%% Set reward magnitudes for next trial

if strncmp('setup',Latent.State1,5)
    for iPatch = find(~ndxRwdArm)
        Latent.(['rew' ABC(iPatch)]) = TaskParameters.GUI.rewFirst;
        TaskParameters.GUI.(['rew' ABC(iPatch)]) = Latent.(['rew' ABC(iPatch)]);
    end
    TaskParameters.GUI.(['rew' ABC(ndxRwdArm)]) = 0;
elseif strncmp('IRI',Latent.State1,3)
    assert(all(ndxRwdArm == (Latent.State1(5)==ABC)));
    Latent.(['rew' ABC(ndxRwdArm)]) = TaskParameters.GUI.rewFirst*(TaskParameters.GUI.rewLast/...
        TaskParameters.GUI.rewFirst)^((str2double(Latent.State1(6+find(ndxRwdArm)))-1)/(TaskParameters.GUI.rewN-1));
    TaskParameters.GUI.(['rew' ABC(ndxRwdArm)]) = Latent.(['rew' ABC(ndxRwdArm)]);
    for iPatch = find(~ndxRwdArm)
        Latent.(['rew' ABC(iPatch)]) = TaskParameters.GUI.rewFirst;
        TaskParameters.GUI.(['rew' ABC(iPatch)]) = Latent.(['rew' ABC(iPatch)]);
    end
end

%% Set timers for next trial

trialDur = BpodSystem.Data.RawEvents.Trial{end}.States.(listStates{visited(end)})(end);

for iPatch = [1 2 3]
    if strcmp(Latent.State1(end-3+iPatch),'0')
        Latent.ClocksSMA(iPatch) = max(Latent.ClocksSMA(iPatch)-trialDur, 1);
    elseif strcmp(Latent.State1(end-3+iPatch),'2')
        if strcmp(ABC(iPatch),listStates{visited(end)}(end))
            Latent.ClocksSMA(iPatch) = TaskParameters.GUI.(['Mean' ABC(iPatch)]);
            if TaskParameters.GUI.VI
                Latent.ClocksSMA(iPatch) = ceil(exprnd(Latent.ClocksSMA(iPatch)));
            end
            TaskParameters.GUI.(['Int' ABC(iPatch)]) = Latent.ClocksSMA(iPatch);
        end
    end
end

% if strncmp('IRI',Latent.State1,3)
%     ndxRwdArm = Latent.State1(5)==ABC;
%     Latent.ClocksSMA(ndxRwdArm) = TaskParameters.GUI.IRI;
%     for iPatch = find(~ndxRwdArm)
%         if strcmp(Latent.SetUp(iPatch),'0')
%             Latent.ClocksSMA(iPatch) = max(Latent.ClocksSMA(iPatch)-trialDur, 1);
%         end
%     end
%     
%     if strcmp(Latent.SetUp(iPatch),'0')
%         Latent.ClocksSMA(iPatch) = max(Latent.ClocksSMA(iPatch)-trialDur, 1);
%     elseif strcmp(listStates{visited(end)},['water_' ABC(iPatch)])
%         Latent.SetUp(iPatch) = '0'; %% INCREMENT THIS
%         Latent.Ints(iPatch) = TaskParameters.GUI.(['Mean' ABC(iPatch)]);
%         if TaskParameters.GUI.VI
%             Latent.Ints(iPatch) = ceil(exprnd(Latent.Ints(iPatch)));
%         end
%         Latent.ClocksSMA(iPatch) = Latent.Ints(iPatch);
%         TaskParameters.GUI.(['Int' ABC(iPatch)]) = Latent.ClocksSMA(iPatch);
%     end
% 
% %% rubbish
% for iPatch = [1 2 3]
%     %% Update custom data fields
%     if isfield(BpodSystem.Data.RawEvents.Trial{end}.Events,['GlobalTimer' num2str(iPatch) '_End'])
% %         BpodSystem.Data.Custom.SetUps{iPatch} = [BpodSystem.Data.Custom.SetUps{iPatch}, tsOffSet + BpodSystem.Data.RawEvents.Trial{end}.Events.(['GlobalTimer' num2str(iPatch) '_End'])];
%         if ~strcmp(Latent.SetUp(end-3+iPatch),'1') %% IT MIGHT BE NUMERIC > 1
%             Latent.SetUp(end-3+iPatch) = '1';
%             warning(['GlobalTimer' num2str(iPatch) '_End failed to setup reward'])
%         end
%     end
%     
% %     if isfield(BpodSystem.Data.RawEvents.Trial{end}.Events,['Port' num2str(iPatch) 'In'])
% %         BpodSystem.Data.Custom.PokeIn{iPatch} = [BpodSystem.Data.Custom.PokeIn{iPatch}, tsOffSet + BpodSystem.Data.RawEvents.Trial{end}.Events.(['Port' num2str(iPatch) 'In'])];
% %     end
% %     if ~isnan(BpodSystem.Data.RawEvents.Trial{end}.States.(['water_' ABC(iPatch)])(1))
% %         BpodSystem.Data.Custom.Rewards{iPatch}(end+1) = tsOffSet + BpodSystem.Data.RawEvents.Trial{end}.States.(['water_' ABC(iPatch)])(1);
% %     end
%     
%     %% Update latent variables
%     if strcmp(Latent.SetUp(iPatch),'0')
%         Latent.ClocksSMA(iPatch) = max(Latent.ClocksSMA(iPatch)-trialDur, 1);
%     elseif strcmp(listStates{visited(end)},['water_' ABC(iPatch)])
%         Latent.SetUp(iPatch) = '0'; %% INCREMENT THIS
%         Latent.Ints(iPatch) = TaskParameters.GUI.(['Mean' ABC(iPatch)]);
%         if TaskParameters.GUI.VI
%             Latent.Ints(iPatch) = ceil(exprnd(Latent.Ints(iPatch)));
%         end
%         Latent.ClocksSMA(iPatch) = Latent.Ints(iPatch);
%         TaskParameters.GUI.(['Int' ABC(iPatch)]) = Latent.ClocksSMA(iPatch);
%     end
% end
end