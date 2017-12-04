InitialData = Importdata();
SCAChannel = 1:1:512;
for i = 1:1:64
    [ Header, BoardNumber, TimeStamp, Channel, TrigID, DataOut, Tail ] = ReadSingleChannelData( InitialData, i+64 );
    figure;
    plot(SCAChannel,DataOut)
end