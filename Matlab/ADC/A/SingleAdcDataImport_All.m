Fnum = {'Input the DataFile number'};
FNumber = inputdlg(Fnum);
FNum = str2double(FNumber);
prompt = {'Input the average number'};
 DlgTitle = 'Input the acq parameter';
 answer = inputdlg(prompt,DlgTitle);
 AverageNumber = str2double(answer);
 Locs=zeros(1,FNum);
 L=zeros(1,FNum);
%  [IgnoreChannel, PathName] = GetIgnore();
 for k=1:1:FNum
     if(CheckIgnore(k,IgnoreChannel) == 1)
         continue;
     end
    [InitialData,FileName ]= ImportAdcDataAll(PathName ,'A',k);
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
    [~,Locs(k)] = FindSpectraPeaks(Adc,AdcCount,0);
    % figure;
%     windowSize = 10;
%     b = (1/windowSize)*ones(1,windowSize);
%     a = 1;
%     y=filter(b,a,AdcCount);
%     % plot(Adc,y);
%     for i=N:-1:1
%         if (y(i)>50)
%             T=i;
%             break;
%         end
%     end
%     [~,E]=max(y(1:250));
%     [~,H1]=max(y);
%     m1=(int32(T+H1)/2);
%     [~,H2]=max(y(m1:T));
%     H2=H2+m1;
%     [~,L1]=min(y(H1:H2));
%     L1=L1+H1;
%     m2=(int32(E+H1)/2);
%     [~,L3]=min(y(E:m2));
%     L3=L3+E;
%     m3=(int32(H1+L3)/2);
%     [~,L2]=min(y(m3:H1));
%     L2=L2+m3;
%     f = fit(Adc(L2:L1).',y(L2:L1).','gauss2');
% %     figure;
% %     plot(f,Adc(L2:L1),y(L2:L1));
%     [pks,locs] = findpeaks(f(Adc(L2:L1)));
%     locs=locs+L2;
%     Locs(k)=Adc(locs);
%     int32(pks);
%     Locs;
%     FAdc=f(Adc(L2:L1))/sum(f(Adc(L2:L1)));
%     FAdc=FAdc.';
%     Average=Adc(L2:L1)*FAdc';
%     S = std(Adc(L2:L1),FAdc);
%     L(k)=2.354*S;

 end
 C3DSumData = zeros(8,8);   
for i = 1:8
    for j = 1:8        
        C3DSumData(i,j) = Locs((i - 1)*8 + j);
    end
end
width = 1;
figure;
b = bar3(C3DSumData,width);
title('A');
colormap(flipud(parula))
colorbar;
for k = 1:length(b)
    zdata = b(k).ZData;
    b(k).CData = zdata;
    b(k).FaceColor = 'interp';
end