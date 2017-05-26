function [Header, BCID, DacCode, Chdata] = ReadPackage(InitialData, PackNumber, DacIndex)
% Read one pack
StartNum = PackNumber*80;
Header = 0;
for i=1:4
    Header = Header + InitialData(i + StartNum)*4^(4-i);
end
BCID = 0;
for i = 5:16
    BCID = BCID + InitialData(i + StartNum)*4^(16 - i);
end
Chdata = zeros(64,1);
for i = 0:3
    k = 3 -i;
    for j = 1:16
        Chdata(16*k + j) = InitialData(16 + j + i*16 + StartNum);
        %Ch_data(16*k + j) = bitand(InitialData(16 + j + i*16 + StartNum),1)*2  + bitand(InitialData(16 + j + i*16 + StartNum),2)/2;
    end
end
end