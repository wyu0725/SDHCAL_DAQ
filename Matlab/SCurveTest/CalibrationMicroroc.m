%%% Calibration the ASIC
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
    % Read Data Back
    filename = sprintf('%s\\64_Chn_%dfC_CTest_DC.dat',CurrentPath,(i-1)*20);
    [fid,~] = fopen(filename,'r');
    if fid <= 0
        % There was an error--tell user
        str = ['File ' filename ' could not be opened.'];
        dlg_title = 'File Open Faild';
        errordlg(str, dlg_title,'modal');
    else
        %File opend successfully
        InitialData = fread(fid,'uint16','ieee-be');%Big-endian ording
        %Size = length(importdata);
        fclose(fid);%close file
    end
    for j = 0:1:63
        [DAC0_50Percent(j+1), DAC1_50Percent(j+1), DAC2_50Percent(j+1)] = SingleChannelTrigEfficiency(ImportData, j);
    end
end