function [Start, Middle, End] = FindStartMidEnd(Trig_Ratio, Percent)
% Find the Start, Middle, End
% Len = length(Trig_Ratio);
Len = 1024;
Start = 0;
End = Len;
Middle = 0;
for i = 1:1:Len - 1
    if(Trig_Ratio(i) == 0 && abs(Trig_Ratio(i + 1)) < 0.01 )
        Start = i;
    end   
end
for i = 1:1:Len - 1
    if(Trig_Ratio(i) ~= 100 && abs(Trig_Ratio(i + 1) - 100) < 0.01)
        End = i;
        break;        
    end
end
temp = 100;
x_i = Start:End;
y_i = Trig_Ratio(Start:End);
x_SI = Start:0.01:End;
y_SI = spline(x_i,y_i,x_SI);
n = (End - Start)/0.01 + 1;
for i = 1:1:n
    if(abs(y_SI))
end
% for i = 1:1:Len - 1
%     if(abs(Trig_Ratio(i) - Percent) < temp)
%         temp = abs(Trig_Ratio(i) - Percent);
%         Middle = i;
%     end
% end