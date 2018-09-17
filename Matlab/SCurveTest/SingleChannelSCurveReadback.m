function [DacCode, TriggerRatio0, TriggerRatio1, TriggerRatio2] = SingleChannelSCurveReadback(InitialData, ChannelNumber, DacRange)
    [~, DacCode, P0, T0, P1, T1, P2, T2] = ReadDataWiDacRange(InitialData, 2 + ChannelNumber*(7*DacRange +1), DacRange);
    TriggerRatio0 = (T0./P0);
    TriggerRatio1 = (T1./P1);
    TriggerRatio2 = (T2./P2);
end

