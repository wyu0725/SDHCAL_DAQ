InitialData = ImportData();
% prompt = {'Which package would you want to display start from','How many package would you like to display'};
% dlg_title = 'Input the package number';
% answer = inputdlg(prompt,dlg_title);
% PackNunber = str2double(answer(1));
% DisplayNumber = str2double(answer(2));
AsicChannelData = zeros(16, 64);
while (InitialData(1) ~= 0)
    PackageNumber = 1;
    [header, ~, Ch_data] = ReadPackageSlaveDaq(InitialData, PackageNumber);
    AsicIndex = CheckHeader(header);
    while (AsicIndex ~= 0)
        AsicChannelData(AsicIndex, :) = AsicChannelData(AsicIndex, :) + Ch_data';
        PackageNumber = PackageNumber + 1;
        [header, ~, Ch_data] = ReadPackageSlaveDaq(InitialData, PackageNumber);
        AsicIndex = CheckHeader(header);
    end    
    InitialData = ImportData();
end

[Row, Column, AsicID, Channel] = GetNewDifMapping();
PadData = zeros(31, 31);
for i = 1:1:900
    PadData(Row(i), Column(i)) = AsicChannelData(AsicID(i), Channel(i));
end
X = 1:31;
Y = 1:31;
figure;
fig = pcolor(X,Y,PadData);
ax = gca;
colormap(jet)
% a = axes;
caxis();
colorbar();
axis ij
axis square

set(fig,'linestyle','-','edgecolor','k')

legend_str = sprintf('The Pad that hitted');
h = legend(legend_str);
set(h,'Location','northoutside');
