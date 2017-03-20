%% SCurve Plot
function SCurvePlot
InitialData = Importdata();
%Test_Header = InitialData(1);
%[Test_Channel, DAC_Code, P0, T0, P1, T1, P2, T2] = ReadData(InitialData, 2);
[~, DAC_Code, P0, T0, P1, T1, P2, T2] = ReadData(InitialData, 2);
%DAC_Code1 = 1:1:1024;
Trig_Ratio0 = (T0./P0).*100 ;
Trig_Ratio1 = (T1./P1).*100;
Trig_Ratio2 = (T2./P2).*100;
% [Start0, Middle0, End0] = FindStartMidEnd(Trig_Ratio0, 1024);
% [Start1, Middle1, End1] = FindStartMidEnd(Trig_Ratio1, 1024);
% [Start2, Middle2, End2] = FindStartMidEnd(Trig_Ratio2, 1024);
% x0_S = Start0 - 10;
% x0_E = End0 + 10;
% x1_S = Start0 - 10;
% x1_E = End0 + 10;
% x2_S = Start2 - 10;
% x2_E = End2 + 10;
% Legend_Trig0 = sprintf('Trigger0:Trigger Rate vs DAC Code\n Middle of trigger rate is :%f', Middle0);
% Legend_Trig1 = sprintf('Trigger1:Trigger Rate vs DAC Code\n Middle of trigger rate is :%f', Middle1);
% Legend_Trig2 = sprintf('Trigger2:Trigger Rate vs DAC Code\n Middle of trigger rate is :%f', Middle2);
 Trig0_DAC = trig_efficiency( DAC_Code,Trig_Ratio0,50);
 Trig1_DAC = trig_efficiency( DAC_Code,Trig_Ratio1,50);
 Trig2_DAC = trig_efficiency( DAC_Code,Trig_Ratio2,50);
Trig0_str = sprintf('Trig0 50 percent trigger efficiency = %d',round(Trig0_DAC));
Trig1_str = sprintf('Trig1 50 percent trigger efficiency = %d',round(Trig1_DAC));
Trig2_str = sprintf('Trig2 50 percent trigger efficiency = %d',round(Trig2_DAC));

plot(DAC_Code, Trig_Ratio0,'k*-');
hold on;
plot(DAC_Code, Trig_Ratio1,'b*-');
hold on;
plot(DAC_Code, Trig_Ratio2,'r*-');
hold off;
axis([0 1024, -10 110]);
xlabel('\bfDAC Code');
ylabel('\bfTrigger efficiency (%)');
h = legend('Trig0','Trig1','Trig2');
set(h, 'Location','southeast')
title('\bfS-Curve Test, 80fC');
text(600,80,Trig0_str);
text(600,70,Trig1_str);
text(600,60,Trig2_str);
% figure(1)
% plot(DAC_Code, Trig_Ratio0,'k*-');
% axis([x0_S x0_E, -0.2 1.2])
% h = legend(Legend_Trig0);
% set(h,'Location','northoutside');
% figure(2)
% plot(DAC_Code, Trig_Ratio1,'k*-');
% axis([x1_S x1_E, -0.2 1.2])
% h = legend(Legend_Trig1);
% set(h,'Location','northoutside');
% figure(3)
% plot(DAC_Code, Trig_Ratio2,'k*-');
% axis([x2_S x2_E, -0.2 1.2])
% h = legend(Legend_Trig2);
% set(h,'Location','northoutside');