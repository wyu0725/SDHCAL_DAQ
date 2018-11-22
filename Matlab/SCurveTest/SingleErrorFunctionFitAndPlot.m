function [] = SingleErrorFunctionFitAndPlot()
    InitialData = Importdata();
    prompt = {'Input DAC Range', 'Input Channel','Input Shaper Index'};
    dlg = 'Input data info';
    answer = inputdlg(prompt,dlg);
    DacRange = str2double(answer(1));
    Channel = str2double(answer(2));
    Shaper = str2double(answer(3));
    
    [DacCode, TriggerRatio0, TriggerRatio1, TriggerRatio2] = ...,
        SingleChannelSCurveReadback(InitialData, Channel - 1, DacRange);
    
    if(bitand(Shaper,1) == 1)
        [DacFitP, DacFitR] = SCurveFitReadback(DacCode, TriggerRatio0);
        A = DacFitP(4);
        a = DacFitP(1);
        b = DacFitP(2);
        c = DacFitP(3);
        sigma = 1/(sqrt(2)*a);
        mu = b;
        ErrorFunction = @(x) A*(erf(a*(x-b))+c);
        GaussFunction = @(x) 1/(sqrt(2*pi))*exp(-(x-mu).^2/(2*sigma.^2));
        figure;
        yyaxis left;
        plot(DacCode, TriggerRatio0,'*');
        hold on;
        fplot(ErrorFunction, [DacCode(1),DacCode(DacRange)]);
        hold off
        ylabel('\bf Trigger Efficiency');
        
        yyaxis right;
        fplot(GaussFunction, [DacCode(1),DacCode(DacRange)]);
        ylabel('\bf Distribution');
        xlabel('\bf DAC Code');
        legend('Measure Data','Fit','Distribution')
        titleString = sprintf('\\bf Channel%d Shaper 0,\\mu = %f,\\sigma = %f, R = %5f', Channel, mu, sigma, DacFitR);
        title(titleString,'Interpreter','tex');        
    end
    
    if(bitand(Shaper,2) == 2)
        [DacFitP, DacFitR] = SCurveFitReadback(DacCode, TriggerRatio1);       
        A = DacFitP(4);
        a = DacFitP(1);
        b = DacFitP(2);
        c = DacFitP(3);
        sigma = 1/(sqrt(2)*a);
        mu = b;
        ErrorFunction = @(x) A*(erf(a*(x-b))+c);
        GaussFunction = @(x) 1/(sqrt(2*pi))*exp(-(x-mu).^2/(2*sigma^2));
        figure;
        yyaxis left;
        plot(DacCode, TriggerRatio1,'*');
        hold on;
        fplot(ErrorFunction, [DacCode(1),DacCode(DacRange)]);
        hold off
        ylabel('\bf Trigger Efficiency');
        yyaxis right;
        fplot(GaussFunction, [DacCode(1),DacCode(DacRange)]);
        ylabel('\bf Distribution');
        xlabel('\bf DAC Code');
        legend('Measure Data','Fit','Distribution')
        titleString = sprintf('\\bf Channel%d Shaper 1,\\mu = %f,\\sigma = %f, R = %5f', Channel, mu, sigma, DacFitR);
        title(titleString);        
    end
    
    if(bitand(Shaper,4) == 4)
        [DacFitP, DacFitR] = SCurveFitReadback(DacCode, TriggerRatio2);       
        A = DacFitP(4);
        a = DacFitP(1);
        b = DacFitP(2);
        c = DacFitP(3);
        sigma = 1/(sqrt(2)*a);
        mu = b;
        ErrorFunction = @(x) A*(erf(a*(x-b))+c);
        GaussFunction = @(x) 1/(sqrt(2*pi))*exp(-(x-mu).^2/(2*sigma^2));
        figure;
        yyaxis left;
        plot(DacCode, TriggerRatio2,'*');
        hold on;
        fplot(ErrorFunction, [DacCode(1),DacCode(DacRange)]);
        hold off
        ylabel('\bf Trigger Efficiency');
        yyaxis right;
        fplot(GaussFunction, [DacCode(1),DacCode(DacRange)]);
        ylabel('\bf Distribution');
        xlabel('\bf DAC Code');
        legend('Measure Data','Fit','Distribution')
        titleString = sprintf('\\bf Channel%d Shaper 2,\\mu = %f,\\sigma = %f, R = %5f', Channel, mu, sigma, DacFitR);
        title(titleString);        
    end
end

