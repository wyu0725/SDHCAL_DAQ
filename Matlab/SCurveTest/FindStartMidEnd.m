function [Start, Middle, End] = FindStartMidEnd(Ratio, Len)
% Find the Start, Middle, End
Start = 0;
End = Len;
Middle = 0;
for i = 1:1:Len
    if(Ratio(i) == 0 && abs(Ratio(i + 1)) < 0.001 )
        Start = i;
    end   
end
for i = 1:1:Len
    if(Ratio(i) ~= 1 && abs(Ratio(i + 1) - 1) < 0.0001)
        End = i;
        break;        
    end
end
temp = 1;
for i = 1:1:Len
    if(abs(Ratio(i) - 0.5) < temp)
        temp = abs(Ratio(i) - 0.5);
        Middle = i;
    end
end