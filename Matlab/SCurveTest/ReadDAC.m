function [Channel, DAC_Code, CountP0, CountT0, CountP1, CountT1, CountP2, CountT2] = ReadDAC(Initialdata, ReadStart)
Channel = Initialdata(ReadStart);
DAC_Code = 1:1:1024;
CountP0 = 1:1:1024;
CountP1 = 1:1:1024;
CountP2 = 1:1:1024;
CountT0 = 1:1:1024;
CountT1 = 1:1:1024;
CountT2 = 1:1:1024;
for i = 1:1:1024
    DAC_Code = Initialdata(ReadStart + 7*(i-1) + 1);
    CountP0(i) = Initialdata(ReadStart + 7*(i-1) + 2);
    CountT0(i) = Initialdata(ReadStart + 7*(i-1) + 3);
    CountP1(i) = Initialdata(ReadStart + 7*(i-1) + 4);
    CountT1(i) = Initialdata(ReadStart + 7*(i-1) + 5);
    CountP2(i) = Initialdata(ReadStart + 7*(i-1) + 6);
    CountT2(i) = Initialdata(ReadStart + 7*(i-1) + 7);
end