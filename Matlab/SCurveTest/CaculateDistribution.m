function [Mean, Rms] = CaculateDistribution(FitFunction, DacStart, DacEnd)
    x = DacStart:0.01:DacEnd;
    y = FitFunction(x);
    Distribution = diff(y);
    x0 = DacStart:0.01:DacEnd-0.01;
    Mean = x0*Distribution;
    Rms = sqrt((x0-Mean).*(x0-Mean)*Distribution);
end