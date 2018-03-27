function [ Header, BCID, ChannelData, TriggerHeader, TriggerCount ] = ReadSlaveDaqPackage( InitialData, PackageNumber )
    % Read one pack
    StartNumber = (PackageNumber-1)*96;
    Header = 0;
    for i=1:4
        Header = Header + InitialData(i + StartNumber)*4^(4-i);
    end
    BCID = 0;
    for i = 5:16
        BCID = BCID + InitialData(i + StartNumber)*4^(16 - i);
    end
    ChannelData = zeros(64,1);
    for i = 0:3
        k = 3 -i;
        for j = 1:16
            ChannelData(16*k + j) = InitialData(16 + j + i*16 + StartNumber);
            %Ch_data(16*k + j) = bitand(InitialData(16 + j + i*16 + StartNum),1)*2  + bitand(InitialData(16 + j + i*16 + StartNum),2)/2;
        end
    end
    TriggerHeader = 0;
    TriggerCount = 0;
    for i = 81:1:84
        TriggerHeader = TriggerHeader + InitialData(i + StartNumber)*4^(4 + 80 - i);
    end
    for i = 85:1:96
        TriggerCount = TriggerCount + InitialData(i + StartNumber)*4^(12 + 84 -i );
    end
    
    
end

