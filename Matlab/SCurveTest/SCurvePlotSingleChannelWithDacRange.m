function [] = SCurvePlotSingleChannelWithDacRange(InitialData, ChannelNumber, DacRange, FigureNumber)
    [~, DacCode, P0, T0, P1, T1, P2, T2] = ReadDataWiDacRange(InitialData, 2 + ChannelNumber*(7*DacRange +1), DacRange);
    TriggerRatio0 = (T0./P0).*100 ;
    TriggerRatio1 = (T1./P1).*100;
    TriggerRatio2 = (T2./P2).*100;
%     [~, DAC_Percent0, ~] = FindStartMidEndWiDacRange(TriggerRatio0, 50, DacRange);
%     [~, DAC_Percent1, ~] = FindStartMidEndWiDacRange(TriggerRatio1, 50, DacRange);
%     [~, DAC_Percent2, ~] = FindStartMidEndWiDacRange(TriggerRatio2, 50, DacRange);
    figure(1+FigureNumber)
    plot(DacCode,TriggerRatio0);
    hold on;
    plot(DacCode, TriggerRatio1);
    hold on;
    plot(DacCode, TriggerRatio2);
    legend('Dac0','Dac1','Dac2');
    
end

