InitialData = ImportData();
    HitNumber = floor(length(InitialData)/32);
    InitialData = 3.467594943922547e+03-InitialData;
    AdcData = zeros(HitNumber,1);
    for i = 1:1:HitNumber
        SumAdcData = 0;
        for j = 1:1:AverageNumber
            DataIndex = (i - 1)*AverageNumber + j;
            SumAdcData = SumAdcData + InitialData(DataIndex);
        end
        AdcData(i) = SumAdcData / AverageNumber;
    end
    
    [AdcCount,Adc] = hist(AdcData,HistNumber);
    figure;
    h = histogram(AdcData,300);