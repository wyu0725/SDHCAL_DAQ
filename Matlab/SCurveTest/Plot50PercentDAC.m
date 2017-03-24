% ImportData_0fC = Importdata();
prompt_asic = 'Please Input the ASIC ID';
dlg_title_asic = 'ASIC ID';
answer = inputdlg(prompt_asic, dlg_title_asic);
ASIC_ID = str2double(answer);
prompt_num = {'Input the number of the data'};
dlg_title_num = 'Number of data';
answer = inputdlg(prompt_num,dlg_title_num);
Data_Number = str2double(answer);
DAC0_50Percent = zeros(1,64);
DAC1_50Percent = zeros(1,64);
DAC2_50Percent = zeros(1,64);
Channel = 1:1:64;
mean_DAC0 = 1:1:Data_Number;
mean_DAC1 = 1:1:Data_Number;
mean_DAC2 = 1:1:Data_Number;
Legend_str = cell(Data_Number,1);
Channel0_DAC = 1:1:Data_Number;
DeltaV = 1:1:Data_Number;
prompt_Charge = 'Input the charge and select the file';
dlg_title_Charge = 'Charge';
Charge = 1:1:Data_Number;
for i = 1:1:Data_Number
    Charge_answer = inputdlg(prompt_Charge, dlg_title_Charge);
    Charge(i) = str2double(Charge_answer);
    ImportData = Importdata();
    for j = 0:1:63
        [DAC0_50Percent(j+1), DAC1_50Percent(j+1), DAC2_50Percent(j+1)] = SingleChannelTrigEfficiency(ImportData, j);
    end
    str_tmp = sprintf('%d fC',Charge(i));
    Legend_str{i} = str_tmp;
%     mean_DAC0(i) = mean(DAC0_50Percent);
    Channel0_DAC(i) = DAC0_50Percent(1);
    DeltaV(i) = 2.43*(Channel0_DAC(1) - Channel0_DAC(i));
    figure(1);
    stairs(Channel,DAC0_50Percent);
    hold on;
end
figure(1)
h = legend(Legend_str);
set(h,'Location','eastout');
xlabel('\bf Channel Number');
ylabel('\bf DAC Code')
title1_str = sprintf('50%% Trig efficiency with different charge input--ASIC Number:%d',ASIC_ID);
title(title1_str);
hold off

% Charge = [0,1,2,4,5,6,8,10];

Rp = corrcoef(Charge, DeltaV);
R = Rp(2,1);
x = linspace(min(Charge),max(Charge));
p0 = polyfit(Charge,DeltaV,1);
y0 = polyval(p0,x);
figure(2)
plot(Charge,DeltaV,'r*');
linear_legend_str = sprintf('Linear fit of shaper output,R:%1.6f -- ASIC ID£º%d',R, ASIC_ID);
xlabel('Charge(fC)');
h = ylabel('\Delta V (mV)');
set(h,'Interpreter','tex');
hold on
plot(x,y0)
legend('Shaper output',linear_legend_str);