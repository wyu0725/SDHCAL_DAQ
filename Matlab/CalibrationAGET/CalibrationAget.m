promptDataNumber = {'Input the start charge','Input the end charge', 'Input the charge interval'};
dlgDataNumber = 'Input data info';
answer = inputdlg(promptDataNumber,dlgDataNumber);
StartCharge = str2double(answer(1));
EndCharge = str2double(answer(2));
ChargeInterval = str2double(answer(3));
Charge = StartCharge:ChargeInterval:EndCharge;
DataNumber = (EndCharge - StartCharge)/ChargeInterval + 1;
CurrentPath = pwd;
Peak = zeros(DataNumber,1);
for i = 1:1:DataNumber
    % Read Data Back
    filename = sprintf('%s\\%dfC.dat',CurrentPath,i*ChargeInterval);
    [fid,~] = fopen(filename,'r');
    if fid <= 0
        % There was an error--tell user
        str = ['File ' filename ' could not be opened.'];
        dlg_title = 'File Open Faild';
        errordlg(str, dlg_title,'modal');
        break;
    else
        %File opend successfully
        InitialData = fread(fid,'uint16','ieee-be');%Big-endian ording
        %Size = length(importdata);
        fclose(fid);%close file
    end
    PackageNumber = floor(length(InitialData) / (64 * 520));
    for j = 1:1:PackageNumber
        [ Header, BoardNumber, TimeStamp, Channel, TrigID, DataOut, Tail ] = ReadSingleChannelData( InitialData, 64*(j - 1) + 50 );
        Peak(i) = Peak(i) + max(DataOut);
    end
    Peak(i) = Peak(i) / PackageNumber;
end
plot(Charge,Peak)
