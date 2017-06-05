function [ DacCode, ChannelDataEqual1, ChannelDataEqual2, ChannelDataEqual3 ] = ReadSingleDac( InitialData, DacIndex, PackageNumber, HittedChannel)
%ReadSingleDac 此处显示有关此函数的摘要
%   此处显示详细说明
    ChannelDataEqual1 = zeros(64,1);
    ChannelDataEqual2 = zeros(64,1);
    ChannelDataEqual3 = zeros(64,1);
    DacCode = 0;
    for i = 1:1:8
        DacCode = DacCode + InitialData((DacIndex-1)*(8 + 80*PackageNumber) + 8 + i)*4^(8-i);
    end
    DacCode = DacCode - 53248;
    for i = 1:1:PackageNumber
        [Header,~,ReadData] = ReadPackage(InitialData, (i-1),(DacIndex-1)*(8 + 80*PackageNumber) + 8 + 8);
        if(Header ~= hex2dec('A1'))
            continue;
        end
        if (ReadData(HittedChannel) > 0)
            for k = 1:1:64
                if (ReadData(k) == 1)
                    ChannelDataEqual1(k) = ChannelDataEqual1(k) + 1;
                end
                if (ReadData(k) == 2)
                    ChannelDataEqual2(k) = ChannelDataEqual2(k) + 1;
                end
                if(ReadData(k) == 3)
                    ChannelDataEqual3(k) = ChannelDataEqual3(k) + 1;
                end
            end
        end        
    end
end

