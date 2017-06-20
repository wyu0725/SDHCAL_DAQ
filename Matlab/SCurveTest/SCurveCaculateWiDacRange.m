function [ DacCode, DAC_Percent0, DAC_Percent1, DAC_Percent2 ] = SCurveCaculateWiDacRange( ImportData, Channel_Number, DacRange, FigureId )
%UNTITLED5 此处显示有关此函数的摘要
%   此处显示详细说明
    [~, DacCode, P0, T0, P1, T1, P2, T2] = ReadDataWiDacRange(ImportData, 2 + Channel_Number*(7*DacRange + 1), DacRange);
    Trig_Ratio0 = (T0./P0).*100 ;
    Trig_Ratio1 = (T1./P1).*100;
    Trig_Ratio2 = (T2./P2).*100;
    % DAC_Percent0 = trig_efficiency(DAC_Code,Trig_Ratio0,Percent);
    % DAC_Percent1 = trig_efficiency(DAC_Code,Trig_Ratio1,Percent);
    % DAC_Percent2 = trig_efficiency(DAC_Code,Trig_Ratio2,Percent);
    [~, DAC_Percent0, ~] = FindStartMidEndWiDacRange(Trig_Ratio0, 50, DacRange);
    [~, DAC_Percent1, ~] = FindStartMidEndWiDacRange(Trig_Ratio1, 50, DacRange);
    [~, DAC_Percent2, ~] = FindStartMidEndWiDacRange(Trig_Ratio2, 50, DacRange);
%     DAC_Percent0 = 0;
%     DAC_Percent1 = 0;
%     DAC_Percent2 = 0;
% DAC_Percent0 = 0;
% 
% DAC_Percent1 = 0;
% 
% DAC_Percent2 = 0;
    
    figure(1+FigureId)
    plot(Trig_Ratio0);
    hold on;
end

