function [FitSlope,FitIntercept,R]=LinearFit(x,y)
    [f,gof]=fit(x,y,'poly1');
     FitSlope = f.p1;
     FitIntercept = f.p2;
     R=gof.rsquare;
end


