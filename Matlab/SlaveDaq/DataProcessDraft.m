%
SlaveDaqData = Importdata();
DataLength = floor(length(SlaveDaqData) / 96) + 1;
HitData = zeros(64, 1);
HitNumber = 0;
for i=1:1:DataLength
    [TotalCount, CheckEnd] = CheckPackageEnd(SlaveDaqData, i);
    if(CheckEnd == 1)
        break;
    end
    [Header, BCID, ChannelData, ~, TriggerCount] = ReadSlaveDaqPackage(SlaveDaqData, i);
    if(Header ~= 161)
        break;
    end
    HitData = ChannelData + HitData;
    HitNumber = HitNumber + 1;
end
