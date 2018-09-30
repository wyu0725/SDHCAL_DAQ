filepath = uigetdir('*.*','ÇëÑ¡ÔñÎÄ¼þ¼Ð');
prompt = {'Input Dac Range'};
dlg = 'Input data info';
answer = inputdlg(prompt,dlg);
DacRange = str2double(answer(1));
% D0 = zeros(4,4,64,2);
% D1 = zeros(4,4,64,2);
% D2 = zeros(4,4,64,2);
% MeanDac0 = zeros(4,4,64);
% RmsDac0 = zeros(4,4,64);
% Dac0FitRSquare = zeros(4,4,64);
Dac0FitP = zeros(4,4,64,4);
Dac1FitP = zeros(4,4,64,4);
Dac2FitP = zeros(4,4,64,4);
Dac0Rsquare = zeros(4,4,64);
Dac1Rsquare = zeros(4,4,64);
Dac2Rsquare = zeros(4,4,64);
for Column = 0:1:3
    for Row = 0:1:3
        filename = sprintf('%s\\ASIC%d%d.dat',filepath,Column,Row);
        [fid,~] = fopen(filename,'r');
        if fid <= 0
            % There was an error--tell user
            str = ['File ' filename ' could not be opened.'];
            dlg_title = 'File Open Faild';
            errordlg(str, dlg_title,'modal');
            break;
        else
            %File opend successfully
            InitialData = fread(fid,'uint16','ieee-be');%Big-endian ording
            %Size = length(importdata);
            fclose(fid);%close file
        end
        for i = 0:1:63
            [DacCode,~,~,~,...,
            Dac0FitP(Column+1,Row+1,i+1,:),Dac1FitP(Column+1,Row+1,i+1,:),Dac2FitP(Column+1,Row+1,i+1,:),...,
                Dac0Rsquare(Column+1,Row+1,i+1,:),Dac1Rsquare(Column+1,Row+1,i+1,:),Dac2Rsquare(Column+1,Row+1,i+1,:)] ...,
            = SingleChannelSCurveCaculate(InitialData,i,DacRange);
        end
    end
end

Dac0FitPSingle = zeros(64,4);
muChannel = zeros(4,4,64);
sigmaChannel = zeros(4,4,64);
ChannelAdjust = zeros(4,4,64,1);
SlopeDac0 = zeros(4,4);
SlopeDac0(1,2) = 2.1487;
SlopeDac0(1,3) = 2.1852;
muPlot = zeros(1,64);
sigmaPlot = zeros(1,64);
for i = 1:1:4
    for j = 1:1:4
        for k = 1:1:64
            Dac0FitPSingle(k,:) = Dac0FitP(i,j,k,:);
            a = Dac0FitPSingle(k,1);
            b = Dac0FitPSingle(k,2);
            c = Dac0FitPSingle(k,3);
            A = Dac0FitPSingle(k,4);
            muChannel(i,j,k) = b;
            muPlot(k) = b;
            sigmaChannel(i,j,k) = 1/(sqrt(2)*a);
            sigmaPlot(k) = 1/(sqrt(2)*a);
%             mu = b;
%             sigma = 1/(sqrt(2)*a);
%             FErrorFunction = @(x) A*(erf(a*(x-b))+c);
%             FGaussFunction = @(x) (1/(sigma*sqrt(2)*pi))*exp(-(x-mu).^2/2/sigma^2);
%             figure;
%             yyaxis left;
%             fplot(FErrorFunction,[500 625])
%             yyaxis right
%             fplot(FGaussFunction,[500 625])
%             titleString = sprintf('Channel%d',k);
%             title(titleString);
        end
        figure;
        yyaxis left;
        plot(muPlot);
        ylabel('\bf DAC Code');
        yyaxis right
        plot(sigmaPlot);
        ylabel('\bf DAC Code');
        xlabel('\bf Channel');
        titleString = sprintf('\\bf ASIC%d%d',i,j);
        title(titleString);
        legend('mu','sigma');
%         MaxMu = max(muChannel(i,j,:));
%         for k = 1:1:64
%             Adjustment = MaxMu - muChannel(i,j,k);
%             AdjustmentVoltage = Adjustment*2.1852;
%             ChannelAdjust(i,j,k) = AdjustmentVoltage / 0.728;
%         end
    end
end
for i = 1:1:4
    figure;
    for j = 1:1:4
        for k = 1:1:64
            Dac0FitPSingle(k,:) = Dac0FitP(i,j,k,:);
            a = Dac0FitPSingle(k,1);
            b = Dac0FitPSingle(k,2);
            c = Dac0FitPSingle(k,3);
            A = Dac0FitPSingle(k,4);
            muChannel(i,j,k) = b;
            muPlot(k) = b;
            sigmaChannel(i,j,k) = 1/(sqrt(2)*a);
            sigmaPlot(k) = 1/(sqrt(2)*a);
        end
        subplot(2,2,j)
        plot(muPlot);
        ylabel('\bf DAC Code');
        xlabel('\bf Channel');
        titleString = sprintf('\\bf ASIC%d%d',i,j);
        title(titleString);
        legend('mu','Location','southeast');
    end
end
RPlot = zeros(1,64);
for i = 1:1:4
    figure;
    for j = 1:1:4
        for k = 1:1:64
            RPlot(k) = Dac0Rsquare(i,j,k);
        end
        subplot(2,2,j)
        plot(RPlot);
        ylabel('\bf R');
        xlabel('\bf Channel');
        titleString = sprintf('\\bf ASIC%d%d',i,j);
        title(titleString);
        legend('R','Location','southeast');
    end
end