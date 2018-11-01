function [Slope,Intercept,R] = LinearFitBack(Xin,Yin)
    p0 = polyfit(Xin,Yin,1);
    Rp0 = corrcoef(Xin,Yin);
    R = Rp0(2,1);
    Slope = p0(1);
    Intercept = p0(2); 
end

