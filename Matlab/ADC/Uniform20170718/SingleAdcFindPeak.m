AverageNumber = 32;
[InitialData, FileName ]= ImportData();
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
% AdcData = (1.758137790851369e+03 - AdcData)*5/4095;
a1 = min(AdcData);
a2 = max(AdcData);
N = round(a2 - a1) + 1;
AdcData = 2.145996 -  AdcData*5/4096;
[AdcCount,Adc] = hist(AdcData,N);
[~, Peak] = FindSpectraPeaks(Adc, AdcCount,0);
Charge = Voltage2Charge(Peak);
figure;
hist(AdcData,N);
title(FileName);
TextString = sprintf('Peak:%1.4f V -> %3.2f fC',Peak,Charge);
text('Position',[0.1 700],'String',TextString);
