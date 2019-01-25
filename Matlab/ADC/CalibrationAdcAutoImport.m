prompt = {'Input the average number','Start Charge', 'End Charge', 'Charge Step','ASIC ID'};
DlgTitle = 'Input the acq parameter';
answer = inputdlg(prompt,DlgTitle);
% HitNumber = str2double(answer(1));
AverageNumber = str2double(answer(1));
StartCharge = str2double(answer(2));
EndCharge = str2double(answer(3));
ChargeStep = str2double(answer(4));
% AsicID = str2double(answer(5));
AsicID = str2double(answer(5));
DataNumber = (EndCharge - StartCharge)/ChargeStep + 1;
Charge = StartCharge:ChargeStep:EndCharge;
AverageAdc = zeros(1,DataNumber);
StdAdc = zeros(1,DataNumber);
h = zeros(1,DataNumber);
DataFolder = uigetdir('*.*','ÇëÑ¡ÔñÎÄ¼þ¼Ð');
figure;
for i = 1:1:DataNumber
    
    [AverageAdc(i), StdAdc(i), h(i)] = CaculateAdcAutoImport(AverageNumber, 10,Charge(i),AsicID,DataFolder);
end
xlabel('\bf ADC Code');
ylabel('\bf Count');
title('\bf Histogram of different charge');
hold off;

figure;
plot(Charge,AverageAdc,'o-')
xlabel('\bf Charge(fC)');
ylabel('\bf ADC code');
title('\bf ADC code Vs. Charge');

AdcChannel = zeros(1,DataNumber);
for i = 1:1:DataNumber
    AdcChannel(i) = AverageAdc(1) - AverageAdc(i);
end
figure;
plot(Charge,AdcChannel,'o-')
xlabel('\bf Charge(fC)');
ylabel('\bf ADC code');
title('\bf ADC code Vs. Charge');


% figure;
% AdcVoltage = AverageAdc * 5 / 4095;
% plot(Charge,AdcVoltage,'o-');
% xlabel('\bf Charge(fC)');
% ylabel('\bf Voltage(V)');
% title('\bf Voltage Vs. Charge');
% ChargeLinear = Charge(1:9);
% AdcLinear = AverageAdc(1:9);
% 
% % Caculate Linear
% Charge1 = Charge(1:9);
% AdcVoltage1 = AdcVoltage(1:9);
% p1 = polyfit(Charge1,AdcVoltage1,1);
% x1 = linspace(min(Charge1),max(Charge1)+50);
% y1 = polyval(p1,x1);
% figure;
% plot(x1,y1);
% Charge2 = Charge(9:11);
% AdcVoltage2 = AdcVoltage(9:11);
% p2 = polyfit(Charge2,AdcVoltage2,1);
% x2 = linspace(min(Charge2)-50,max(Charge2));
% y2 = polyval(p2,x2);
% figure;
% plot(x2,y2);
% 
% ShaperOutput = AdcVoltage(1) - AdcVoltage;
% ShaperOutput1 = ShaperOutput(1:9);
% p3 = polyfit(Charge1,ShaperOutput1,1);
% y3 = polyval(p3,x1);
% figure;
% plot(x1,y3);
% hold on;
% plot(Charge1, ShaperOutput1,'o');
% 
% ShaperOutput2 = ShaperOutput(9:11);
% p4 = polyfit(Charge2,ShaperOutput2,1);
% y4 = polyval(p4,x2);
% figure;
% plot(x2,y4);
% hold on;
% plot(Charge2,ShaperOutput2,'o')