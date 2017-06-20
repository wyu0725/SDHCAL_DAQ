InitialData = ImportData();
prompt = {'Input the average number','Input the charge'};
DlgTitle = 'Input the acq parameter';
answer = inputdlg(prompt,DlgTitle);

AverageNumber = str2double(answer(1));
Charge = str2double(answer(2));
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
% AdcData1 = 2.1465201465201465201465201465201 -  AdcData*5/4095;
AdcData1 = AdcData;
[AdcCount,Adc] = hist(AdcData1,10);
[xData,yData] = createFit(Adc,AdcCount);
x = linspace(min(Adc),max(Adc));
a1 = xData.a1;
b1 = xData.b1;
c1 = xData.c1;
y = a1*exp(-((x - b1)./c1).^2);
figure;
hist(AdcData1,2000);
AdcData2 = AdcData*5/4095;
AdcCharge = zeros(HitNumber,1);
for i = 1:1:HitNumber
    AdcCharge(i) = Voltage2Charge(AdcData2(i));
end
figure;
hist(AdcCharge,2000);
FAdc = AdcCount/sum(AdcCount);
Average = FAdc*Adc';
Std = sqrt(FAdc*((Adc-Average).*(Adc-Average))');