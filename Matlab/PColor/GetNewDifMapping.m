function [Row, Column, AsicID, Channel] = GetNewDifMapping()
        filename = 'D:\MyProject\SDHCAL_DAQ\Matlab\PColor\PadMappingFEB.txt';
        delimiterIn = ' ';
        headerlinesIn = 1;
        A = importdata(filename, delimiterIn, headerlinesIn);
        Row = A(:,1);
        Column = A(:,2);
        AsicID = A(:,3);
        Channel = A(:,4);
end

