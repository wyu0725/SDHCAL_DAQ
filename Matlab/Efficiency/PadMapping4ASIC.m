function [ Pad ] = PadMapping4ASIC( MapData, A, B, N, P)
%UNTITLED2 此处显示有关此函数的摘要
% 连接器上A~P 区域的pad和整个pad的映射关系
% MapData: The mapping table of the hole pad, in the format of string
% A~P: Data of 14 pad : format double 64x1
% Pad: Data of the 30*30 pad
%   此处显示详细说明
    Pad= zeros(18, 15);
    for i = 1:1:18
        for j = 1:1:15
            mapdata = char(MapData(i,j));
            MapDataLength = length(mapdata);
            MapDataHeader = mapdata(1);
            if(MapDataLength == 2)
                MapDataIndex = str2double(mapdata(2));
            else 
                MapDataIndex = str2double([mapdata(2),mapdata(3)]);
            end
            switch MapDataHeader
                case 'A'
                    Pad(i,j) = A(MapDataIndex);
                case 'B'
                    Pad(i,j) = B(MapDataIndex);                
                case 'N'
                    Pad(i,j) = N(MapDataIndex);
                case 'P'
                    Pad(i,j) = P(MapDataIndex);
                case 'X'
                    Pad(i,j) = 0;
                otherwise
                    Pad(i,j) = 0;                      
            end
        end
    end
end

