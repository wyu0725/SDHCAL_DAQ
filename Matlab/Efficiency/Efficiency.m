% 导入数据及设定数据包个数
InitialData = ImportData();
PackageNumber = 9000;
% 读回芯片的编号Header Brunch ID BCID和数据ASICChannelData
Header = zeros(PackageNumber, 1);
BCIDGray = zeros(PackageNumber, 1);
ASICChannelData = zeros(PackageNumber, 64);
for i = 1:1:PackageNumber
    [Header(i), BCIDGray(i), ASICChannelData(i, :)] = ReadPackage(InitialData, i -1);
end
% 将读回的数据分配到ASIC1~4，在这里没有考虑一个Start来了两个ASIC被击中的情况，
% 后面再想办法加上这种情况的判断
A1Data = zeros(PackageNumber, 64);
A2Data = zeros(PackageNumber, 64);
A3Data = zeros(PackageNumber, 64);
A4Data = zeros(PackageNumber, 64);
i = 1;
while(i <= PackageNumber)
    if(Header(i) == hex2dec('A1'))
        A1Data(i,:) = ASICChannelData(i,:);
    end
    if(Header(i) == hex2dec('A2'))
        A2Data(i,:) = ASICChannelData(i,:);
    end
    if(Header(i) == hex2dec('A3'))
        A3Data(i,:) = ASICChannelData(i,:);
    end
    if(Header(i) == hex2dec('A4'))
        A4Data(i,:) = ASICChannelData(i,:);
    end
    i = i + 1;
end
% 将芯片的数据和连接器的数据映射起来
AConnector = zeros(PackageNumber, 64);
BConnector = zeros(PackageNumber, 64);
NConnector = zeros(PackageNumber, 64);
PConnector = zeros(PackageNumber, 64);
for i = 1:1:PackageNumber
    AConnector(i,:) = [A1Data(i, 1:32) A2Data(i, 1:32)];
    BConnector(i,:) = [A3Data(i, 1:32) A4Data(i, 1:32)];
    PConnector(i,:) = [A1Data(i, 33:64) A2Data(i, 33:64)];
    NConnector(i,:) = [A3Data(i, 33:64) A4Data(i, 33:64)];
end
% 将连接器的数据和Pad的通道映射起来
PadA = zeros(PackageNumber, 64);
PadB = zeros(PackageNumber, 64);
PadN = zeros(PackageNumber, 64);
PadP = zeros(PackageNumber, 64);
PadData = zeros(PackageNumber, 18, 15);
[AConnectorChannel,APadChannel] = GetMapping('Mapping_A.txt');
[BConnectorChannel,PadBChannel] = GetMapping('Mapping_B.txt');
[NConnectorChannel,PadNChannel] = GetMapping('Mapping_N.txt');
[PConnectorChannel,PadPChannel] = GetMapping('Mapping_P.txt');
MapData = GetPadMapData4ASIC();
for i = 1:1:PackageNumber
    PadA(i,:) = SingleMapping(AConnector(i,:),AConnectorChannel,APadChannel);
    PadB(i,:) = SingleMapping(BConnector(i,:),BConnectorChannel,PadBChannel);
    PadN(i,:) = SingleMapping(NConnector(i,:),NConnectorChannel,PadNChannel);
    PadP(i,:) = SingleMapping(PConnector(i,:),PConnectorChannel,PadPChannel);
    PadData(i,:,:) = PadMapping4ASIC(MapData, PadA(i,:), PadB(i,:), PadN(i,:), PadP(i,:));
end
% 对数据进行统计，即有一个击中pad超过最高的阈的时候，统计周围pad的击中情况
Hit3Over1 = 0;
Hit3Over2 = 0;
Hit3Over3 = 0;
PadData1 = zeros(100,18,15);
Over1 = 0;
Over2 = 0;
Over3 = 0;
Hit3 = 0;
Crosstalk = 0;
for i = 1:1:PackageNumber
    a = 1;
    for j = 1:1:18
        for k = 1:1:15
            if(PadData(i,j,k) == 3)
                Hit3 = Hit3 + 1;
                if((j > 1 && PadData(i,j-1,k) == 1) ...,
                        || (j < 18 && PadData(i,j + 1,k) == 1) ...,
                        || (k > 1 && PadData(i,j,k - 1) == 1) ...,
                        || (k < 15 && PadData(i,j,k + 1) == 1))
                    Hit3Over1 = Hit3Over1 + 1;
                    Over1 = [Over1 i];
                end
                if((j > 1 && PadData(i,j-1,k) == 2) ...,
                        || (j < 18 && PadData(i,j + 1,k) == 2) ...,
                        || (k > 1 && PadData(i,j,k - 1) == 2) ...,
                        || (k < 15 && PadData(i,j,k + 1) == 2))
                    Hit3Over2 = Hit3Over2 + 1;
                    Over2 = [Over2 i];
                end
                if((j > 1 && PadData(i,j-1,k) == 3) ...,
                        || (j < 18 && PadData(i,j + 1,k) == 3) ...,
                        || (k > 1 && PadData(i,j,k - 1) == 3) ...,
                        || (k < 15 && PadData(i,j,k + 1) == 3))
                    Hit3Over3 = Hit3Over3 + 1;
                    Over3 = [Over3 i];
                end    
                if((j > 1 && PadData(i,j-1,k) ~= 0) ...,
                        || (j < 18 && PadData(i,j + 1,k) ~= 0) ...,
                        || (k > 1 && PadData(i,j,k - 1) ~= 0) ...,
                        || (k < 15 && PadData(i,j,k + 1) ~= 0))
                    Crosstalk = Crosstalk + a;
                    a = 0  ;                  
                end  
            end
        end
    end
end
Over1(1) = [];
Over2(1) = [];
Over3(1) = [];
Over3New = unique(Over3);
for i = 1:1:length(Over3New)
    figure;
    PlotData = zeros(18,15);
    PlotData(:) = PadData(Over3New(i),:,:);
    b = bar3(PlotData);
    TitleString = sprintf('%d',Over3New(i));
    title(TitleString);
    colormap(flipud(parula))
    colorbar;
    for k = 1:length(b)
        zdata = b(k).ZData;
        b(k).CData = zdata;
        b(k).FaceColor = 'interp';
    end
end
for i = 1:1:length(Over2)
    figure;
    PlotData = zeros(18,15);
    PlotData(:) = PadData(Over2(i),:,:);
    b = bar3(PlotData);
    colormap(flipud(parula))
    colorbar;
    for k = 1:length(b)
        zdata = b(k).ZData;
        b(k).CData = zdata;
        b(k).FaceColor = 'interp';
    end
end
% Change the connector data to pad Data
AEqual1 = zeros(1, 64);
AEqual2 = zeros(1, 64);
AEqual3 = zeros(1, 64);
BEqual1 = zeros(1, 64);
BEqual2 = zeros(1, 64);
BEqual3 = zeros(1, 64);
NEqual1 = zeros(1, 64);
NEqual2 = zeros(1, 64);
NEqual3 = zeros(1, 64);
PEqual1 = zeros(1, 64);
PEqual2 = zeros(1, 64);
PEqual3 = zeros(1, 64);
for i = 1:1:PackageNumber
    for j = 1:1:64
        if(PadA(i,j) == 1)
            AEqual1(j) = AEqual1(j) + 1;
        elseif(PadA(i,j) == 2)
            AEqual2(j) = AEqual2(j) + 1;
        elseif(PadA(i,j) == 3)
            AEqual3(j) = AEqual3(j) + 1;
        end
        if(PadB(i,j) == 1)
            BEqual1(j) = BEqual1(j) + 1;
        elseif(PadB(i,j) == 2)
            BEqual2(j) = BEqual2(j) + 1;
        elseif(PadB(i,j) == 3)
            BEqual3(j) = BEqual3(j) + 1;
        end
        if(PadN(i,j) == 1)
            NEqual1(j) = NEqual1(j) + 1;
        elseif(PadN(i,j) == 2)
            NEqual2(j) = NEqual2(j) + 1;
        elseif(PadN(i,j) == 3)
            NEqual3(j) = NEqual3(j) + 1;
        end
        if(PadP(i,j) == 1)
            PEqual1(j) = PEqual1(j) + 1;
        elseif(PadP(i,j) == 2)
            PEqual2(j) = PEqual2(j) + 1;
        elseif(PadP(i,j) == 3)
            PEqual3(j) = PEqual3(j) + 1;
        end
    end
end
Pad1 = PadMapping4ASIC(MapData,AEqual1,BEqual1,NEqual1,PEqual1);
Pad2 = PadMapping4ASIC(MapData,AEqual2,BEqual2,NEqual2,PEqual2);
Pad3 = PadMapping4ASIC(MapData,AEqual3,BEqual3,NEqual3,PEqual3);
figure;
b1 = bar3(Pad1);
colormap(flipud(parula))
colorbar;
for k = 1:length(b1)
   zdata = b1(k).ZData;
   b1(k).CData = zdata;
   b1(k).FaceColor = 'interp';
end
figure;
b2 = bar3(Pad2);
colormap(flipud(parula))
colorbar;
for k = 1:length(b2)
   zdata = b2(k).ZData;
   b2(k).CData = zdata;
   b2(k).FaceColor = 'interp';
end
figure;
b3 = bar3(Pad3);
colormap(flipud(parula))
colorbar;
for k = 1:length(b3)
   zdata = b3(k).ZData;
   b3(k).CData = zdata;
   b3(k).FaceColor = 'interp';
end
M = 2^24;
BCIDBin = gray2bin(BCIDGray,'qam',M);