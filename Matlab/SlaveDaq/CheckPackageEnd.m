function [ TriggerCount, PackageEnd ] = CheckPackageEnd( InitialData, PackageNumber )
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
    StartNumber = (PackageNumber-1)*96;
    Tail = 0;
    for i=1:8
        Tail = Tail + InitialData(i + StartNumber)*4^(8-i);
    end
    if(Tail == 65349)
        TriggerCount = 0;
        PackageEnd = 1;
        if(PackageNumber ~= 1)
            for i = 85:1:96
                    TriggerCount = TriggerCount + InitialData(i + StartNumber - 96)*4^(12 + 84 -i );            
            end
        else
            TriggerCount = 0;
        end
    else
        TriggerCount = 0;
        PackageEnd = 0;
    end
end

