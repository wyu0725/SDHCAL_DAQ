function [ TriggerCount, PackageEnd ] = CheckPackageEnd( InitialData, DataPoint )
    Tail = 0;
    for i=1:8
        Tail = Tail + InitialData(i + DataPoint)*4^(8-i);
    end
    DataPoint = DataPoint + 8;
    if(Tail == 65349)
        TriggerCount = 0;
        PackageEnd = 1;
        TriggerCountHeader = 0;
        for i = 1:1:4
            TriggerCountHeader = TriggerCountHeader + InitialData(i + DataPoint)*4^(4-i);
        end
        DataPoint = DataPoint + 4;
        if(TriggerCountHeader == 204) %204 = 0xCC
            for i = 1:1:12
                TriggerCount = TriggerCount + InitialData(i + DataPoint)*4^(12-i);
            end
        else if(DataPoint > 96)
                DataPoint = DataPoint - 24;
            for i = 1:1:12
                TriggerCount = TriggerCount + InitialData(i + DataPoint)*4^(12 -i );            
            end
            else
                TriggerCount = 0;
            end
        end
        
    else
        TriggerCount = 0;
        PackageEnd = 0;
    end
end

