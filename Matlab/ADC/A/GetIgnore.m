function [IgnoreChannel] = GetIgnore( )
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
    [FileName,PathName,FilterIndex] = uigetfile('*.txt','Select the file');
    if FilterIndex
        filename = [PathName FileName];
        delimiterIn = ' ';
        headerlinesIn = 1;
        A = importdata(filename, delimiterIn, headerlinesIn);
    end
    IgnoreChannel = A.data(:,1);
end

