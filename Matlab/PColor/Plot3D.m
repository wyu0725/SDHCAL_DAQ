%Plot3d
InitialData = ImportData();
% Read one pack
prompt = {'Which package would you want to display'};
dlg_title = 'Input the package number';
answer = inputdlg(prompt,dlg_title);
PackNo = str2double(answer);
[header, BCID, Ch_data] = ReadPackage(InitialData, PackNo);
% % % Get mapping function
% [FileName,PathName,FilterIndex] = uigetfile('*.txt','Select the file');
% if FilterIndex
%     filename = [PathName FileName];
%     delimiterIn = ' ';
%     headerlinesIn = 1;
%     A = importdata(filename, delimiterIn, headerlinesIn);
% end
% ASIC_Channel = A.data(:,1);
% Pad_Channel = A.data(:,2);
[ASIC_Channel, Pad_Channel] = GetMapping();
New_ChannelData = SingleMapping(Ch_data, ASIC_Channel, Pad_Channel);
X = 1:8;
Y = 1:8;
C = zeros(8, 8);
for i = 1:8
    for j = 1:8        
        C(i,j) = New_ChannelData((i - 1)*8 + j);
    end
end
width = 1;
b = bar3(C,width);
colormap(flipud(winter(4)))
% a = axes;
caxis([0,4]);
colorbar('Ticks',[0.5,1.5,2.5,3.5],'TickLabels',{'<2fC','2fC~20fC','20fC~200fC','>200fC'});
for k = 1:length(b)
    zdata = b(k).ZData;
    b(k).CData = zdata;
    b(k).FaceColor = 'interp';
end
legend_str = sprintf('Pad that hitted \n header = %X, BCID = %u',header,BCID);
h = legend(legend_str);
set(h,'Location','northoutside');
% for i = 1:8
%     for j = 1:8
%         PadNum = j + 8*(i - 1);
%         str = ['Ch', int2str(PadNum)];
%         xText_o = 0.5;
%         yText_o = 1;
%         xText = xText_o + (j - 1);
%         yText = yText_o + (i - 1);
%         text('String',str,'Position',[xText, yText],'FontSize',10,'Color','r');
%     end
% end