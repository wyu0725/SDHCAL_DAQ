% ImportData_0fC = Importdata();
DAC0_50Percent = zeros(1,64);
DAC1_50Percent = zeros(1,64);
DAC2_50Percent = zeros(1,64);
Channel = 1:1:64;
mean_DAC0 = 1:1:8;
mean_DAC1 = 1:1:8;
mean_DAC2 = 1:1:8;
Legend_str = cell(1,8);
Channel0_DAC = 1:1:8;
for i = 1:1:8
    ImportData = Importdata();
    for j = 0:1:63
        [DAC0_50Percent(j+1), DAC1_50Percent(j+1), DAC2_50Percent(j+1)] = SingleChannelTrigEfficiency(ImportData, j);
    end
%     mean_DAC0(i) = mean(DAC0_50Percent);
    Channel0_DAC(i) = DAC0_50Percent(1);
    figure(1);
    stairs(Channel,DAC0_50Percent);
    hold on;
end
figure(1)
legend('0fC','1fC','2fC','4fC','5fC','6fC','8fC','10fC')
hold off

Charge = [0,1,2,4,5,6,8,10];
Rp = corrcoef(Charge, Channel0_DAC);
R = Rp(2,1);
x = linspace(min(Charge),max(Charge));
p0 = polyfit(Charge,Channel0_DAC,1);
y0 = polyval(p0,x);
figure(2)
plot(Charge,Channel0_DAC,'k*-')
hold on
plot(x,y0)