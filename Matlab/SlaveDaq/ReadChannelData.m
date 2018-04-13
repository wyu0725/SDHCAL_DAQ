function [ ChannelData, DataPoint ] = ReadChannelData( Data, DataPoint )
    ChannelData = zeros(64,1);
    for i = 0:3
        k = 3 -i;
        for j = 1:16
            ChannelData(16*k + j) = Data(j + i*16 + DataPoint);
        end
    end
    DataPoint = DataPoint + 64;
end

