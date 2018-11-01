function [p0,R0] = ThresholdCalibrationLinearfit(Charge,DacCode)
    p0 = zeros(64,2);
    R0 = zeros(64,1);
    for i = 1:1:64
        p0(i,:) = polyfit(Charge,DacCode(i,:),1);
        Rp = corrcoef(Charge,DacCode(i,:));
        R0(i) = Rp(2,1);
    end
end

