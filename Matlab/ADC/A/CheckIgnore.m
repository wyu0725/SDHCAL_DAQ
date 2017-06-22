function IgnoreOrNot = CheckIgnore( Channel,IgnoreData )
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
    for i = 1:1:length(IgnoreData)
        if(Channel == IgnoreData(i))
            IgnoreOrNot = 1;
            break;
        else
            IgnoreOrNot = 0;
        end
    end
end

