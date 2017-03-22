% Compare 64 channel S Curve: with or without correction
ImportData_woCorrection = Importdata();
ImportData_wiCorrection_DC = Importdata();
ImportData_wiCorrection_SCT = Importdata();
DAC0_50Percent_woCorrect = zeros(1,64);
DAC1_50Percent_woCorrect = zeros(1,64);
DAC2_50Percent_woCorrect = zeros(1,64);
DAC0_50Percent_wiCorrect_DC = zeros(1,64);
DAC1_50Percent_wiCorrect_DC = zeros(1,64);
DAC2_50Percent_wiCorrect_DC = zeros(1,64);
DAC0_50Percent_wiCorrect_SCT = zeros(1,64);
DAC1_50Percent_wiCorrect_SCT = zeros(1,64);
DAC2_50Percent_wiCorrect_SCT = zeros(1,64);

for i = 0:1:63
    [DAC0_50Percent_woCorrect(i+1), DAC1_50Percent_woCorrect(i+1), DAC2_50Percent_woCorrect(i+1)] = SCurvePlotSingleChannel(ImportData_woCorrection, i ,0);
    [DAC0_50Percent_wiCorrect_DC(i+1), DAC1_50Percent_wiCorrect_DC(i+1), DAC2_50Percent_wiCorrect_DC(i+1)] = SCurvePlotSingleChannel(ImportData_wiCorrection_DC, i ,3);
    [DAC0_50Percent_wiCorrect_SCT(i+1), DAC1_50Percent_wiCorrect_SCT(i+1), DAC2_50Percent_wiCorrect_SCT(i+1)] = SCurvePlotSingleChannel(ImportData_wiCorrection_SCT, i ,6);
end         
% figure(1)
% axis([590 600,0 110])
% figure(4)
% axis([590 600,0 110])
Channel = 1:1:64;
Channel(61) = [];
DAC0_50Percent_woCorrect(61) = [];
DAC0_50Percent_wiCorrect_DC(61) = [];
DAC0_50Percent_wiCorrect_SCT(61) = [];
max_DAC0_woCorrect = max(DAC0_50Percent_woCorrect);
min_DAC0_woCorrect = min(DAC0_50Percent_woCorrect);
std_DAC0_woCorrect = std(DAC0_50Percent_woCorrect);
max_DAC0_wiCorrect_DC = max(DAC0_50Percent_wiCorrect_DC);
min_DAC0_wiCorrect_DC = min(DAC0_50Percent_wiCorrect_DC);
std_DAC0_wiCorrect_DC = std(DAC0_50Percent_wiCorrect_DC);
max_DAC0_wiCorrect_SCT = max(DAC0_50Percent_wiCorrect_SCT);
min_DAC0_wiCorrect_SCT = min(DAC0_50Percent_wiCorrect_SCT);
std_DAC0_wiCorrect_SCT = std(DAC0_50Percent_wiCorrect_SCT);
Min_woCorrect = min(DAC0_50Percent_woCorrect);
CorrectVoltage = (DAC0_50Percent_woCorrect - Min_woCorrect)*2.157;%mV
CorrectNumber = round(CorrectVoltage/0.725);
figure(10)
plot(Channel,DAC0_50Percent_woCorrect,'k*-')
hold on;
plot(Channel,DAC0_50Percent_wiCorrect_DC,'r*-')
hold on;
plot(Channel,DAC0_50Percent_wiCorrect_SCT,'b*-')
hold off;
legend_str0 = sprintf('50 Percent Trig rate DAC Code without correction\n Max:%d, Min:%d,Std:%1.4f',max_DAC0_woCorrect,min_DAC0_woCorrect,std_DAC0_woCorrect);
legend_str1 = sprintf('50 Peercent Trig rate DAC Code with DC correction\n Max:%d, Min:%d,Std:%1.4f',max_DAC0_wiCorrect_DC,min_DAC0_wiCorrect_DC,std_DAC0_wiCorrect_DC);
legend_str2 = sprintf('50 Percent Trig rate DAC Code with SCurve Test correction\n Max:%d, Min:%d,Std:%1.4f',max_DAC0_wiCorrect_SCT,min_DAC0_wiCorrect_SCT,std_DAC0_wiCorrect_SCT);
h = legend(legend_str0, legend_str1,legend_str2);
set(h,'Location', 'northout');