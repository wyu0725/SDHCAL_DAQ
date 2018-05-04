function [ y, x ] = FermiDiracFit( Vth, TriggerRatio )
%FermiDiracFit 使用Fermi-Dirac分布函数来拟合S曲线数据
%   y = \frac{1}{e^{\frac{x-\mu}{kT}} + 1}
    ft = fittpye('1/(exp((x-u)/m) + 1)','independent','x');
    [Curve, gof] = fit(Vth, TriggerRatio,ft);

end

