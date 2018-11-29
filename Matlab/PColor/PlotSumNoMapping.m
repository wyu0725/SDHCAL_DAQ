%--- Open file and Import data ---%
InitialData = ImportData();
% Read one pack
prompt = {'Which package would you want to display start from','How many package would you like to display'};
dlg_title = 'Input the package number';
answer = inputdlg(prompt,dlg_title);
PackNo = str2double(answer(1));
DisplayNo = str2double(answer(2));


New_ChannelData = zeros(64,1);
for i = 1:DisplayNo
    [~, ~, Ch_data] = ReadPackageSlaveDaq(InitialData, PackNo + i - 1);
    New_ChannelData = New_ChannelData + Ch_data;
end

%----- Plot The Data -----%
X = 1:9;
Y = 1:9;
C = zeros(9,9);
for i = 1:9
    for j = 1:9        
        if (i == 9) || (j ==9)
            C(i,j) = 0;
        else
            C(i,j) = New_ChannelData((i - 1)*8 + j);
        end
    end
end
figure;
fig = pcolor(X,Y,C);
% coclormap summer
ax = gca;
colormap(flipud(gray))
% a = axes;
caxis;
colorbar;
axis ij
axis square

set(fig,'linestyle','-','edgecolor','b')

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

