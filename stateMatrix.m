function sma = stateMatrix(varargin)
p = inputParser;
addOptional(p,'isBridgeUp',false);
parse(p,varargin{:});
isBridgeUp = p.Results.isBridgeUp;

global Latent
global TaskParameters

sma = NewStateMatrix();
sma = SetGlobalTimer(sma,1,Latent.ClocksSMA(1));
sma = SetGlobalTimer(sma,2,Latent.ClocksSMA(2));
sma = SetGlobalTimer(sma,3,Latent.ClocksSMA(3));
sma = SetGlobalTimer(sma,4,TaskParameters.GUI.IRI);
sma = SetGlobalTimer(sma,5,Latent.jackNext);
if isBridgeUp
    sma = AddState(sma, 'Name', 'state_0',...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'bridgeUp'},...
        'OutputActions', {});
else
    sma = AddState(sma, 'Name', 'state_0',...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'bridgeDown'},...
        'OutputActions', {});
end
sma = AddState(sma, 'Name', 'bridgeUp',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'syncCamera'},...
    'OutputActions', {'Serial1Code', 255});
sma = AddState(sma, 'Name', 'bridgeDown',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'syncCamera'},...
    'OutputActions', {'Serial1Code', 1});
sma = AddState(sma, 'Name', 'syncCamera',...
    'Timer', 0.150,...
    'StateChangeConditions', {'Tup', 'trig1'},...
    'OutputActions', {'PWM8', 255});
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
    'StateChangeConditions', {'Tup', 'trig4'},...
    'OutputActions', {'GlobalTimerTrig', 3});
sma = AddState(sma, 'Name', 'trig4',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup', Latent.State1},...
    'OutputActions', {'GlobalTimerTrig', 5});

while any(~logical(sma.StatesDefined))
    sma = FluxStateMaker(sma);
end
end