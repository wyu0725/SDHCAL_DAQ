filepath = uigetdir('*.*','ÇëÑ¡ÔñÎÄ¼þ¼Ð');
prompt = {'Input Dac Range', 'Input Channel', 'Input Shaper Index'};
dlg = 'Input data info';
answer = inputdlg(prompt,dlg);
DacRange = str2double(answer(1));
Channel = str2double(answer(2));
Shaper = str2double(answer(3));
for Column = 1:1:4
    for Row = 1:1:4
        filename = sprintf('%s\\ASIC%d%d.dat',filepath,Column,Row);
        [fid,~] = fopen(filename,'r');
        if fid <= 0
            % There was an error--tell user
            str = ['File ' filename ' could not be opened.'];
            dlg_title = 'File Open Faild';
            errordlg(str, dlg_title,'modal');
            continue;
        else
            %File opend successfully
            InitialData = fread(fid,'uint16','ieee-be');%Big-endian ording
            %Size = length(importdata);
            fclose(fid);%close file
        end
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
            titleString = sprintf('\\bf ASIC%d%d Channel%d Shaper 0,\\mu = %f,\\sigma = %f, R = %5f', Column, Row, Channel, mu, sigma, DacFitR);
            title(titleString,'Interpreter','tex');
        end
    end
end