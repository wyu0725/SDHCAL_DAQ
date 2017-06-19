prompt = {'Input the hit number','Input the average number','DataNumber'};
DlgTitle = 'Input the acq parameter';
answer = inputdlg(prompt,DlgTitle);
HitNumber = str2double(answer(1));
AverageNumber = str2double(answer(2));
DataNumber = str2double(answer(3));
Charge = zeros(DataNumber,1);
AverageAdc = zeros(DataNumber,1);
StdAdc = zeros(DataNumber,1);
PromptCharge = 'Input Charge';
ChargeTitle = 'InputCharge and select file';
for i = 1:1:DataNumber
    ChargeAnswer = inputdlg(PromptCharge,ChargeTitle);
    Charge(i) = str2double(ChargeAnswer);
    [AverageAdc(i),StdAdc(i)] = CaculateAdc(HitNumber,AverageNumber);
end