%% Calibration the ASIC
Channel = 1:1:64;
promptDataNumber = {'Input the start charge','Input the end charge', 'Input the charge interval'};
dlgDataNumber = 'Input data info';
answer = inputdlg(promptDataNumber,dlgDataNumber);
StartCharge = str2double(answer(1));
EndCharge = str2double(answer(2));
ChargeInterval = str2double(answer(3));
DataNumber = (EndCharge - StartCharge)/ChargeInterval + 1;
CurrentPath = pwd;
for i = 1:1:DataNumber
    
end