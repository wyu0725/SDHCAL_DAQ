function [Start, Middle, End] = FindStartMidEnd(Ratio, Len)
% Find the Start, Middle, End
Start = 0;
End = 0;
Middle = 0;
for i = 1:1:Len
    if(Ratio(i) == 0 && abs(Ratio(i + 1)) < 0.001 )
        Start = i;
    end
    if(Ratio(i) ~= 1 && abs(Ratio(i + 1) - 1) < 0.001)
        End = i;
    end
    if(abs(Ratio(i) - 0.5) < 0.01)
        Middle = i;
    end
end