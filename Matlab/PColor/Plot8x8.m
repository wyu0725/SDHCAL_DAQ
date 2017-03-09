%% Pesudocolor Plot of 8*8 Square
% Read data from *.dat, and plot as hitmap

%--- Open file and Import data ---%
InitialData = importdata();
% Read one pack
prompt = {'Which package would you want to display';
dlg_title = 'Input the package number';
answer = inputdlg(prompt,dlg_title);
PackNo = str2double(answer);
[header, BCID, Ch_data] = ReadPackage(InitialData, PackNo);

%----- Plot The Data -----%
X = 1:9;
Y = 1:9;
C = zeros(9,9);
for i = 1:9
    for j = 1:9        
        if (i == 9) || (j ==9)
            C(i,j) = 0;
        else
            C(i,j) = Ch_data((i - 1)*8 + j);
        end
    end
end

fig = pcolor(X,Y,C);
% coclormap summer
ax = gca;
colormap(flipud(gray(4)))
% a = axes;
caxis([0,4]);
colorbar('Ticks',[0.5,1.5,2.5,3.5],'TickLabels',{'<2fC','2fC~20fC','20fC~200fC','>200fC'});
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

% ax = gca;
% ax.Color = 'b';
% ax.XAxis.Color = 'r';
% ax.YAxis.Color = 'g';
%h = axes('xcolor','y','ycolor','r','xgrid','on','ygrid','on');
%set(h,);