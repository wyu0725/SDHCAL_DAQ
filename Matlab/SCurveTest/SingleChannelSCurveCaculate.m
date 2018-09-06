function [DacCode, TriggerRatio0, TriggerRatio1, TriggerRatio2, Dac0FitP,Dac1FitP,Dac2FitP,Dac0Rsquare,Dac1Rsquare,Dac2Rsquare] = SingleChannelSCurveCaculate(InitialData, ChannelNumber, DacRange)
%UNTITLED5 此处显示有关此函数的摘要
%   此处显示详细说明
    [~, DacCode, P0, T0, P1, T1, P2, T2] = ReadDataWiDacRange(InitialData, 2 + ChannelNumber*(7*DacRange +1), DacRange);
    TriggerRatio0 = (T0./P0);
    TriggerRatio1 = (T1./P1);
    TriggerRatio2 = (T2./P2);
    [Dac0Fit, Dac0gof] = ErrorFunctionFit(DacCode', TriggerRatio0', DacCode(1), DacCode(DacRange));
    [Dac1Fit, Dac1gof] = ErrorFunctionFit(DacCode', TriggerRatio1', DacCode(1), DacCode(DacRange));
    [Dac2Fit, Dac2gof] = ErrorFunctionFit(DacCode', TriggerRatio2', DacCode(1), DacCode(DacRange));
    Dac0FitP = [Dac0Fit.a, Dac0Fit.b, Dac0Fit.c, Dac0Fit.A];
    Dac0Rsquare = Dac0gof.rsquare;
    Dac1FitP = [Dac1Fit.a, Dac1Fit.b, Dac1Fit.c, Dac1Fit.A];
    Dac1Rsquare = Dac1gof.rsquare;
    Dac2FitP = [Dac2Fit.a, Dac2Fit.b, Dac2Fit.c, Dac2Fit.A];
    Dac2Rsquare = Dac2gof.rsquare;
end

