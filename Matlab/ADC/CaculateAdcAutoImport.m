function [ Average,Std,h] = CaculateAdcAutoImport(AverageNumber, HistNumber, Charge,AsicID,DataFolder)
%CaculateAdc AverageNumber是多少个点将ADC的数据平均一次 HistNumber是为调用hist
%   此处显示详细说明
    filename = sprintf('%s\\Adc_ASIC%s_%dfC.dat',DataFolder,AsicID,Charge);
    [fid,~] = fopen(filename,'r');
    if fid <= 0
        % There was an error--tell user
        str = ['File ' filename ' could not be opened.'];
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
    for i = 1:1:HitNumber
        SumAdcData = 0;
        for j = 1:1:AverageNumber
            DataIndex = (i - 1)*AverageNumber + j;
            SumAdcData = SumAdcData + InitialData(DataIndex);
        end
        AdcData(i) = SumAdcData / AverageNumber;
    end
    
    [AdcCount,Adc] = hist(AdcData,HistNumber);
    h = histogram(AdcData);
    hold on;
    FAdc = AdcCount/sum(AdcCount);
    Average = FAdc*Adc';
    Std = sqrt(FAdc*((Adc-Average).*(Adc-Average))');


end
