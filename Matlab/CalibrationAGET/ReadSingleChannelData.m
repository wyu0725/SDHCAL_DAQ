function [ Header, BoardNumber, TimeStamp, Channel, TrigID, DataOut, Tail ] = ReadSingleChannelData( InitialData, PackageNumber )
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
    Header = InitialData((PackageNumber-1)*520 + 1);
    BoardNumber = InitialData((PackageNumber -1)*520 + 2);
    TimeStamp = InitialData((PackageNumber - 1)*520 + 3)* 65536 + InitialData((PackageNumber - 1)*520 + 4);
    Channel = InitialData((PackageNumber - 1)*520 + 5);
    TrigID = InitialData((PackageNumber - 1)*520 + 6);
    DataOut = InitialData((PackageNumber - 1)*520 + 7:(PackageNumber - 1)*520 + 518) - 40960;
    Tail = ((PackageNumber - 1)*520 + 519)*65536 + ((PackageNumber - 1)*520 + 520);

end

