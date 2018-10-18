% Create an UDP-Server on the localhost/loopback interface on port 4711
% ds is the socket objec
% dp is the datagramPacket object
% rx_timer is the timer that checks if anything got received

% This call should be placed at the beginning of the Bpod-Protocol before
% entering the loop
[ds, dp, rx_timer] = UDPServerCreate('lo', 4713);

% faked Bpod execution
pause(120);

% This call should be placed at the ent of the protocol to ensure that the
% UDP server socket will be closed and the port will be free for the next
% run of the protocol...
UDPServerClose(ds);