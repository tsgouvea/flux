function [ sma ] = FluxStateMaker( sma )
%FLUXSTATEMAKER Defines states listed but yet undefined in SMA

if all(logical(sma.StatesDefined))
    return
end

stateName = sma.StateNames{find(~logical(sma.StatesDefined),1)};
% list(1) = [];% = list(2:end);

try
    assert(strncmp(stateName,'IRI',3) | strncmp(stateName,'setup',5) | strncmp(stateName,'water',5) | strcmp(stateName,'exit'))
catch
    error('Don''t know how to handle state with this name (TG, Feb1 18)')
end

%%
global Latent
global TaskParameters
%% Define ports
% PortA = floor(mod(TaskParameters.GUI.Ports_ABC/100,10));
% PortB = floor(mod(TaskParameters.GUI.Ports_ABC/10,10));
% PortC = mod(TaskParameters.GUI.Ports_ABC,10);
% PortAIn = strcat('Port',num2str(PortA),'In');
% PortBIn = strcat('Port',num2str(PortB),'In');
% PortCIn = strcat('Port',num2str(PortC),'In');
% ValveA = 2^(PortA-1);
% ValveB = 2^(PortB-1);
% ValveC = 2^(PortC-1);
% ValveATime  = GetValveTimes(Latent.rewA, PortA);
% ValveBTime  = GetValveTimes(Latent.rewB, PortB);
% ValveCTime  = GetValveTimes(Latent.rewC, PortC);
% PortIns = {PortAIn, PortBIn, PortCIn};
smaTimer = 0;
smaChange = {};
smaOut = {};
ABC = 'ABC';

if strncmp(stateName,'setup',5)
    for iPatch = 1:3
        if strcmp(stateName(5+iPatch),'0')
            nextState = stateName; nextState(5+iPatch) = '1';
            smaChange = {smaChange{:}, ['GlobalTimer' num2str(iPatch) '_End'],nextState};
            for jPatch = find(1:3~=iPatch)
                assert(~isnan(str2double(stateName(5+jPatch))))
                if str2double(stateName(5+jPatch)) > 1
                    PortIn = ['Port' num2str(floor(mod(TaskParameters.GUI.Ports_ABC/10^(3-iPatch),10))) 'In'];
                    nextState = stateName; nextState(5+jPatch) = '0';
                    smaChange = {smaChange{:}, PortIn, nextState};
                end
            end
        elseif ~isnan(str2double(stateName(5+iPatch))) && str2double(stateName(5+iPatch)) > 0 % strcmp(stateName(5+iPatch),'1')
%             nextState = ['IRI_' ABC(iPatch) '_' stateName(end-2:end)];
            nextState = ['water_' ABC(iPatch)];
            smaChange = {smaChange{:}, ['Port' num2str(floor(mod(TaskParameters.GUI.Ports_ABC/10^(3-iPatch),10))) 'In'], nextState};
        end
    end
elseif strncmp(stateName,'water',5)
    Port = floor(mod(TaskParameters.GUI.Ports_ABC/10^(3-find(ABC==stateName(end))),10));
    ValveTime = GetValveTimes(Latent.(['rew' stateName(end)]), Port);
    smaTimer = ValveTime;
    smaChange = {'Tup','exit'};
    smaOut = {'ValveState', 2^(Port-1)};
elseif strncmp(stateName,'IRI',3)
    for iPatch = 1:numel(ABC)
        if strcmp(stateName(5),ABC(iPatch)) % PATCH WHERE LAST REWARD WAS OBTAINED
            smaChange = {smaChange{:}, 'GlobalTimer4_End',['setup' stateName(end-2:end)]}; % THIS WILL BREAK IF ANIMAL COLLECTS >9 REWARDS ON SAME SIDE
        else % ALL OTHER PATCHES
            if strcmp(stateName(6+iPatch),'0')
                smaChange = {smaChange{:}, ['GlobalTimer' num2str(iPatch) '_End'],[stateName(1:6) ...
                    sprintf('%03i',str2double(stateName(7:9))+10^(3-iPatch))]};
                for jPatch = find(1:3~=iPatch)
                    assert(~isnan(str2double(stateName(end-3+jPatch))))
                    if str2double(stateName(end-3+jPatch)) > 1
                        PortIn = ['Port' num2str(floor(mod(TaskParameters.GUI.Ports_ABC/10^(3-iPatch),10))) 'In'];
                        assert(find(ABC==stateName(5))==jPatch)
                        nextState = ['setup' stateName(end-2:end)]; nextState(end-3+jPatch) = '0';
                        smaChange = {smaChange{:}, PortIn, nextState};
                    end
                end
            elseif strcmp(stateName(6+iPatch),'1')
                smaChange = {smaChange{:},['Port' num2str(floor(mod(TaskParameters.GUI.Ports_ABC/10^(3-iPatch),10))) 'In'],['water_' ABC(iPatch)]};
            end
        end
    end
    smaOut = {'GlobalTimerTrig', 4};
%     sma = AddState(sma, 'Name', stateName,...
%         'Timer', 0,...
%         'StateChangeConditions', smaChange,...
%         'OutputActions', {'GlobalTimerTrig', 4});
    
    
elseif strcmp(stateName,'exit')
    return
end

%%
sma = AddState(sma, 'Name', stateName,...
    'Timer', smaTimer,...
    'StateChangeConditions', smaChange,...
    'OutputActions', smaOut);

list = sma.StateNames(~logical(sma.StatesDefined));
% newStates = reshape(smaChange,2,[])'; newStates = newStates(:,2);
% list = {list{:}, newStates{:}};
% list = unique(list);
% list = list(~ismember(list,sma.Manifest(1:sma.nStatesInManifest)) & ismember(list,sma.StateNames));
