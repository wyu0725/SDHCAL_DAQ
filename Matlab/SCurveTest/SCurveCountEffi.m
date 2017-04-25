InitialData = Importdata();
%Test_Header = InitialData(1);
%[Test_Channel, DAC_Code, P0, T0, P1, T1, P2, T2] = ReadData(InitialData, 2);
[~, DAC_Code, P0, T0, P1, T1, P2, T2] = ReadData(InitialData, 2);
figure
Charge = 1:1:593;
CountEffi = 1:1:593;
for i = 1:1:593
    Charge(594 - i) = (592 - DAC_Code(i))/1.01;
    CountEffi(594 - i) = T2(i);
end
x= Charge;
y=CountEffi;
figure
plot(x,y);
xlabel('Vth(fC)');
ylabel('Count Efficiency(count/sec)')
title('\bfS-Curve Test, 8keV X-Ray');
DiffCountEffi = -diff(CountEffi);
DiffCharge = Charge(1:592);
figure;
plot(DiffCharge,DiffCountEffi);
figure;
plot(DAC_Code, T2,'r');
axis([0 593, -10 15000]);
xlabel('\bfVth(DAC Code)');
ylabel('\bfTrigger efficiency (%)');
h = legend('Trig2');
set(h, 'Location','southeast')
title('\bfS-Curve Test, 8keV X-Ray');
Average = 1:1:295;
for i = 1:1:295
    SumEffi = 0;
    for k = 0:1:1
        SumEffi = SumEffi + CountEffi(2*i - k);
    end
    Average(i) = SumEffi/2;
end
figure;
plot(Average);
DiffAve = diff(Average);
figure
plot(DiffAve)