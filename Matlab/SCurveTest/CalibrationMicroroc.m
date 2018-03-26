%%% Calibration the ASIC
Channel = 1:1:64;
Channel(61) = [];
promptDataNumber = {'Input the start charge','Input the end charge', 'Input the charge interval', 'Input the DAC Range', 'Input Linear range(fC)'};
dlgDataNumber = 'Input data info';
answer = inputdlg(promptDataNumber,dlgDataNumber);
StartCharge = str2double(answer(1));
EndCharge = str2double(answer(2));
ChargeInterval = str2double(answer(3));
DacRange = str2double(answer(4));
LinearCharge = str2double(answer(5));
LinearRange = (LinearCharge - StartCharge)/ChargeInterval + 1;
Charge = StartCharge:ChargeInterval:EndCharge;
DataNumber = (EndCharge - StartCharge)/ChargeInterval + 1;
CurrentPath = pwd;
CalibrationDataDac0 = zeros(DataNumber, 64);
CalibrationDataDac1 = zeros(DataNumber, 64);
CalibrationDataDac2 = zeros(DataNumber, 64);
for i = 1:1:DataNumber
    % Read Data Back
    filename = sprintf('%s\\SCurveTest20180323\\AllChannel%dfC.dat',CurrentPath,(i-1)*ChargeInterval);
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
    for j = 0:1:63
        [CalibrationDataDac0(i, j+1), CalibrationDataDac1(i, j+1), CalibrationDataDac2(i, j+1)] = SingleChannelTrigEfficiency(InitialData, j, DacRange);
    end
end
%%% Linearfit and plot
% DAC0
pDac0 = zeros(64,2);
figure;
for i = 1:1:64
    ChannelData = CalibrationDataDac0(:,i);
    ChannelDataFit = ChannelData(1:LinearRange);
    ChargeFit = Charge(1:LinearRange);
    if(i == 61)
        continue;
    end
    [~,pDac0(i,:),x,y] = SelfLinearFit(ChargeFit, ChannelDataFit'); 
    plot(Charge,ChannelData,'*');
    hold on;
    plot(x,y);
    hold on;
end
 xlabel('\bf Charge')
ylabel('\bf DAC Code')
title('\bf 64通道高增益成形刻度曲线(DAC0)')
% text('String','DAC Code = p \times Charge + b','Position',[300 500],'HorizontalAlignment','center');
figure;
pDac0(61,:) = [];
plot(Channel,pDac0(:,1));
title('\bf 高增益成形增益和通道关系')
xlabel('Channel')
ylabel('Gain (DAC Unit/fC)')
legend('High Gain shaper')
figure;
plot(Channel,pDac0(:,2));
meanPDac0 = mean(pDac0(:,1));
maxPDac0 = max(pDac0(:,1));
UniformPDac0 = abs(maxPDac0 - meanPDac0) / meanPDac0;
devPDac0 = pDac0 - meanPDac0(:,1);
figure;
stairs(Channel, devPDac0(:,1));
axis([0 65,-0.1 0.1])
textDac0 = sprintf('$\\frac{\\vert Max(p) - Mean(p)\\vert}{Mean(p)}$ = %1.4f',UniformPDac0*100);
text('String',textDac0,'HorizontalAlignment','center','Position',[32 0.05],'Interpreter','latex');
xlabel('\bf Channel')
ylabel('\bf $\frac{\vert Max(p) - Mean(p)\vert}{Mean(p)}$','Interpreter','latex')
title('\bf 通道间增益不均匀性')
hold on
ax = [0 65];
ay = [0 0];
plot(ax,ay,'r')
hold off;
% DAC1
pDac1 = zeros(64,2);
figure;
for i = 1:1:64
    ChannelData = CalibrationDataDac1(:,i);
    ChannelDataFit = ChannelData(1:LinearRange);
    ChargeFit = Charge(1:LinearRange);
    if(i == 61)
        continue;
    end
    [~,pDac1(i,:),x,y] = SelfLinearFit(ChargeFit, ChannelDataFit'); 
    plot(Charge,ChannelData,'*');
    hold on;
    plot(x,y);
    hold on;
end
 xlabel('\bf Charge')
ylabel('\bf DAC Code')
title('\bf 高增益成形刻度曲线DAC1')
% DAC2
figure;
for i = 1:1:64
    ChannelData = CalibrationDataDac2(:,i);
    if(i == 61)
        continue;
    end
    plot(Charge,ChannelData);
    hold on;
end