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
            Dac0FitP(Column+1,Row+1,i+1,:),~,~,...,
                Dac0Rsquare(Column+1,Row+1,i+1,:),~,~] ...,
            = SingleChannelSCurveCaculate(InitialData,i,DacRange);
        end
    end
end

D00 = zeros(64,2);
D10 = zeros(64,2);
D20 = zeros(64,2);
MeanDac = zeros(64,1);
RmsDac = zeros(64,1);
RSquare = zeros(64,1);
for i = 1:1:4
    for j = 1:1:4
        for k = 1:1:64
            D00(k,:) = D0(i,j,k,:);
            D10(k,:) = D1(i,j,k,:);
            D20(k,:) = D2(i,j,k,:);
            MeanDac(k) = MeanDac0(i,j,k);
            RmsDac(k) = RmsDac0(i,j,k);
            RSquare(k) = Dac0FitRSquare(i,j,k);
        end
        figure;
        subplot(2,2,1);
        plot(D00(:,1),'*');
        hold on;
        plot(MeanDac,'o');
        hold off;
        titleString = sprintf('ASIC%d%d Pedestal',i,j);
        title(titleString);
        legend('50% Trigger Ratio','Mean');
        subplot(2,2,2);
        plot(RmsDac);
        titleString = sprintf('ASIC%d%d Rms',i,j);
        title(titleString);
        legend('RMS');
        subplot(2,2,3);
        plot(D00(:,2));
        titleString = sprintf('ASIC%d%d',i,j);
        title(titleString);
        legend('Data Valid');
        subplot(2,2,4);
        plot(RSquare);
        titleString = sprintf('ASIC%d%d RSquare',i,j);
        title(titleString);
        legend('RSquare');
    end
end