filepath = uigetdir('*.*','ÇëÑ¡ÔñÎÄ¼þ¼Ð');
prompt = {'Input Dac Range'};
dlg = 'Input data info';
answer = inputdlg(prompt,dlg);
DacRange = str2double(answer(1));
D0 = zeros(4,4,64,2);
D1 = zeros(4,4,64,2);
D2 = zeros(4,4,64,2);
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
            [~,~,~,~,D0(Column+1,Row+1,i+1,:),D1(Column+1,Row+1,i+1,:),D2(Column+1,Row+1,i+1,:)] = SingleChannelSCurveCaculate(InitialData,i,DacRange);
        end
    end
end

D00 = zeros(64,2);
D10 = zeros(64,2);
D20 = zeros(64,2);
for i = 1:1:4
    for j = 1:1:4
        for k = 1:1:64
            D00(k,:) = D0(i,j,k,:);
            D10(k,:) = D1(i,j,k,:);
            D20(k,:) = D2(i,j,k,:);
            
        end
        figure((i-1)*4+j)
        plot(D00(:,1));
        titleString = sprintf('\\bf ASIC%d%d DAC0',i,j);
        title(titleString);
        xlabel('\bf Channel');
        ylabel('\bf DAC(No Input)');
        figure((i-1)*4+j+16)
        plot(D10(:,1));
        titleString = sprintf('\\bf ASIC%d%d DAC1',i,j);
        title(titleString);
        xlabel('\bf Channel');
        ylabel('\bf DAC(No Input)');
        figure((i-1)*4+j+32)
        plot(D20(:,1));
        titleString = sprintf('\\bf ASIC%d%d DAC2',i,j);
        title(titleString);
        xlabel('\bf Channel');
        ylabel('\bf DAC(No Input)');
    end
end
D01 = zeros(64,1);
for i = 1:1:64
    D01(i) = D00(i,1)*D00(i,2);
    if(D01(i)<580)
        D01(i) = [];
    end
end