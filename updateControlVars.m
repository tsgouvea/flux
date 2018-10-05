function updateControlVars()
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

%% Set State1 for next trial
if (strncmp('water',listStates{visited(end)},5))
    ndxRwdArm = listStates{visited(end)}(end)==ABC;
    if TaskParameters.GUI.Deplete
        Latent.State1 = ['IRI_' ABC(ndxRwdArm) '_' listStates{visited(end-1)}(end-2:end)];
        try
            Latent.State1(end-3+find(ndxRwdArm)) = Latent.ListX(find(Latent.ListX==Latent.State1(end-3+find(ndxRwdArm)))+1);
        catch
            warning('Animal collected a sequence of rewards longer than allowed. Try increasing Latent.ListX, and consider checking noseports. (TG Feb 2, 2018)')
        end
        for iPatch = find(~ndxRwdArm)
            if ~strcmp(Latent.State1(end-3+iPatch),'1')
                Latent.State1(end-3+iPatch) = '0'; % with exception of last visited arm, all others must be set to either 0 or 1
            end
        end
    else
        Latent.State1 = ['setup' listStates{visited(end-1)}(end-2:end)];
        Latent.State1(end-3+find(ndxRwdArm)) = '0';
    end
elseif (strncmp('reset',listStates{visited(end)},5))
    Latent.State1 = ['setup' listStates{visited(end)}(end-2:end)];
end

%% Set reward magnitudes for next trial
for iPatch = 1:numel(ABC)
    Latent.(['rew' ABC(iPatch)]) = TaskParameters.GUI.rewFirst;
    TaskParameters.GUI.(['rew' ABC(iPatch)]) = Latent.(['rew' ABC(iPatch)]);
end
if TaskParameters.GUI.Deplete
    TaskParameters.GUI.rewSum = round(sum(TaskParameters.GUI.rewFirst*(TaskParameters.GUI.rewLast/TaskParameters.GUI.rewFirst).^([0:TaskParameters.GUI.rewN-1]/(TaskParameters.GUI.rewN-1))));
    if (strncmp('water',listStates{visited(end)},5))
        n = find(Latent.ListX==Latent.State1(end-3+find(ndxRwdArm)))-1;
        Latent.(['rew' ABC(ndxRwdArm)]) = ceil(TaskParameters.GUI.rewFirst*(TaskParameters.GUI.rewLast/...
            TaskParameters.GUI.rewFirst)^((n-1)/(TaskParameters.GUI.rewN-1)));
        TaskParameters.GUI.(['rew' ABC(ndxRwdArm)]) = Latent.(['rew' ABC(ndxRwdArm)]);
    end
end

%% Set timers for next trial

trialDur = BpodSystem.Data.RawEvents.Trial{end}.States.(listStates{visited(end)})(end);

for iPatch = [1 2 3]
    if TaskParameters.GUI.Deplete
        if strcmp(Latent.State1(end-3+iPatch),'0')
            Latent.ClocksSMA(iPatch) = max(Latent.ClocksSMA(iPatch)-trialDur, 1);
        elseif find(Latent.ListX == Latent.State1(end-3+iPatch)) > find(Latent.ListX == '1')
            if strcmp(ABC(iPatch),listStates{visited(end)}(end))
                Latent.ClocksSMA(iPatch) = TaskParameters.GUI.(['Mean' ABC(iPatch)]);
                if TaskParameters.GUI.VI
                    Latent.ClocksSMA(iPatch) = ceil(exprnd(Latent.ClocksSMA(iPatch)));
                end
                TaskParameters.GUI.(['Int' ABC(iPatch)]) = Latent.ClocksSMA(iPatch);
            end
        end
    else
        if iPatch == find(ndxRwdArm)
            Latent.ClocksSMA(iPatch) = TaskParameters.GUI.(['Mean' ABC(iPatch)]);
            if TaskParameters.GUI.VI
                Latent.ClocksSMA(iPatch) = ceil(exprnd(Latent.ClocksSMA(iPatch)));
            end
            TaskParameters.GUI.(['Int' ABC(iPatch)]) = Latent.ClocksSMA(iPatch);
        elseif strcmp(Latent.State1(end-3+iPatch),'0')
            Latent.ClocksSMA(iPatch) = max(Latent.ClocksSMA(iPatch)-trialDur, 1);
        end
    end    
end
Latent.ClocksSMA = min(Latent.ClocksSMA,3600);%Bpod limit
end