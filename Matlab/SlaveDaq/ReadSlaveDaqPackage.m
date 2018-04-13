function [ Header, BCID, ChannelData, TriggerHeader, TriggerCount, DataPoint ] = ReadSlaveDaqPackage( InitialData, DataPoint )
    % Read one pack
    [Header, DataPoint ]= ReadChipID(InitialData, DataPoint);
    [BCID, DataPoint ] = ReadBCID(InitialData, DataPoint);
    [ChannelData, DataPoint] = ReadChannelData(InitialData,DataPoint);
    [TriggerHeader, DataPoint] = ReadTriggerHeader(InitialData,DataPoint);
    while(TriggerHeader ~= 241)
        DataPoint = DataPoint + 76;
        [TriggerHeader, DataPoint] = ReadTriggerHeader(InitialData,DataPoint);
    end
    [TriggerCount, DataPoint] = ReadTriggerCount(InitialData,DataPoint);   
end

