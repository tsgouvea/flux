function UserKillScript()
%USERKILLSCRIPT Execute some code when the user presses the Bpod stop button
%
% When the user presses the stop button, the additional/external figure
% that presents the stimulus should be closed...
%
% Authors: David Bonda
%          Michael Wulf
%          Cold Spring Harbor Laboratory
%          Kepecs Lab
%          One Bungtown Road
%          Cold Spring Harboor
%          NY 11724, USA
% 
% Date:    10/09/2018 
% Version: 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the global structure 'TaskParameters'
global TaskParameters;

stop(TaskParameters.rx_timer);
UDPServerClose(TaskParameters.ds);


end % function

