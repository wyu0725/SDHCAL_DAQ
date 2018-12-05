InitialData= ImportData();
% prompt = {'Input the average number'};
%  DlgTitle = 'Input the acq parameter';
% answer = inputdlg(prompt,DlgTitle);
% 
% AverageNumber = str2double(answer(1));
AverageNumber = 32;
% Charge = str2double(answer(2));
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
figure;
histogram(AdcData);
% figure(12);
% hold on;
% histogram(AdcData);
% % AdcData = (1.758137790851369e+03 - AdcData)*5/4095;
% a1 = min(AdcData);
% a2 = max(AdcData);
% N = round(a2 - a1) + 1;
% AdcData = 2.145996 -  AdcData*5/4096;
% [AdcCount,Adc] = hist(AdcData,N);
% figure;
% hist(AdcData,N);
% title(FileName);
% FAdc = AdcCount/sum(AdcCount);
% Average = FAdc*Adc';
% Std = sqrt(FAdc*((Adc-Average).*(Adc-Average))');
