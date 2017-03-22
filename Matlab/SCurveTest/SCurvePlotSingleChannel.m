function [DAC_Percent0, DAC_Percent1, DAC_Percent2 ] = SCurvePlotSingleChannel( ImportData, Channel_Number, fig_num)
% fig_num = 3;
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
[~, DAC_Code, P0, T0, P1, T1, P2, T2] = ReadData(ImportData, 2 + Channel_Number*7169);
Trig_Ratio0 = (T0./P0).*100 ;
Trig_Ratio1 = (T1./P1).*100;
Trig_Ratio2 = (T2./P2).*100;
% DAC_Percent0 = trig_efficiency(DAC_Code,Trig_Ratio0,Percent);
% DAC_Percent1 = trig_efficiency(DAC_Code,Trig_Ratio1,Percent);
% DAC_Percent2 = trig_efficiency(DAC_Code,Trig_Ratio2,Percent);
[~, DAC_Percent0, ~] = FindStartMidEnd(Trig_Ratio0, 50);
[~, DAC_Percent1, ~] = FindStartMidEnd(Trig_Ratio1, 50);
[~, DAC_Percent2, ~] = FindStartMidEnd(Trig_Ratio2, 50);
% Trig0_DAC = trig_efficiency( DAC_Code,Trig_Ratio0,50);
% Trig1_DAC = trig_efficiency( DAC_Code,Trig_Ratio1,50);
% Trig2_DAC = trig_efficiency( DAC_Code,Trig_Ratio2,50);
% Trig0_str = sprintf('Channle%d,trig0 50 percent trigger efficiency = %d',Channel,round(Trig0_DAC));
% Trig1_str = sprintf('Channle%d,trig1 50 percent trigger efficiency = %d',Channel,round(Trig1_DAC));
% Trig2_str = sprintf('Channle%d,trig2 50 percent trigger efficiency = %d',Channel,round(Trig2_DAC));
% Trig0_str = sprintf('Channle%d,trig0 50 percent trigger efficiency = %d',Channel,round(Trig0_DAC));
% Trig1_str = sprintf('Channle%d,trig1 50 percent trigger efficiency = %d',Channel,round(Trig1_DAC));
% Trig2_str = sprintf('Channle%d,trig2 50 percent trigger efficiency = %d',Channel,round(Trig2_DAC));
% figure_number0 = 1 + 3*(Channel_Number-1);
% figure_number1 = 2 + 3*(Channel_Number-1);
% figure_number2 = 3 + 3*(Channel_Number-1);
figure(1 + fig_num)
plot(DAC_Code, Trig_Ratio0);
% h0 = legend(Trig0_str);
% set(h0,'Location','northwest');
hold on;
figure(2 + fig_num)
plot(DAC_Code, Trig_Ratio1);
% h1 = legend(Trig1_str);
% set(h1,'Location','northwest');
hold on;
figure(3 + fig_num)
plot(DAC_Code, Trig_Ratio2);
% h2 = legend(Trig2_str);
% set(h2,'Location','northwest');
hold on;

end

