function [ Average,Std ] = CaculateAdc(AverageNumber, HistNumber)
%CaculateAdc AverageNumber是多少个点将ADC的数据平均一次 HistNumber是为调用hist
%   此处显示详细说明
    InitialData = ImportData();
    HitNumber = floor(length(InitialData)/AverageNumber);
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
    h = histogram(AdcData,10);
    hold on;
    FAdc = AdcCount/sum(AdcCount);
    Average = FAdc*Adc';
    Std = sqrt(FAdc*((Adc-Average).*(Adc-Average))');


end

