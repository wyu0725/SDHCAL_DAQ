%% 64 Channel SCurvePlot
InitialData = Importdata();
legend_str = cell(8,8);
DAC0_50percent = 1:1:64;
DAC1_50percent = 1:1:64;
DAC2_50percent = 1:1:64;
for i=0:1:63
    [DAC0_50percent(i+1), DAC1_50percent(i+1), DAC2_50percent(i+1)] = SCurvePlotSingleChannel(InitialData, i ,0);
    %legend_str{i+1} = sprintf('Channel%d',i+1);    
end
Channel_Number = 1:1:64;
figure(4)
plot(Channel_Number, DAC0_50percent,'*-');
figure(5)
plot(Channel_Number, DAC1_50percent,'*-');
figure(6)
plot(Channel_Number, DAC2_50percent,'*-');
% legend_str = {'Channel1','Channel2'};
figure(1)
%legend(legend_str{1});
axis([0 1023,-10 110]);
hold off;
figure(2)
axis([0 1023,-10 110]);
hold off;
figure(3)
axis([0 1023,-10 110]);
hold off;