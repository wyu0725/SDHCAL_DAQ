function [DacCode, TriggerRatio0, TriggerRatio1, TriggerRatio2, Dac0Value, Dac1Value, Dac2Value] = SingleChannelSCurveCaculate(InitialData, ChannelNumber, DacRange)
%UNTITLED5 此处显示有关此函数的摘要
%   此处显示详细说明
    [~, DacCode, P0, T0, P1, T1, P2, T2] = ReadDataWiDacRange(InitialData, 2 + ChannelNumber*(7*DacRange +1), DacRange);
    TriggerRatio0 = (T0./P0);
    TriggerRatio1 = (T1./P1);
    TriggerRatio2 = (T2./P2);
    Dac0Fit = ErrorFunctionFit(DacCode', TriggerRatio0', DacCode(1), DacCode(DacRange));
    Dac1Fit = ErrorFunctionFit(DacCode', TriggerRatio1', DacCode(1), DacCode(DacRange));
    Dac2Fit = ErrorFunctionFit(DacCode', TriggerRatio2', DacCode(1), DacCode(DacRange));
    Dac0Value = zeros(2,1);
    Dac1Value = zeros(2,1);
    Dac2Value = zeros(2,1);
    [Dac0Value(1),Dac0Value(2)] = Find50PercentDacValue(Dac0Fit,DacCode(1),DacCode(DacRange));
    [Dac1Value(1),Dac1Value(2)] = Find50PercentDacValue(Dac1Fit,DacCode(1),DacCode(DacRange));
    [Dac2Value(1),Dac2Value(2)] = Find50PercentDacValue(Dac2Fit,DacCode(1),DacCode(DacRange));
end

