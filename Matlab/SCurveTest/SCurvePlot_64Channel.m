%% 64 Channel SCurvePlot
InitialData = Importdata();
legend_str = cell(1,4);
for i=59:1:63
    SCurvePlotSingleChannel(InitialData, i);
    legend_str{i-58} = sprintf('Channel%d',i+1);    
end
% legend_str = {'Channel1','Channel2'};
figure(1)
legend(legend_str);
axis([0 1023,-10 110]);
hold off;
figure(2)
axis([0 1023,-10 110]);
hold off;
figure(3)
axis([0 1023,-10 110]);
hold off;