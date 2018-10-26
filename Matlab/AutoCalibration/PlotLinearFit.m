function [] = PlotLinearFit(Dac,Value,Parameter)
    p0 = polyfit(Dac,Value,1);
    x = linspace(min(Dac),max(Dac));
    y0 = polyval(p0,x);
%     figure;
    plot(Dac,Value,Parameter(1));
    hold on;
    plot(x,y0,Parameter(2));
%     grid on;
%     hold off;
end

