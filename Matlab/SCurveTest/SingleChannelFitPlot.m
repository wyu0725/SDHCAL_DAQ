Dac0FitP = zeros(64,4);
Dac0FitR = zeros(64,1);
Dac1FitP = zeros(64,4);
Dac1FitR = zeros(64,1);
Dac2FitP = zeros(64,4);
Dac2FitR = zeros(64,1);

DacRange = 126;

InitialData = Importdata();

for i =1:1:64
    [DacCode, TriggerRatio0, TriggerRatio1, TriggerRatio2] = ...,
        SingleChannelSCurveReadback(InitialData, i - 1, DacRange);
    [Dac0FitP(i,:), Dac0FitR(i)] = SCurveFitReadback(DacCode, TriggerRatio0);
    [Dac1FitP(i,:), Dac1FitR(i)] = SCurveFitReadback(DacCode, TriggerRatio1);
    [Dac2FitP(i,:), Dac2FitR(i)] = SCurveFitReadback(DacCode, TriggerRatio2);
end
figure;
plot(Dac0FitP(:,2));
A = Dac0FitP(4);
        a = Dac0FitP(1);
        b = Dac0FitP(2);
        c = Dac0FitP(3);
        sigma = 1/(sqrt(2)*a);
        mu = b;
        ErrorFunction = @(x) A*(erf(a*(x-b))+c);
        GaussFunction = @(x) 1/(sqrt(2*pi))*exp(-(x-mu)^2/(2*sigma^2));
        figure;
        yyaxis left;
        plot(DacCode, TriggerRatio0,'*');
        hold on;
        fplot(ErrorFunction, [DacCode(1),DacCode(DacRange)]);
        hold off
        ylabel('\bf Trigger Efficiency');
        legend('Measure Data','Fit','Distribution')
        yyaxis right;
        fplot(GaussFunction, [DacCode(1),DacCode(DacRange)]);
        ylabel('\bf Distribution');
        xlabel('\bf DAC Code');
        titleString = sprintf('\\bf Channel%d Shaper 0, R = %5f', Channel, DacFitR);
        title(titleString);   