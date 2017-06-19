InitialData = ImportData();
prompt = {'Input the hit number','Input the average number','Input the charge'};
DlgTitle = 'Input the acq parameter';
answer = inputdlg(prompt,DlgTitle);
HitNumber = str2double(answer(1));
AverageNumber = str2double(answer(2));
Charge = str2double(answer(3));

AdcData = zeros(HitNumber,1);
for i = 1:1:HitNumber
    SumAdcData = 0;
    for j = 1:1:AverageNumber
        DataIndex = (i - 1)*AverageNumber + j;
        SumAdcData = SumAdcData + InitialData(DataIndex);
    end
    AdcData(i) = SumAdcData / AverageNumber;
end
AdcData = AdcData*5/4095;
[AdcCount,Adc] = hist(AdcData,10);
FAdc = AdcCount/sum(AdcCount);
Average = FAdc*Adc';
Std = sqrt(FAdc*((Adc-Average).*(Adc-Average))');