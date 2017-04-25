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
GreatThan1 = zeros(64,1);
GreatThan2 = zeros(64,1);
GreatThan3 = zeros(64,1);
for DisplayK = 1:DisplayNo
    [header, BCID, Ch_data] = ReadPackage(InitialData, PackNo + DisplayK - 1);
%     if(header ~= hex2dec('A0'))
%         continue;
%     end
%     NewChannelData = SingleMapping(Ch_data, ASIC_Channel, Pad_Channel);
    for k = 1:1:64
        if(Ch_data(k) == 1)
            GreatThan1(k) = GreatThan1(k) + 1;
        end
        if(Ch_data(k) == 2)
            GreatThan2(k) = GreatThan2(k) + 1;
        end
        if(Ch_data(k) == 3)
            GreatThan3(k) = GreatThan3(k) + 1;
        end
    end
    
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
NewGreatThan1 = SingleMapping(GreatThan1, ASIC_Channel, Pad_Channel);
C3D1 = zeros(8,8);   
for i = 1:8
    for j = 1:8        
        C3D1(i,j) = NewGreatThan1((i - 1)*8 + j);
    end
end
width = 1;
figure;
b1 = bar3(C3D1,width);
colormap(flipud(parula))
colorbar;
for k = 1:length(b1)
    zdata = b1(k).ZData;
    b1(k).CData = zdata;
    b1(k).FaceColor = 'interp';
end
NewGreatThan2 = SingleMapping(GreatThan2, ASIC_Channel, Pad_Channel);
C3D2 = zeros(8,8);   
for i = 1:8
    for j = 1:8        
        C3D2(i,j) = NewGreatThan2((i - 1)*8 + j);
    end
end
width = 1;
figure;
b2 = bar3(C3D2,width);
colormap(flipud(parula))
colorbar;
for k = 1:length(b2)
    zdata = b2(k).ZData;
    b2(k).CData = zdata;
    b2(k).FaceColor = 'interp';
end
NewGreatThan3 = SingleMapping(GreatThan3, ASIC_Channel, Pad_Channel);
C3D2 = zeros(8,8);   
for i = 1:8
    for j = 1:8        
        C3D2(i,j) = NewGreatThan3((i - 1)*8 + j);
    end
end
width = 1;
figure;
b3 = bar3(C3D2,width);
colormap(flipud(parula))
colorbar;
for k = 1:length(b3)
    zdata = b3(k).ZData;
    b3(k).CData = zdata;
    b3(k).FaceColor = 'interp';
end

WeightSum = (3*NewGreatThan1 + 20*NewGreatThan2 + 150*NewGreatThan3)/DisplayNo;
C3DWeight = zeros(8,8);   
for i = 1:8
    for j = 1:8        
        C3DWeight(i,j) = WeightSum((i - 1)*8 + j);
    end
end
width = 1;
figure;
bWeight = bar3(C3DWeight,width);
colormap(flipud(parula))
colorbar;
for k = 1:length(bWeight)
    zdata = bWeight(k).ZData;
    bWeight(k).CData = zdata;
    bWeight(k).FaceColor = 'interp';
end
CWeight = zeros(9,9);
for i = 1:9
        for j = 1:9        
            if (i == 9) || (j ==9)
                CWeight(i,j) = 0;
            else
                CWeight(i,j) = WeightSum((i - 1)*8 + j);
            end
        end
end
figure;
fig = pcolor(X,Y,CWeight);
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
% ax = gca;
% ax.Color = 'b';
% ax.XAxis.Color = 'r';
% ax.YAxis.Color = 'g';
%h = axes('xcolor','y','ycolor','r','xgrid','on','ygrid','on');
%set(h,);