% Compare 64 channel S Curve: with or without correction
ImportData_woHV = Importdata();
ImportData_wiHV = Importdata();
DAC0_50Percent_woHV = zeros(1,64);
DAC1_50Percent_woHV = zeros(1,64);
DAC2_50Percent_woHV = zeros(1,64);
DAC0_50Percent_wiHV = zeros(1,64);
DAC1_50Percent_wiHV = zeros(1,64);
DAC2_50Percent_wiHV = zeros(1,64);


for i = 0:1:63
    [DAC0_50Percent_woHV(i+1), DAC1_50Percent_woHV(i+1), DAC2_50Percent_woHV(i+1)] = SCurvePlotSingleChannel(ImportData_woHV, i ,0);
    [DAC0_50Percent_wiHV(i+1), DAC1_50Percent_wiHV(i+1), DAC2_50Percent_wiHV(i+1)] = SCurvePlotSingleChannel(ImportData_wiHV, i ,3);
end
for i = 1:1:6    
    figure(i)
    xlabel('\bfDAC Code')
    ylabel('\bfTrigger efficiency (%)')
    hold off
end
figure(1)
title('\bf TRIG0: S Curve 0fC,without HV')
figure(2)
title('\bf TRIG1: S Curve 0fC,without HV')
figure(3)
title('\bf TRIG2: S Curve 0fC,without HV')
figure(4)
title('\bf TRIG0: S Curve 0fC,with HV')
figure(5)
title('\bf TRIG1: S Curve 0fC,with HV')
figure(6)
title('\bf TRIG2: S Curve 0fC,with HV')

Channel = 1:1:64;
Channel(61) = [];
DAC0_50Percent_woHV(61) = [];
DAC0_50Percent_wiHV(61) = [];
max_DAC0_woHV = max(DAC0_50Percent_woHV);
min_DAC0_woHV = min(DAC0_50Percent_woHV);
std_DAC0_woHV = std(DAC0_50Percent_woHV);
max_DAC0_wiHV = max(DAC0_50Percent_wiHV);
min_DAC0_wiHV = min(DAC0_50Percent_wiHV);
std_DAC0_wiHV = std(DAC0_50Percent_wiHV);

figure(10)
plot(Channel,DAC0_50Percent_woHV,'k*-')
hold on;
plot(Channel,DAC0_50Percent_wiHV,'r*-')
hold off;
legend_str0 = sprintf('Without HV Max:%d, Min:%d,Std:%1.4f',max_DAC0_woHV,min_DAC0_woHV,std_DAC0_woHV);
legend_str1 = sprintf('With HV Max:%d, Min:%d,Std:%1.4f',max_DAC0_wiHV,min_DAC0_wiHV,std_DAC0_wiHV);
h = legend(legend_str0, legend_str1);
y_axs1 = min([min(DAC0_50Percent_woHV),min(DAC0_50Percent_wiHV)]) - 1;
y_axs2 = max([max(DAC0_50Percent_woHV),max(DAC0_50Percent_wiHV)]) + 3;


