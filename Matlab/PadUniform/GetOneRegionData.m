function [ RegionData ] = GetOneRegionData( AverageNumber )
% GetOneRegionData
% This function is used to get the spectra peak and return to RegionData[64]
% In this function will use ImportAdcDataAll to get the ADC data and then
% change it into spectra data. Then the FindSpectraPeasks function will
% return the peak information. 
% This function needs assign the ignored pad and the aera index manually
    RegionData = zeros(64,1);
    prompt = 'Please input the aera index and select the ignore file';
    dlgTitle = 'Input aera';
    answer = inputdlg(prompt,dlgTitle);
    AreaIndex = strjoin(answer(1));
    [IgnoreChannel,PathName] = GetIgnore();
    for k=1:1:64
         if(CheckIgnore(k,IgnoreChannel) == 1)
             continue;
         end
        [InitialData,~ ]= ImportAdcDataAll(PathName ,AreaIndex,k);
        % Charge = str2double(answer(2));
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
        % AdcData = (1.758137790851369e+03 - AdcData)*5/4095;
        a1 = min(AdcData);
        a2 = max(AdcData);
        N = round(a2 - a1) + 1;
        AdcData = 2.145996 -  AdcData*5/4096;
        [AdcCount,Adc] = hist(AdcData,N);
        [~,RegionData(k)] = FindSpectraPeaks(Adc,AdcCount,0);
     end


end

