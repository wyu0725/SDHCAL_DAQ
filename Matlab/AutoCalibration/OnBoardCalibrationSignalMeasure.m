function [] = OnBoardCalibrationSignalMeasure(DacCode,DacOutput,DacBuffer,CaliBuffer,CaliSignal)
    p0 = polyfit(DacCode,DacOutput,1);
    Rp0 = corrcoef(DacCode,DacOutput);
    x = linspace(min(DacCode),max(DacCode));
    y0 = polyval(p0,x);
    text0 = sprintf('DAC Output Slope: %1.4f mV / DAC Unit \n V(min) = %.6fmV,R: %1.4f',p0(1),p0(2),Rp0(2,1));
    figure;
    plot(DacCode,DacOutput,'ok');
    hold on;
    plot(x,y0);
    hold on
    
    p1 = polyfit(DacCode,DacBuffer,1);
    Rp1 = corrcoef(DacCode,DacBuffer);
    x = linspace(min(DacCode),max(DacCode));
    y1 = polyval(p1,x);
    text1 = sprintf('DAC Buffer Slope: %1.4f mV / DAC Unit \n V(min) = %.6fmV,R: %1.4f',p1(1),p1(2),Rp1(2,1));
    plot(DacCode,DacBuffer,'*m');
    hold on;
    plot(x,y1);
    hold on
    
    p2 = polyfit(DacCode(1:11),CaliBuffer(1:11),1);
    Rp2 = corrcoef(DacCode(1:11),CaliBuffer(1:11));
    x = linspace(min(DacCode(1:11)),max(DacCode(1:11)));
    y2 = polyval(p2,x);
    text2 = sprintf('Cali Buffer Slope: %1.4f mV / DAC Unit \n V(min) = %.6fmV,R: %1.4f',p2(1),p2(2),Rp2(2,1));
    plot(DacCode,CaliBuffer,'+b');
    hold on;
    plot(x,y2);
    hold on
    
        p3 = polyfit(DacCode(1:11),CaliSignal(1:11),1);
    Rp3 = corrcoef(DacCode(1:11),CaliSignal(1:11));
    x = linspace(min(DacCode(1:11)),max(DacCode(1:11)));
    y3 = polyval(p3,x);
    text3 = sprintf('CaliSignal Slope: %1.4f mV / DAC Unit \n V(min) = %.6fmV,R: %1.4f',p3(1),p3(2),Rp3(2,1));
    plot(DacCode,CaliSignal,'xr');
    hold on;
    plot(x,y3);
    hold off
    grid on
    
    legend(text0,'Measurement DAC Out',text1,'Measurement DAC Buffer',text2,'Measurement Cali Buffer',text3,'Measurement Cali Signal');
    legend('Location','northwest')
    xlabel('\bf DAC Code');
    ylabel('\bf Voltage(V)')
end

