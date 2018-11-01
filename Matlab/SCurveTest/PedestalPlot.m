InitialData = Importdata();
DacRange = 126;
for Channel = 1:1:64
    figure;
    [DacCode, TriggerRatio0, TriggerRatio1, TriggerRatio2] = ...,
        SingleChannelSCurveReadback(InitialData, Channel - 1, DacRange);
    plot(DacCode, TriggerRatio0);
%     [DacFitP, DacFitR] = SCurveFitReadback(DacCode, TriggerRatio0);
%         A = DacFitP(4);
%         a = DacFitP(1);
%         b = DacFitP(2);
%         c = DacFitP(3);
%         ErrorFunction = @(x) A*(erf(a*(x-b))+c);
%     plot(DacCode, TriggerRatio0,'*');
%     hold on;
%     fplot(ErrorFunction, [DacCode(1),DacCode(DacRange)]);
%     hold off
    titleString = sprintf('Channel %d',Channel);
    title(titleString)
end

DacRange = 126;
figure;
for Channel = 1:1:64
    [DacCode, TriggerRatio0, TriggerRatio1, TriggerRatio2] = ...,
        SingleChannelSCurveReadback(InitialData, Channel - 1, DacRange);
    plot(DacCode, TriggerRatio0);
    hold on;
end