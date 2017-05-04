ImportData1 = Importdata();
prompt = 'Which channel you want to display';
answer = inputdlg(prompt);
ChannelNumber = str2double(answer);
[~, DacCode, P0, T0, P1, T1, P2, T2] = ReadData(ImportData1, 2 + (ChannelNumber-1)*7169);

TrigRatio0 = (T0./P0).*100 ;
TrigRatio1 = (T1./P1).*100;
TrigRatio2 = (T2./P2).*100;
for i = 1:1:1023
    if(TrigRatio0(i) > TrigRatio0(i+1))
        TrigRatio0(i) = TrigRatio0(i+1);
    end
    if(TrigRatio1(i) > TrigRatio1(i+1))
        TrigRatio1(i) = TrigRatio1(i+1);
    end
    if(TrigRatio2(i) > TrigRatio2(i+1))
        TrigRatio2(i) = TrigRatio2(i+1);
    end
end
[~, DacPercent0, ~] = FindStartMidEnd(TrigRatio0, 50);
[~, DacPercent1, ~] = FindStartMidEnd(TrigRatio1, 50);
[~, DacPercent2, ~] = FindStartMidEnd(TrigRatio2, 50);

DiffTrigRatio0 = diff(TrigRatio0)/100;
DiffTrigRatio1 = diff(TrigRatio1)/100;
DiffTrigRatio2 = diff(TrigRatio2)/100;

DacCodeDiff = 0.5:1:1022.5;
MeanDac0 = DacCodeDiff*DiffTrigRatio0';
VarDac0 = ((DacCodeDiff - MeanDac0).*(DacCodeDiff - MeanDac0))*DiffTrigRatio0';
StdDac0 = sqrt(VarDac0);
MeanDac1 = DacCodeDiff*DiffTrigRatio1';
VarDac1 = ((DacCodeDiff - MeanDac1).*(DacCodeDiff - MeanDac1))*DiffTrigRatio1';
StdDac1 = sqrt(VarDac1);
MeanDac2 = DacCodeDiff*DiffTrigRatio2';
VarDac2 = ((DacCodeDiff - MeanDac2).*(DacCodeDiff - MeanDac2))*DiffTrigRatio2';
StdDac2 = sqrt(VarDac2);
figure;
plot(DacCodeDiff,DiffTrigRatio0);
LegendStr0 = sprintf('Mean:%3.4f,Std:%2.4f',MeanDac0,StdDac0);
legend(LegendStr0);
title('DAC0')
figure;
plot(DacCodeDiff,DiffTrigRatio1);
LegendStr1 = sprintf('Mean:%3.4f,Std:%2.4f',MeanDac1,StdDac1);
legend(LegendStr1);
title('DAC1')
figure;
plot(DacCodeDiff,DiffTrigRatio2);
LegendStr2 = sprintf('Mean:%3.4f,Std:%2.4f',MeanDac2,StdDac2);
legend(LegendStr2);
title('DAC2')

figure;
plot(DacCode,TrigRatio0,'.-');
LegendStr0 = sprintf('DAC0, Channel:%d',ChannelNumber);
% legend(LegendStr0)
hold on;
% figure;
plot(DacCode,TrigRatio1,'.-');
LegendStr1 = sprintf('DAC1, Channel:%d',ChannelNumber);
% legend(LegendStr1)
hold on
% figure;
plot(DacCode,TrigRatio2,'.-');
LegendStr2 = sprintf('DAC2, Channel:%d',ChannelNumber);
legend(LegendStr0,LegendStr1,LegendStr2);
hold off

