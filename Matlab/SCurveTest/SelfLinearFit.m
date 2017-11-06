function [ R, p, x0, y0 ] = SelfLinearFit( x, y )
% 自己写的线性拟合的函数
% 输入x,y输出拟合系数R,拟合参数p，以及用于作图的x0和y0
    R = corrcoef(x, y);
    p = polyfit(x, y, 1);
    x0 = linspace(min(x), max(x));
    y0 = polyval(p, x0);
end

