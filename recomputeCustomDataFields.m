function Data = recomputeCustomDataFields(Data)
ABC = 'ABC';
listStates = Data.RawData.OriginalStateNamesByNumber{:};
Data.Custom.PokeIn = cell(3,1);
Data.Custom.Rewards = cell(3,1);
Data.Custom.SetUps = cell(3,1);

Data.Custom.IdPoke = [];
Data.Custom.TsPoke = [];
Data.Custom.IdRew = [];
Data.Custom.TsRew = [];
Data.Custom.IdSetup = [];
Data.Custom.TsSetup = [];
Data.Custom.ndxSwitch = [];

%%
for iTrial = 1:Data.nTrials
    visited = Data.RawData.OriginalStateData(iTrial); visited = visited{:};
    if numel(visited) == 1
        break
    end
    tsOffTrial = Data.TrialStartTimestamp(iTrial) - Data.TrialStartTimestamp(1);
    for iPatch = [1 2 3]
        if isfield(Data.RawEvents.Trial{iTrial}.Events,['GlobalTimer' num2str(iPatch) '_End'])
            Data.Custom.SetUps{iPatch} = [Data.Custom.SetUps{iPatch}, tsOffTrial + Data.RawEvents.Trial{iTrial}.Events.(['GlobalTimer' num2str(iPatch) '_End'])];
        end
        if isfield(Data.RawEvents.Trial{iTrial}.Events,['Port' num2str(iPatch) 'In'])
            Data.Custom.PokeIn{iPatch} = [Data.Custom.PokeIn{iPatch}, tsOffTrial + Data.RawEvents.Trial{iTrial}.Events.(['Port' num2str(iPatch) 'In'])];
        end
        if ~isnan(Data.RawEvents.Trial{iTrial}.States.(['water_' ABC(iPatch)])(1))
            Data.Custom.Rewards{iPatch}(end+1) = tsOffTrial + Data.RawEvents.Trial{iTrial}.States.(['water_' ABC(iPatch)])(1);
        end
    end
end

for iPatch = [1 2 3]
    Data.Custom.IdPoke = [Data.Custom.IdPoke; iPatch*ones(numel(Data.Custom.PokeIn{iPatch}),1)];
    Data.Custom.TsPoke = [Data.Custom.TsPoke; Data.Custom.PokeIn{iPatch}(:)];
    Data.Custom.IdRew = [Data.Custom.IdRew; iPatch*ones(numel(Data.Custom.Rewards{iPatch}),1)];
    Data.Custom.TsRew = [Data.Custom.TsRew; Data.Custom.Rewards{iPatch}(:)];
    Data.Custom.IdSetup = [Data.Custom.IdSetup; iPatch*ones(numel(Data.Custom.SetUps{iPatch}),1)];
    Data.Custom.TsSetup = [Data.Custom.TsSetup; Data.Custom.SetUps{iPatch}(:)];
end

[Data.Custom.TsPoke, ndxPoke] = sort(Data.Custom.TsPoke);
Data.Custom.IdPoke = Data.Custom.IdPoke(ndxPoke);

[Data.Custom.TsRew, ndxRew] = sort(Data.Custom.TsRew);
Data.Custom.IdRew = Data.Custom.IdRew(ndxRew);

[Data.Custom.TsSetup, ndxSetup] = sort(Data.Custom.TsSetup);
Data.Custom.IdSetup = Data.Custom.IdSetup(ndxSetup);

Data.Custom.ndxSwitch = [false; diff(Data.Custom.IdPoke)~=0];
end