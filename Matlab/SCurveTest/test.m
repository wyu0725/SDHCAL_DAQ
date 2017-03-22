x = 594:599;
%y = 1./(0.5+exp(-x));
y = Trig_Ratio0(x);
% myfittype = fittype('1/(a + b*exp(-(x - )))','dependent',{'y'},'independent',{'x'}, 'coefficients',{'a','b'});
% myfittype = fittype('a/(1 + b*exp(-c*x))','dependent',{'y'},'independent',{'x'}, 'coefficients',{'a','b','c'});
% myfit = fit(x',y',myfittype);
% plot(myfit,x,y);
% bar(diff(y));
[~,~,rref]=sigm_fit(x,y);
figure(2)
plot(diff(rref),'ko');