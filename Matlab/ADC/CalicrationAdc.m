prompt = {'Input the average number','DataNumber'};
DlgTitle = 'Input the acq parameter';
answer = inputdlg(prompt,DlgTitle);
% HitNumber = str2double(answer(1));
AverageNumber = str2double(answer(1));
DataNumber = str2double(answer(2));
Charge = zeros(DataNumber,1);
AverageAdc = zeros(DataNumber,1);
StdAdc = zeros(DataNumber,1);
PromptCharge = 'Input Charge';
ChargeTitle = 'InputCharge and select file';
for i = 1:1:DataNumber
    ChargeAnswer = inputdlg(PromptCharge,ChargeTitle);
    Charge(i) = str2double(ChargeAnswer);
    [AverageAdc(i),StdAdc(i)] = CaculateAdc(AverageNumber, 10);
end
figure;
plot(Charge,AverageAdc,'o-')
AdcVoltage = AverageAdc * 5 / 4095;
figure;
plot(Charge,AdcVoltage,'o-')
ChargeLinear = Charge(1:9);
AdcLinear = AverageAdc(1:9);

% Caculate Linear
Charge1 = Charge(1:9);
AdcVoltage1 = AdcVoltage(1:9);
p1 = polyfit(Charge1,AdcVoltage1,1);
x1 = linspace(min(Charge1),max(Charge1)+50);
y1 = polyval(p1,x1);
figure;
plot(x1,y1);
Charge2 = Charge(9:11);
AdcVoltage2 = AdcVoltage(9:11);
p2 = polyfit(Charge2,AdcVoltage2,1);
x2 = linspace(min(Charge2)-50,max(Charge2));
y2 = polyval(p2,x2);
figure;
plot(x2,y2);

ShaperOutput = AdcVoltage(1) - AdcVoltage;
ShaperOutput1 = ShaperOutput(1:9);
p3 = polyfit(Charge1,ShaperOutput1,1);
y3 = polyval(p3,x1);
figure;
plot(x1,y3);
hold on;
plot(Charge1, ShaperOutput1,'o');

ShaperOutput2 = ShaperOutput(9:11);
p4 = polyfit(Charge2,ShaperOutput2,1);
y4 = polyval(p4,x2);
figure;
plot(x2,y4);
hold on;
plot(Charge2,ShaperOutput2,'o')