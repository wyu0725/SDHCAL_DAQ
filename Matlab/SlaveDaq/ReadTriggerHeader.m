function [ TriggerHeader, DataPoint ] = ReadTriggerHeader( Data, DataPoint )
    TriggerHeader = 0;
    for i = 1:1:4
        TriggerHeader = TriggerHeader + Data(i + DataPoint)*4^(4 - i);
    end
    DataPoint = DataPoint + 4;
end

