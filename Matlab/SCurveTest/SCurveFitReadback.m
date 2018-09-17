function [DacFitP,DacRsquare] = SCurveFitReadback(DacCode,TriggerRatio)
    DacRange = length(DacCode);
    [DacFit, Dacgof] = ErrorFunctionFit(DacCode', TriggerRatio', DacCode(1), DacCode(DacRange));
    DacFitP = [DacFit.a, DacFit.b, DacFit.c, DacFit.A];
    DacRsquare = Dacgof.rsquare;
end

