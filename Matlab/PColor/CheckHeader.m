function [Index] = CheckHeader(Header)
    switch Header
        case hex2dec('A1')
            Index = 1;
        case hex2dec('A2')
            Index = 2;
        case hex2dec('A3')
            Index = 3;
        case hex2dec('A4')
            Index = 4;
        case hex2dec('B1')
            Index = 5;
        case hex2dec('B2')
            Index = 6;
        case hex2dec('B3')
            Index = 7;
        case hex2dec('B4')
            Index = 8;
        case hex2dec('C1')
            Index = 9;
        case hex2dec('C2')
            Index = 10;
        case hex2dec('C3')
            Index = 11;
        case hex2dec('C4')
            Index = 12;
        case hex2dec('D1')
            Index = 13;
        case hex2dec('D2')
            Index = 14;
        case hex2dec('D3')
            Index = 15;
        case hex2dec('D4')
            Index = 16;
        otherwise
            Index = 0;
    end
end

