function [ TriggerCount, DataPoint ] = ReadTriggerCount( Data, DataPoint )
    TriggerCount = 0;
    for i = 1:1:12
        TriggerCount = TriggerCount + Data(i + DataPoint)*4^(12 - i );
    end
    DataPoint = DataPoint + 12;
end

