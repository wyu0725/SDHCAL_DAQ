%% SCurve Plot
InitialData = Importdata();
Test_Header = InitialData(1);
[Test_Channel, DAC_Code, P0, T0, P1, T1, P2, T2] = ReadDAC(InitialData, 2);
DAC_Code1 = 1:1:1024;
Trig_Ratio0 = T0./P0;
Trig_Ratio1 = T1./P1;
Trig_Ratio2 = T2./P2;
figure(1)
plot(DAC_Code1, Trig_Ratio0);
figure(2)
plot(DAC_Code1, Trig_Ratio1);
figure(3)
plot(DAC_Code1, Trig_Ratio2);