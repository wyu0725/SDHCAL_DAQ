Peak = zeros(32,1);
for FileIn = 1:1:32
    InitialData = ImportData();
%     prompt = {'Input the average number'};
%      DlgTitle = 'Input the acq parameter';
%     answer = inputdlg(prompt,DlgTitle);
% 
%     AverageNumber = str2double(answer(1));
    AverageNumber = 32;
    % Charge = str2double(answer(2));
    HitNumber = floor(length(InitialData)/AverageNumber);
    % Charge = str2double(answer(3));

    AdcData = zeros(HitNumber,1);
    for i = 1:1:HitNumber
        SumAdcData = 0;
        for j = 1:1:AverageNumber
            DataIndex = (i - 1)*AverageNumber + j;
            SumAdcData = SumAdcData + InitialData(DataIndex);
        end
        AdcData(i) = SumAdcData / AverageNumber;
    end
    AdcData = AdcData*5/4095;
    [AdcCount,Adc] = hist(AdcData,2000);
    figure;
    windowSize = 10;
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    y=filter(b,a,AdcCount);
    plot(Adc,y);
    for i=1:1:2000
        if (y(i)>50)
        T=i;break;end
    end
    [~,E]=max(y(1500:2000));
    E=E+1500;
    [~,H1]=max(y);
    m1=(int32(T+H1)/2);
    [~,H2]=max(y(T:m1));
    H2=H2+T;
    [~,L1]=min(y(H2:H1));
    L1=L1+H2;
    m2=(int32(E+H1)/2);
    [~,L3]=min(y(m2:E));
    L3=L3+m2;
    m3=(int32(H1+L3)/2);
    [~,L2]=min(y(H1:m3));
    L2=L2+H1;
    f1 = fit(Adc(T:L1).',y(T:L1).','gauss2');
    figure;
    plot(f1,Adc(T:L1),y(T:L1));
    f2 = fit(Adc(L1:L2).',y(L1:L2).','gauss2');
    figure;
    plot(f2,Adc(L1:L2),y(L1:L2));
    f3 = fit(Adc(L2:L3).',y(L2:L3).','gauss5');
    figure;
    plot(f3,Adc(L2:L3),y(L2:L3));
    [pks,locs,l,s] = findpeaks(f2(Adc(L1:L2)));
    locs=locs+L1;
    Locs=Adc(locs);
    int32(pks);
    Peak(FileIn) = 2.145996 - Locs;
end
% FAdc = AdcCount/sum(AdcCount);
% Average = FAdc*Adc';
% Std = sqrt(FAdc*((Adc-Average).*(Adc-Average))');