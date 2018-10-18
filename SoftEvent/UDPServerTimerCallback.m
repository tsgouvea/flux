function UDPServerTimerCallback(obj, event, ds, dp)
%UDPSERVERTIMERCALLBACK Summary of this function goes here
%   Detailed explanation goes here

global BpodSystem; 
packetReceived = 0;
try
    ds.receive(dp);
    packetReceived = 1;
catch ME
    switch (ME.identifier)
        % Check for Java exceptions
        case 'MATLAB:Java:GenericException'
            excobj = ME.ExceptionObject;
            switch (class(excobj))
                case 'java.net.SocketTimeoutException'
                    %disp('TimeOut');
                otherwise
                    disp(class(excobj));
            end
            
            % Check for MATLAB exceptions
        otherwise
            ds.close();
            rethrow(ME);
    end
end

if (packetReceived)
    %     disp('Packet received');
    %     N = dp.getLength();
    %     data = uint8(dp.getData());
    %     data = data(1:1:N)';
    %     disp(data);
    %     disp(native2unicode(data));
    
    N = dp.getLength();
    data = uint8(dp.getData());
    data = data(1:1:N)';
    rx_byte = data(12);
    fprintf('Received value: %i\n', rx_byte);
    
    if (rx_byte > 0) && (rx_byte <= 10)
        fprintf('Trigger event SoftCode%i', rx_byte);
        disp('Here');
        SendBpodSoftCode(rx_byte);
    end 
end

