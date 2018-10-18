function [ds,dp,rx_timer] = UDPServerCreate(iface, port)

% Necessary Java imports
import java.net.*;
import java.io.*;
import java.util.*;

server_iface      = [];
server_iface_inet = [];

% Get an enumeration object of all existing network interfaces
iface_enum = NetworkInterface.getNetworkInterfaces();

% Take only the specified interface
iface_found = 0;
while (iface_enum.hasMoreElements)
    curr_iface = iface_enum.nextElement;
    if ( strcmpi(curr_iface.getName(), iface) )
        server_iface = curr_iface;
        iface_found = 1;
        clear curr_iface;
        clear iface_enum;
        break;
    end
end

if (iface_found == 0)
    ME = MException('UDPServer:interfaceNotFound', ...
                    'Interface %s not found on system', server_iface_name);
    throw(ME);
end
clear iface_found;

% Get the maximum transfer unit of that interface to create the receive
% buffer of the same size
MTU = server_iface.getMTU();
if ( server_iface.isLoopback() )
    MTU = 1500;
end
rx_buffer = uint8(zeros(1, MTU));

% Create a datagram packet
dp = DatagramPacket(rx_buffer, MTU);

inet_enum = server_iface.getInetAddresses;

if ( isempty(inet_enum) )
    ME = MException('UDPServer:noInterfaceAddressFound', ...
                    'Interface %s has no inet address', server_iface_name);
    throw(ME);
end
% Take the first entry of the enum
inet_addr = inet_enum.nextElement;

% Create a DatagramSocket object to
try
    ds = DatagramSocket(port, inet_addr);
catch ME
    switch (ME.identifier)
        % Check for Java exceptions
        case 'MATLAB:Java:GenericException'
            excobj = ME.ExceptionObject;
            switch (class(excobj))
                case 'java.net.BindException'
                    error('Unable to open UDP port %d! Port is already in use...', port);
                otherwise
                    disp(class(excobj));
            end
            
            % Check for MATLAB exceptions
        otherwise
            ds.close();
            rethrow(ME);
    end
end

ds.setSoTimeout(10);

rx_timer            = timer;
rx_timer.StartDelay = 0;
rx_timer.Period     = 0.01;
%rx_timer.TimerFcn   = {@RX_Timer_Handler, ds, dp};
rx_timer.TimerFcn   = {@UDPServerTimerCallback, ds, dp};
rx_timer.ExecutionMode = 'fixedSpacing';
start(rx_timer);

end

