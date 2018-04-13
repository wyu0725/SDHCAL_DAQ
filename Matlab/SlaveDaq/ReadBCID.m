function [ BCID, DataPoint ] = ReadBCID( Data, DataPoint )
    %DataPoint 是当前读到第几个数据位置，从下一个开始读
    BCID = 0;
    for i = 1:12
        BCID = BCID + Data(i + DataPoint)*4^(12 - i);
    end
    DataPoint = DataPoint + 12;
end

