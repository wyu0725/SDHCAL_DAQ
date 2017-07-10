function [ MapData ] = GetPadMapData4ASIC()
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
    MapData = cell(15, 18);
    [fid,~] = fopen('4ASIC_Order.txt','r');
    mapping = textscan(fid, '%s');
    for i = 1:1:15
       for j = 1:1:18
           MapData(i, j) = mapping{1}(j + 15*(i - 1));
       end
    end
end

