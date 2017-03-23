FileImport = uiimport('-file');
FileData = FileImport.data;
Channel = FileData(:,1)';
DC_VoutSh = FileData(:,2)';
Mean_DC_VoutSh = mean(DC_VoutSh);
Var_DC_VoutSh = var(DC_VoutSh);
Std_DC_VoutSh = std(DC_VoutSh);

%------ Plot ------%
plot(Channel, DC_VoutSh,'ob');
hold on;
plot(Channel, DC_VoutSh,'--k');
xlabel('Channel');
ylabel('DC Voltage');
Max_DC_VoutSh = max(DC_VoutSh);
Min_DC_VoutSh = min(DC_VoutSh);
yMax = Max_DC_VoutSh + (Max_DC_VoutSh - Min_DC_VoutSh)/5;
yMin = Min_DC_VoutSh - (Max_DC_VoutSh - Min_DC_VoutSh)/5;
axis([0 Channel(64) yMin yMax]);
h = legend('DC Voltage vs Channel without correction');
set(h,'Interpreter','latex','FontSize',10,'Location','southeast');
xtext = max(Channel)/10;
ytext = yMax - (yMax - yMin)/15;
textOut = sprintf('Mean = %.5fV,\\sigma = %.5fmV \n Max = %.5fV,Min = %.5fV',Mean_DC_VoutSh,sqrt(Var_DC_VoutSh)*1000,Max_DC_VoutSh,Min_DC_VoutSh);
text('Interpreter','tex','String',textOut,'Position',[xtext, ytext],'FontSize',14,'color','r');