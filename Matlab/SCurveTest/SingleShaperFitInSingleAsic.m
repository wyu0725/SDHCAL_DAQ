function [FitSlope,FitIntercept,FitR] = SingleShaperFitInSingleAsic(Charge,DacCode)
    if(length(DacCode) ~= 64)
        return
    end
    FitSlope = zeros(1,64);
    FitIntercept = zeros(1,64);
    FitR = zeros(1,64);
    for i = 1:1:64
        [FitSlope(i), FitIntercept(i),FitR(i)] = LinearFit(Charge',DacCode(i,:)');
%         figure;
%         plot(Charge,DacCode(i,:))
    end
end

