minV = 0.8;
maxV = 3.0;
% Code = [0,127,255,383,511,693,767,895,1023];
% Vth0 = [0.8270,1.0995,1.3776,1.6670,1.9471,2.2253,2.4985,2.7355,2.7475];
% Vth1 = [0.8229,1.0931,1.3678,1.6441,1.9189,2.1919,2.4607,2.7199,2.7420];
% Vth2 = [0.8270,1.0995,1.3776,1.6533,1.9315,2.2039,2.4762,2.7365,2.7668];
Code = [0,127,255,383,511,639,767,895];
Vth0 = [0.8270,1.0995,1.3776,1.6670,1.9471,2.2253,2.4985,2.7355];
Vth1 = [0.8229,1.0931,1.3678,1.6441,1.9189,2.1919,2.4607,2.7199];
Vth2 = [0.8270,1.0995,1.3776,1.6533,1.9315,2.2039,2.4762,2.7365];

%%%%PolyFit
Rp0 = corrcoef(Code,Vth0);
Rp1 = corrcoef(Code,Vth1);
Rp2 = corrcoef(Code,Vth2);
R0 = Rp0(2,1);
R1 = Rp1(2,1);
R2 = Rp2(2,1);
x = linspace(min(Code),max(Code));
p0 = polyfit(Code,Vth0,1);
y0 = polyval(p0,x);
p1 = polyfit(Code,Vth1,1);
y1 = polyval(p1,x);
p2 = polyfit(Code,Vth2,1);
y2 = polyval(p2,x);
xText = 500;
yText = 1.2;
str0 = sprintf('Vth_0 vs Code\n--The Linear correlation coefficient is %1.6f',R0);
str1 = sprintf('Vth_1 vs Code\n--The Linear correlation coefficient is %1.6f',R1);
str2 = sprintf('Vth_2 vs Code\n--The Linear correlation coefficient is %1.6f',R2);

text0 = sprintf('Slope: %1.6f mV / DAC Unit \n Vth(min) = %.6fV',p0(1)*1000,p0(2));
text1 = sprintf('Slope: %1.6f mV / DAC Unit \n Vth(min) = %.6fV',p1(1)*1000,p1(2));
text2 = sprintf('Slope: %1.6f mV / DAC Unit \n Vth(min) = %.6fV',p2(1)*1000,p2(2));

figure;
plot(Code,Vth0,'ok');
hold on;
plot(x,y0);
text('String',text0,'Position',[xText,yText]);
h0 = legend(str0);
set(h0,'Location','northwest');

figure;
plot(Code,Vth1,'*k');
hold on;
plot(x,y1);
text('String',text1,'Position',[xText,yText]);
h1 = legend(str1);
set(h1,'Location','northwest')

figure;
plot(Code,Vth2,'xk');
hold on;
plot(x,y2);
text('String',text2,'Position',[xText,yText]);
h2 = legend(str2);
set(h2,'Location','northwest')