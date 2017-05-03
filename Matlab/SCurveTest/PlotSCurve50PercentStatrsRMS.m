% Compare 64 channel S Curve: with or without correction
ImportData_woCorrection = Importdata();
ImportData_wiCorrection_DC = Importdata();
DAC0_50Percent_woCorrect = zeros(1,64);
DAC1_50Percent_woCorrect = zeros(1,64);
DAC2_50Percent_woCorrect = zeros(1,64);
DAC0_50Percent_wiCorrect_DC = zeros(1,64);
DAC1_50Percent_wiCorrect_DC = zeros(1,64);
DAC2_50Percent_wiCorrect_DC = zeros(1,64);
DiffDAC0_woCorrection = zeros(1023,64);
DiffDAC1_woCorrection = zeros(1023,64);
DiffDAC2_woCorrection = zeros(1023,64);
DiffDAC0_wiCorrection_DC = zeros(1023,64);
DiffDAC1_wiCorrection_DC = zeros(1023,64);
DiffDAC2_wiCorrection_DC = zeros(1023,64);
Dac0StdWoCorrection = zeros(1,64);
Dac1StdWoCorrection = zeros(1,64);
Dac2StdWoCorrection = zeros(1,64);
Dac0StdWiCorrection = zeros(1,64);
Dac1StdWiCorrection = zeros(1,64);
Dac2StdWiCorrection = zeros(1,64);
for i = 0:1:63
    [DAC0_50Percent_woCorrect(i+1), DAC1_50Percent_woCorrect(i+1), DAC2_50Percent_woCorrect(i+1)] = SCurvePlotSingleChannel(ImportData_woCorrection, i ,0);
    [DiffDAC0_woCorrection(:,i+1),DiffDAC1_woCorrection(:,i+1),DiffDAC2_woCorrection(:,i+1)] = DiffSCurve(ImportData_woCorrection,i);
    [Dac0StdWoCorrection(i+1), Dac1StdWoCorrection(i+1), Dac2StdWoCorrection(i+1)] = CaculateStd(ImportData_woCorrection,i);
    [DAC0_50Percent_wiCorrect_DC(i+1), DAC1_50Percent_wiCorrect_DC(i+1), DAC2_50Percent_wiCorrect_DC(i+1)] = SCurvePlotSingleChannel(ImportData_wiCorrection_DC, i ,3);
    [DiffDAC0_wiCorrection_DC(:,i+1),DiffDAC1_wiCorrection_DC(:,i+1),DiffDAC2_wiCorrection_DC(:,i+1)] = DiffSCurve(ImportData_wiCorrection_DC,i);
    [Dac0StdWiCorrection(i+1), Dac1StdWiCorrection(i+1), Dac2StdWiCorrection(i+1)] = CaculateStd(ImportData_wiCorrection_DC,i);
end
for i = 1:1:6    
    figure(i)
    xlabel('\bfDAC Code')
    ylabel('\bfTrigger efficiency (%)')
    hold off
end
figure(1)
title('\bf TRIG0: S Curve 0fC,without 4-bit DAC Correction')
figure(2)
title('\bf TRIG1: S Curve 0fC,without 4-bit DAC Correction')
figure(3)
title('\bf TRIG2: S Curve 0fC,without 4-bit DAC Correction')
figure(4)
title('\bf TRIG0: S Curve 0fC,with 4-bit DAC DC Correction')
figure(5)
title('\bf TRIG1: S Curve 0fC,with 4-bit DAC DC Correction')
figure(6)
title('\bf TRIG2: S Curve 0fC,with 4-bit DAC DC Correction')


Channel = 1:1:64;
Channel(61) = [];
figure
DAC0_50Percent_woCorrect(61) = [];
DAC0_50Percent_wiCorrect_DC(61) = [];
max_DAC0_woCorrect = max(DAC0_50Percent_woCorrect);
min_DAC0_woCorrect = min(DAC0_50Percent_woCorrect);
std_DAC0_woCorrect = std(DAC0_50Percent_woCorrect);
max_DAC0_wiCorrect_DC = max(DAC0_50Percent_wiCorrect_DC);
min_DAC0_wiCorrect_DC = min(DAC0_50Percent_wiCorrect_DC);
std_DAC0_wiCorrect_DC = std(DAC0_50Percent_wiCorrect_DC);
stairs(Channel,DAC0_50Percent_woCorrect,'k-')
hold on;
stairs(Channel,DAC0_50Percent_wiCorrect_DC,'r-')
hold off;
legend_str0 = sprintf('Without HV Max:%3d, Min:%d,Std:%1.4f',max_DAC0_woCorrect,min_DAC0_woCorrect,std_DAC0_woCorrect);
legend_str1 = sprintf('With HV Max:%d3, Min:%d,Std:%1.4f',max_DAC0_wiCorrect_DC,min_DAC0_wiCorrect_DC,std_DAC0_wiCorrect_DC);
h = legend(legend_str0, legend_str1);
y_axs1 = min([min(DAC0_50Percent_woCorrect),min(DAC0_50Percent_wiCorrect_DC)]) - 1;
y_axs2 = max([max(DAC0_50Percent_woCorrect),max(DAC0_50Percent_wiCorrect_DC)]) + 3;
axis([0 64,y_axs1 y_axs2])
set(h,'Location', 'north');
xlabel('\bf Chanel')
ylabel('\bf 50 percent trig rate')
title('\bf DAC0:Comparison of 50 percent trigger efficiency')

figure;
DAC1_50Percent_woCorrect(61) = [];
DAC1_50Percent_wiCorrect_DC(61) = [];
max_DAC1_woCorrect = max(DAC1_50Percent_woCorrect);
min_DAC1_woCorrect = min(DAC1_50Percent_woCorrect);
std_DAC1_woCorrect = std(DAC1_50Percent_woCorrect);
max_DAC1_wiCorrect_DC = max(DAC1_50Percent_wiCorrect_DC);
min_DAC1_wiCorrect_DC = min(DAC1_50Percent_wiCorrect_DC);
std_DAC1_wiCorrect_DC = std(DAC1_50Percent_wiCorrect_DC);
stairs(Channel, DAC1_50Percent_woCorrect,'k-');
hold on;
stairs(Channel, DAC1_50Percent_wiCorrect_DC,'r-');
hold off;
legend1_str0 = sprintf('Without HV Max:%3d, Min:%d,Std:%1.4f',max_DAC1_woCorrect,min_DAC1_woCorrect,std_DAC1_woCorrect);
legend1_str1 = sprintf('With HV Max:%3d, Min:%d,Std:%1.4f',max_DAC1_wiCorrect_DC,min_DAC1_wiCorrect_DC,std_DAC1_wiCorrect_DC);
h = legend(legend1_str0, legend1_str1);
y_axs1 = min([min(DAC1_50Percent_woCorrect),min(DAC1_50Percent_wiCorrect_DC)]) - 1;
y_axs2 = max([max(DAC1_50Percent_woCorrect),max(DAC1_50Percent_wiCorrect_DC)]) + 3;
axis([0 64,y_axs1 y_axs2])
set(h,'Location', 'north');
xlabel('\bf Chanel')
ylabel('\bf 50 percent trig rate')
title('\bf DAC1 Comparison of 50 percent trigger efficiency')

figure;
DAC2_50Percent_woCorrect(61) = [];
DAC2_50Percent_wiCorrect_DC(61) = [];
max_DAC2_woCorrect = max(DAC2_50Percent_woCorrect);
min_DAC2_woCorrect = min(DAC2_50Percent_woCorrect);
std_DAC2_woCorrect = std(DAC2_50Percent_woCorrect);
max_DAC2_wiCorrect_DC = max(DAC2_50Percent_wiCorrect_DC);
min_DAC2_wiCorrect_DC = min(DAC2_50Percent_wiCorrect_DC);
std_DAC2_wiCorrect_DC = std(DAC2_50Percent_wiCorrect_DC);
stairs(Channel, DAC2_50Percent_woCorrect,'k-');
hold on;
stairs(Channel, DAC2_50Percent_wiCorrect_DC,'r-');
hold off;
legend2_str0 = sprintf('Without HV Max:%3.2d, Min:%d,Std:%1.4f',max_DAC2_woCorrect,min_DAC2_woCorrect,std_DAC2_woCorrect);
legend2_str1 = sprintf('With HV Max:%3.2d, Min:%d,Std:%1.4f',max_DAC2_wiCorrect_DC,min_DAC2_wiCorrect_DC,std_DAC2_wiCorrect_DC);
h = legend(legend2_str0, legend2_str1);
y_axs1 = min([min(DAC2_50Percent_woCorrect),min(DAC2_50Percent_wiCorrect_DC)]) - 1;
y_axs2 = max([max(DAC2_50Percent_woCorrect),max(DAC2_50Percent_wiCorrect_DC)]) + 3;
axis([0 64,y_axs1 y_axs2])
set(h,'Location', 'north');
xlabel('\bf Chanel')
ylabel('\bf 50 percent trig rate')
title('\bf DAC2 Comparison of 50 percent trigger efficiency');

% Caculate the RMS
% GaussFit
% gaussEqn = 'a*exp(-((x-b)/c)^2)+d';
% DacCode = 1:1023;
% DAC0ChnDiff = DiffDAC0_woCorrection(:,1);
% f1 = fit(DacCode', DAC0ChnDiff,gaussEqn);
% MeanDac0 = DacCode*DAC0ChnDiff/100;
% NewDac0 = (DacCode - MeanDac0).*(DacCode - MeanDac0);
% VarDac0 = NewDac0*DAC0ChnDiff/100;
% StdDac0 = sqrt(VarDac0);
% % figure;
ChannelNumber = 1:64;
ChannelNumber(61) = [];
Dac0StdWoCorrection(61) = [];
Dac0StdWiCorrection(61) = [];
figure
plot(ChannelNumber,Dac0StdWoCorrection);
hold on;
plot(ChannelNumber,Dac0StdWiCorrection);
hold off;
xlabel('Channel');
ylabel('Std of differential-SCurve (DAC Code)');
legend('Without HV','With HV');
title('\bf RMS of DAC0 (0fC)');

Dac1StdWoCorrection(61) = [];
Dac1StdWiCorrection(61) = [];
figure
plot(ChannelNumber,Dac1StdWoCorrection);
hold on;
plot(ChannelNumber,Dac1StdWiCorrection);
hold off;
xlabel('Channel');
ylabel('Std of differential-SCurve (DAC Code)');
legend('Without HV','With HV');
title('\bf RMS of DAC1 (0fC)');

Dac2StdWoCorrection(61) = [];
Dac2StdWiCorrection(61) = [];
figure
plot(ChannelNumber,Dac2StdWoCorrection);
hold on;
plot(ChannelNumber,Dac2StdWiCorrection);
hold off;
xlabel('Channel');
ylabel('Std of differential-SCurve (DAC Code)');
legend('Without HV','With HV');
title('\bf RMS of DAC2 (0fC)');