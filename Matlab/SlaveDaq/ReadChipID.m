function [ ChipID, DataPoint ] = ReadChipID( Data, DataPoint )
    %DataPoint 是当前读到第几个数据位置，从下一个开始读
    ChipID = 0;
    for i=1:4
        ChipID = ChipID + Data(i + DataPoint)*4^(4-i);
    end
    DataPoint = DataPoint + 4;
end

