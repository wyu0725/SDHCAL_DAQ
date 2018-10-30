function [Slope,Intercept,R] = CTestVoltageTest(DacCode,Voltage,AsicID)
    p0 = polyfit(DacCode,Voltage,1);
    Rp0 = corrcoef(DacCode,Voltage);
    x = linspace(min(DacCode),max(DacCode));
    y0 = polyval(p0,x);
    R = Rp0(2,1);
    Slope = p0(1);
    Intercept = p0(2);
    text0 = sprintf('DAC Output Slope: %1.4f mV / DAC Unit \n V(min) = %.6fmV,R: %1.4f',p0(1),p0(2),Rp0(2,1));
    figure;
    plot(DacCode,Voltage,'ok');
    hold on;
    plot(x,y0);
    hold off;
    legend(text0);
    txtTitle = sprintf('\\bf ASIC%s CTest Voltage(mV)',AsicID);
    xlabel('\bf DAC Code (DAC Unit)');
    ylabel('\bf Voltage (mV)');
    title(txtTitle)
    legend('Location','northwest');
    grid on;
end

