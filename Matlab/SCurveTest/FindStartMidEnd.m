function [Start, Middle, End] = FindStartMidEnd(Trig_Ratio, Percent)
% Find the Start, Middle, End
% Len = length(Trig_Ratio);
Len = 1024;
Start = 0;
End = Len;
Middle = 0;
for i = 1:1:Len - 1
    if(Trig_Ratio(i) == 0 && abs(Trig_Ratio(i + 1)) < 0.1 )
        Start = i;
    end   
end
for i = 1:1:Len - 1
    if(Trig_Ratio(i) ~= 100 && abs(Trig_Ratio(i + 1) - 1) < 1)
        End = i;
        break;        
    end
end
temp = 100;
for i = 1:1:Len - 1
    if(abs(Trig_Ratio(i) - Percent) < temp)
        temp = abs(Trig_Ratio(i) - Percent);
        Middle = i;
    end
end