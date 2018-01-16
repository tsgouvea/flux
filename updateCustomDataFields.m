function updateCustomDataFields()
global BpodSystem
global TaskParameters
global Latent
% global sessionTimer

listStates = BpodSystem.Data.RawData.OriginalStateNamesByNumber{:};
visited = BpodSystem.Data.RawData.OriginalStateData(end); visited = visited{:};
if numel(visited) == 1
    return
end
Latent.SetUp = listStates{visited(end-1)}(end-2:end);
trialDur = BpodSystem.Data.RawEvents.Trial{end}.States.(listStates{visited(end)})(end);

ABC = 'ABC';

tsOffSet = BpodSystem.Data.TrialStartTimestamp(end) - BpodSystem.Data.TrialStartTimestamp(1);
for iPatch = [1 2 3]
    %% Update custom data fields
    if isfield(BpodSystem.Data.RawEvents.Trial{end}.Events,['GlobalTimer' num2str(iPatch) '_End'])
        BpodSystem.Data.Custom.SetUps{iPatch} = [BpodSystem.Data.Custom.SetUps{iPatch}, tsOffSet + BpodSystem.Data.RawEvents.Trial{end}.Events.(['GlobalTimer' num2str(iPatch) '_End'])];
        if ~strcmp(Latent.SetUp(end-3+iPatch),'1')
            Latent.SetUp(end-3+iPatch) = '1';
            warning(['GlobalTimer' num2str(iPatch) '_End failed to setup reward'])
        end
    end
    
    if isfield(BpodSystem.Data.RawEvents.Trial{end}.Events,['Port' num2str(iPatch) 'In'])
        BpodSystem.Data.Custom.PokeIn{iPatch} = [BpodSystem.Data.Custom.PokeIn{iPatch}, tsOffSet + BpodSystem.Data.RawEvents.Trial{end}.Events.(['Port' num2str(iPatch) 'In'])];
    end
    if ~isnan(BpodSystem.Data.RawEvents.Trial{end}.States.(['water_' ABC(iPatch)])(1))
        BpodSystem.Data.Custom.Rewards{iPatch}(end+1) = tsOffSet + BpodSystem.Data.RawEvents.Trial{end}.States.(['water_' ABC(iPatch)])(1);
    end
    
    %% Update latent variables
    if strcmp(Latent.SetUp(iPatch),'0')
        Latent.IntSma(iPatch) = max(Latent.IntSma(iPatch)-trialDur, 1);
    elseif strcmp(listStates{visited(end)},['water_' ABC(iPatch)])
        Latent.SetUp(iPatch) = '0';
        Latent.Ints(iPatch) = TaskParameters.GUI.(['Mean' ABC(iPatch)]);
        if TaskParameters.GUI.VI
            Latent.Ints(iPatch) = ceil(exprnd(Latent.Ints(iPatch)));
        end
        Latent.IntSma(iPatch) = Latent.Ints(iPatch);
        TaskParameters.GUI.(['Int' ABC(iPatch)]) = Latent.IntSma(iPatch);
    end
end
end