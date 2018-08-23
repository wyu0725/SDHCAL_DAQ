function [MyErrorFunctionFit] = ErrorFunctionFit(x,y,bLower,bUpper)
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
    fitType = fittype('A*erf(a*(x-b))+c','dependent',{'y'},'independent',{'x'},'coefficients',{'a','b','c','A'});
    MyErrorFunctionFit = fit(x,y,fitType,'Lower',[-Inf bLower 0 0.3],'Upper',[Inf bUpper 1 0.6], 'StartPoint',[0.1 0.1 0.5 0.5]);
end

