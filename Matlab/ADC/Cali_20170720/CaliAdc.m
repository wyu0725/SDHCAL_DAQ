AverageNumber = 32;
AmpVoltage = 5:5:50;
ChargeInput = AmpVoltage * 8.2;
Peak = zeros(1,10);
for i = 1:1:10
    FileName = [num2str(ChargeInput(i)) 'fC' '.dat'];
    [fid,~] = fopen(FileName,'r');
    if fid <= 0
        % There was an error--tell user
        str = ['File ' FileName ' could not be opened.'];
        dlg_title = 'File Open Faild';
        errordlg(str, dlg_title,'modal');
    else
        %File opend successfully
        InitialData = fread(fid,'ubit16','ieee-be');%Big-endian ording
        %Size = length(importdata);
        fclose(fid);%close file
    end   
    HitNumber = floor(length(InitialData)/AverageNumber);
    AdcData = zeros(HitNumber,1);
    for k = 1:1:HitNumber
        SumAdcData = 0;
        for j = 1:1:AverageNumber
            DataIndex = (k - 1)*AverageNumber + j;
            SumAdcData = SumAdcData + InitialData(DataIndex);
        end
        AdcData(k) = SumAdcData / AverageNumber;
    end
    % AdcData = (1.758137790851369e+03 - AdcData)*5/4095;
    a1 = min(AdcData);
    a2 = max(AdcData);
    N = round(a2 - a1) + 1;
    AdcData = 2.145996 -  AdcData*5/4096;
    [AdcCount,Adc] = hist(AdcData,N);
    figure;
    hist(AdcData,N);
    [Peak(i), ~] = GetAdcCaliPeak(Adc,AdcCount);
end
pAdc = polyfit(Peak,ChargeInput,1);
x = linspace(min(Peak),max(Peak));
y = polyval(pAdc,x);
figure
plot(Peak,ChargeInput,'b*');
hold on;
plot(x,y,'r');
textString = sprintf('Charge = %3.4f * Peak + %1.4f',pAdc(1),pAdc(2));
text('Position',[0.2 350],'String',textString);
hold off;