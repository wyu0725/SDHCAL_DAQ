function [MyGaussFunction,gof] = MyGaussFit(x,y)
    GaussFun = fittype('A*exp(-(x-mu)^2/(2*sigma^2))','dependent',{'y'},'independent',{'x'},'coefficients',{'A','mu','sigma'});
    
    [MyGaussFunction, gof] = fit(x,y,GaussFun,'Lower',[0 -Inf 0], 'Upper',[Inf Inf Inf],'StartPoint',[0 x(1) 0]);
    
end

