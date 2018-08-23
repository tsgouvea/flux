function getgit()
global BpodSystem
pathProt=fullfile(BpodSystem.BpodUserPath,'Protocols',BpodSystem.CurrentProtocolName,[BpodSystem.CurrentProtocolName '.m']);
try
    assert(exist(pathProt)==2);
    cmd=['git rev-parse --prefix ' fileparts(pathProt) ' --short HEAD'];
    [~,commit]=system(cmd);
    BpodSystem.Data.GitCommit=commit;
    
    cmd=['cd ' fileparts(pathProt) ' | git remote get-url origin'];
    [~,origin]=system(cmd);
    BpodSystem.Data.GitOrigin=origin;
    
catch
    warning('Failed to get git metadata')
end
