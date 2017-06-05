%%%
% 从扫阈读回的数据中分析串扰

InitialData = ImportData();
prompt = {'Start DAC', 'End DAC', 'Package Number', 'Hitted Channel'};
DlgTitle = 'Input the Sweep Parameter';
answer = inputdlg(prompt, DlgTitle);
StartDac = str2double(answer(1));
EndDac = str2double(answer(2));
PackageNumber = str2double(answer(3));
HittedChannel = str2double(answer(4));
DacRange = EndDac - StartDac + 1;
DacCode = zeros(DacRange, 1);
ChannelDataEQ1 = zeros(64,DacRange);
ChannelDataEQ2 = zeros(64,DacRange);
ChannelDataEQ3 = zeros(64,DacRange);
for i = 1:1:DacRange
    [DacCode, ChannelDataEQ1(:,i), ChannelDataEQ2(:,i), ChannelDataEQ3(:,i)] = ReadSingleDac(InitialData, i, PackageNumber,HittedChannel);
end