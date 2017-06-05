function [ Channel, DAC_Code, CountP0, CountT0, CountP1, CountT1, CountP2, CountT2 ] = ReadDataWiDacRange( Initialdata, ReadStart, DacRange )
%UNTITLED4 此处显示有关此函数的摘要
%   此处显示详细说明
    Channel = bitand(Initialdata(ReadStart), uint16(255));
    DAC_Code = 1:1:DacRange;
    CountP0 = 1:1:DacRange;
    CountP1 = 1:1:DacRange;
    CountP2 = 1:1:DacRange;
    CountT0 = 1:1:DacRange;
    CountT1 = 1:1:DacRange;
    CountT2 = 1:1:DacRange;
    for i = 1:1:DacRange
        DAC_Code(i) = bitand((Initialdata(ReadStart + 7*(i-1) + 1)), uint16(1023));
        CountP0(i) = Initialdata(ReadStart + 7*(i-1) + 2);
        CountT0(i) = Initialdata(ReadStart + 7*(i-1) + 3);
        CountP1(i) = Initialdata(ReadStart + 7*(i-1) + 4);
        CountT1(i) = Initialdata(ReadStart + 7*(i-1) + 5);
        CountP2(i) = Initialdata(ReadStart + 7*(i-1) + 6);
        CountT2(i) = Initialdata(ReadStart + 7*(i-1) + 7);
    end

end

