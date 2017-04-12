function [ Pad ] = PadMapping( MapData, A, B, C, D, E, F, G, H, J, K, L, M, N, P)
%UNTITLED2 此处显示有关此函数的摘要
% 连接器上A~P 区域的pad和整个pad的映射关系
% MapData: The mapping table of the hole pad, in the format of string
% A~P: Data of 14 pad : format double 64x1
% Pad: Data of the 30*30 pad
%   此处显示详细说明
    Pad= zeros(30, 30);
    for i = 1:1:30
        for j = 1:1:30
            mapdata = MapData(i,j);
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
                case 'C'
                    Pad(i,j) = C(MapDataIndex);
                case 'D'
                    Pad(i,j) = D(MapDataIndex);
                case 'E'
                    Pad(i,j) = E(MapDataIndex);
                case 'F'
                    Pad(i,j) = F(MapDataIndex);
                case 'G'
                    Pad(i,j) = G(MapDataIndex);
                case 'H'
                    Pad(i,j) = H(MapDataIndex);    
                case 'J'
                    Pad(i,j) = J(MapDataIndex);
                case 'K'
                    Pad(i,j) = K(MapDataIndex);
                case 'L'
                    Pad(i,j) = L(MapDataIndex);
                case 'M'
                    Pad(i,j) = M(MapDataIndex);
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

