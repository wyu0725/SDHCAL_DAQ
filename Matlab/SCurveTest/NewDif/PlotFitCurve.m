for i = 0:1:63
    [~, DacCode, P0, T0, P1, T1, P2, T2] = ReadDataWiDacRange(InitialData, 2 + i*(7*DacRange +1), DacRange);
    TriggerRatio0 = (T0./P0);
    [Dac0Fit, gof]= ErrorFunctionFit(DacCode', TriggerRatio0', DacCode(1), DacCode(DacRange));
    figure;
    titleString = sprintf('Channel%d,RSquare:%f',i,gof.rsquare);
    plot(Dac0Fit,DacCode,TriggerRatio0)
    title(titleString)
end