InitialData = Importdata();
prompt = {'StartDac','EndDac'};
dlg = 'Input data info';
answer = inputdlg(prompt,dlg);
StartDac = str2double(answer(1));
EndDac = str2double(answer(2));
PackageNumber = EndDac - StartDac + 1;
TestHeader = InitialData(1);
Channel = InitialData(2);
if(bitand(Channel, 65280) == 25344)
    PackageGood = 1;
else
    PackageGood = 0;
end

ChannelGood = zeros(64, 1);
ChannelGood(1) = PackageGood;
for i = 2:1:64
    Channel = InitialData(2 + (i-1)*(PackageNumber * 7 + 1));
    if(bitand(Channel, 65280) == 25344)
        PackageGood = 1;
    else
        PackageGood = 0;
    end
    ChannelGood(i) = PackageGood;
end