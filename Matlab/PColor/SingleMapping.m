function [ NewData ] = SingleMapping( OldData, OldIndex, NewIndex )
%Mapping 此处显示有关此函数的摘要
% 将OldData的值通过映射关系OldIndex --> NewIndex映射到NewData
%   此处显示详细说明
%   即Pad和芯片管脚之间的映射
    if(length(OldData) ~= length(OldIndex) && length(OldIndex) ~= length(NewIndex))
        str = 'Length is not matched';
        dlg_title = 'File Open Faild';
        errordlg(str, dlg_title,'modal');
    end
    ChannelNumber = length(OldData);
    NewData = zeros(1,ChannelNumber);
    for i = 1:1:ChannelNumber
        NewData(NewIndex(i)) = OldData(OldIndex(i));
    end
end

