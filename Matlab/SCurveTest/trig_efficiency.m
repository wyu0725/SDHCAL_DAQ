function [ DAC_percent ] = trig_efficiency( DAC_value,trig_data,percent)
%TRIG_EFFICIENCY 此处显示有关此函数的摘要
%   此处显示详细说明
% DAC_value为DAC码值
% trig_data为统计触发率的值
% percent为求百分之几的触发率，目前percent值设为50
    
    if size(DAC_value) ~= size(trig_data)
        % There was an error--tell user
        str = 'the size of DAC value and trigger data should be the same';
        dlg_title = 'data error';
        errordlg(str, dlg_title,'modal');
    else
        %由之前的实验得出找4个点，做3次项拟合比较好
        len = length(DAC_value);
        for i=1:len-1
            if(trig_data(i) <= percent && trig_data(i+1)>= percent)
                pos = i;
            end
        end
        x = DAC_value(pos-1:pos+2); %对应DAC value的值
        y = trig_data(pos-1:pos+2); %对应触发率的值
        [p,~,mu] = polyfit(y,x,3); %以触发率为自变量，DAC码为变量描绘曲线
        DAC_percent = polyval(p,percent,[],mu);
    end
end

