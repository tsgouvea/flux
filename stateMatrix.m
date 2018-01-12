function sma = stateMatrix()
global Latent
global TaskParameters
%% Define ports
PortA = floor(mod(TaskParameters.GUI.Ports_ABC/100,10));
PortB = floor(mod(TaskParameters.GUI.Ports_ABC/10,10));
PortC = mod(TaskParameters.GUI.Ports_ABC,10);
% ValveTimes  = GetValveTimes(TaskParameters.GUI.rewardAmount, [PortA PortB PortC]);
% PortAOut = strcat('Port',num2str(PortA),'Out');
% PortBOut = strcat('Port',num2str(PortB),'Out');
% PortCOut = strcat('Port',num2str(PortC),'Out');
PortAIn = strcat('Port',num2str(PortA),'In');
PortBIn = strcat('Port',num2str(PortB),'In');
PortCIn = strcat('Port',num2str(PortC),'In');

ValveA = 2^(PortA-1);
ValveB = 2^(PortB-1);
ValveC = 2^(PortC-1);

ValveATime  = GetValveTimes(TaskParameters.GUI.rewardAmount, PortA);
ValveBTime  = GetValveTimes(TaskParameters.GUI.rewardAmount, PortB);
ValveCTime  = GetValveTimes(TaskParameters.GUI.rewardAmount, PortC);

%%
sma = NewStateMatrix();
sma = SetGlobalTimer(sma,1,Latent.IntSma(1));
sma = SetGlobalTimer(sma,2,Latent.IntSma(2));
sma = SetGlobalTimer(sma,3,Latent.IntSma(3));
% sma = SetGlobalTimer(sma,1,10);
% sma = SetGlobalTimer(sma,2,8);
% sma = SetGlobalTimer(sma,3,12);
sma = AddState(sma, 'Name', 'state_0',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'trig1'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'trig1',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'trig2'},...
    'OutputActions', {'GlobalTimerTrig', 1});
sma = AddState(sma, 'Name', 'trig2',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'trig3'},...
    'OutputActions', {'GlobalTimerTrig', 2});
sma = AddState(sma, 'Name', 'trig3',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup', ['setup' Latent.SetUp]},...
    'OutputActions', {'GlobalTimerTrig', 3});

for iA = [0, 1]
    for iB = [0, 1]
        for iC = [0, 1]
            stateName = ['setup' num2str([iA,iB,iC]')'];
            stateChangCond = {};
            outAct = {};
            if iA == 0
                stateChangCond = {stateChangCond{:}, 'GlobalTimer1_End',['setup' num2str([1,iB,iC]')']};
            elseif iA == 1
                stateChangCond = {stateChangCond{:}, PortAIn,'water_A'};
            end
            if iB == 0
                stateChangCond = {stateChangCond{:}, 'GlobalTimer2_End',['setup' num2str([iA,1,iC]')']};
            elseif iB == 1
                stateChangCond = {stateChangCond{:}, PortBIn,'water_B'};
            end
            if iC == 0
                stateChangCond = {stateChangCond{:}, 'GlobalTimer3_End',['setup' num2str([iA,iB,1]')']};
            elseif iC == 1
                stateChangCond = {stateChangCond{:}, PortCIn,'water_C'};
            end
%             display(stateName)
%             display(stateChangCond)
            sma = AddState(sma,'Name',stateName,'Timer',0,...
                'StateChangeConditions', stateChangCond,'OutputActions', outAct);
        end
    end
end
sma = AddState(sma, 'Name', 'water_A',...
    'Timer', ValveATime,...
    'StateChangeConditions', {'Tup','exit'},...
    'OutputActions', {'ValveState', ValveA});
sma = AddState(sma, 'Name', 'water_B',...
    'Timer', ValveBTime,...
    'StateChangeConditions', {'Tup','exit'},...
    'OutputActions', {'ValveState', ValveB});
sma = AddState(sma, 'Name', 'water_C',...
    'Timer', ValveCTime,...
    'StateChangeConditions', {'Tup','exit'},...
    'OutputActions', {'ValveState', ValveC});
end