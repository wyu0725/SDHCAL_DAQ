%
SlaveDaqData = Importdata();
DataLength = floor(length(SlaveDaqData) / 96) + 1;
HitData = zeros(64, 1);
HitNumber = 0;
DataPoint = 0;
for i=1:1:DataLength
    [TotalCount, CheckEnd] = CheckPackageEnd(SlaveDaqData, DataPoint);
    if(CheckEnd == 1)
        break;
    end
    if(i == 76)
        
    end
    [Header, BCID, ChannelData, ~, TriggerCount, DataPoint] = ReadSlaveDaqPackage(SlaveDaqData, DataPoint);
    if(Header ~= 161)
        break;
    end
    HitData = ChannelData + HitData;
    HitNumber = HitNumber + 1;
end
