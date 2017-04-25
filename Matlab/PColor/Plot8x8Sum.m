%% Pesudocolor Plot of 8*8 Square
% Read data from *.dat, and plot as hitmap

%--- Open file and Import data ---%
InitialData = ImportData();
% Read one pack
prompt = {'Which package would you want to display start from','How many package would you like to display'};
dlg_title = 'Input the package number';
answer = inputdlg(prompt,dlg_title);
PackNo = str2double(answer(1));
DisplayNo = str2double(answer(2));
% Get Mapping Function
[ASIC_Channel, Pad_Channel] = GetMapping();
SumData = zeros(64,1);
for DisplayK = 1:DisplayNo
    [header, BCID, Ch_data] = ReadPackage(InitialData, PackNo + DisplayK - 1);
%     if(header ~= hex2dec('A0'))
%         continue;
%     end
%     NewChannelData = SingleMapping(Ch_data, ASIC_Channel, Pad_Channel);
    SumData = SumData + Ch_data;

%     %----- Plot The Data -----%
%     X = 1:9;
%     Y = 1:9;
%     C = zeros(9,9);
%     for i = 1:9
%         for j = 1:9        
%             if (i == 9) || (j ==9)
%                 C(i,j) = 0;
%             else
%                 C(i,j) = NewChannelData((i - 1)*8 + j);
%             end
%         end
%     end
%     
%     figure(DisplayK);
%     fig = pcolor(X,Y,C);
%     % coclormap summer
%     ax = gca;
%     colormap(flipud(gray(4)))
%     % a = axes;
%     caxis([0,4]);
%     colorbar('Ticks',[0.5,1.5,2.5,3.5],'TickLabels',{'<50','50~150','>150','Not Use'});
%     axis ij
%     axis square
% 
%     set(fig,'linestyle','-','edgecolor','b')
% 
%     legend_str = sprintf('The Pad that hitted \n header = %X, BCID = %u',header,BCID);
%     h = legend(legend_str);
%     set(h,'Location','northoutside');
%     for i = 1:8
%         for j = 1:8
%             PadNum = j + 8*(i - 1);
%             str = ['Ch', int2str(PadNum)];
%             xText_o = 1.1;
%             yText_o = 1.5;
%             xText = xText_o + (j - 1);
%             yText = yText_o + (i - 1);
%             text('String',str,'Position',[xText, yText],'FontSize',10,'Color','r');
%         end
%     end
end
NewSumData = SingleMapping(SumData, ASIC_Channel, Pad_Channel);
 X = 1:9;
 Y = 1:9;
CTotal = zeros(9,9);
for i = 1:9
        for j = 1:9        
            if (i == 9) || (j ==9)
                CTotal(i,j) = 0;
            else
                CTotal(i,j) = NewSumData((i - 1)*8 + j);
            end
        end
end
figure;
fig = pcolor(X,Y,CTotal);
    % coclormap summer
ax = gca;
colormap(flipud(gray))
colorbar;
axis ij;
axis square;
legend_str = sprintf('The Pad that hitted \n header = %X, BCID = %u',header,BCID);
    h = legend(legend_str);
    set(h,'Location','northoutside');
    for i = 1:8
        for j = 1:8
            PadNum = j + 8*(i - 1);
            str = ['Ch', int2str(PadNum)];
            xText_o = 1.1;
            yText_o = 1.5;
            xText = xText_o + (j - 1);
            yText = yText_o + (i - 1);
            text('String',str,'Position',[xText, yText],'FontSize',10,'Color','r');
        end
    end
  
 C3D = zeros(8,8);   
for i = 1:8
    for j = 1:8        
        C3D(i,j) = NewSumData((i - 1)*8 + j);
    end
end
width = 1;
figure;
b = bar3(C3D,width);
colormap(flipud(parula))
colorbar;
% a = axes;
% caxis([0,4]);
% colorbar('Ticks',[0.5,1.5,2.5,3.5],'TickLabels',{'<2fC','2fC~20fC','20fC~200fC','>200fC'});
for k = 1:length(b)
    zdata = b(k).ZData;
    b(k).CData = zdata;
    b(k).FaceColor = 'interp';
end
% ax = gca;
% ax.Color = 'b';
% ax.XAxis.Color = 'r';
% ax.YAxis.Color = 'g';
%h = axes('xcolor','y','ycolor','r','xgrid','on','ygrid','on');
%set(h,);