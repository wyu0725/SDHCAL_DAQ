clear
clc
%Fnum = {'Input the DataFile number'};
%FNumber = inputdlg(Fnum);%64
%FNum = str2double(FNumber);
%prompt = {'Input the average number'};
% DlgTitle = 'Input the acq parameter';
% answer = inputdlg(prompt,DlgTitle);
% AverageNumber = str2double(answer);
FNum=64;
AverageNumber=32;
Locs=zeros(1,FNum);
 L=zeros(1,FNum);
 %IgnoreChannel = GetIgnore();
 File_str =['A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'J' 'K' 'L' 'M' 'N' 'P'];
% File_str =['A'];
 Ca_str = '.dat';
 FCounts=0;
 
 for n=1:1:14
  for k=1:1:FNum
   % for k=1:1:1
     name  = [File_str(n),num2str(k)];
     name2  = [File_str(n),num2str(k),Ca_str] ;
     %name = ['A',num2str(k),Ca_str] ;
     s=cd;
     filename=fullfile('K:\dhcal\A',File_str(n),name2);
      % filename=fullfile('K:\dhcal\A','A',name);
     [fid,~] = fopen(filename,'r');
     if fid < 0  
        continue;
     else
        InitialData = fread(fid,'ubit16','ieee-be');
        fclose(fid);
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
    AdcData = 2.145996 -  AdcData*5/4096;%amplitude  AdcData
    for i = 1:1:HitNumber
        if (AdcData(i) < 0.15)  
        AdcData(i)=0;
        end  
    end
   [AdcCount,Adc] = hist(AdcData,N);  % counts    amplitude 
    % figure;
    windowSize = 10;
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    y=filter(b,a,AdcCount);
    % plot(Adc,y);
    for i=N:-1:1
        if (y(i)>30)
        T=i;break;
        end
    end
    [pvalue,H2]=max(y(100:T));%pvalue return max value of y.H2 return the location of ymax.
    while(H2==[])
        continue;
    end
    if(H2>0 &  pvalue>200)
        FCounts=FCounts+1;
    H2=H2+100;    %location of ymax
    H1=int32(5*H2/8); %location of first peak
    [~,L1]=min(y(H1:H2)); % location of the first valley
    if(H2-(L1+H1)<80)
        L1=H1+L1;
    else
        L1=H2-50;
    end
    L3=2*H2-L1; 
    [~,L2]=min(y(H2:L3));
    L2=H2+L2;
    
    f = fit(Adc(L1:L2).',y(L1:L2).','gauss2');
    figure; 
  %  xlim([0.15, 1.2])
    xlabel('Amplitude(V)');
    ylabel('Counts');
    plot(f,Adc(L1:L2),y(L1:L2));
    title(name2);
 %   xlim([0.2 1.2]);
    saveas(gcf,['K:\dhcal\A\picture\',name,'.jpg']);
    %may use command 'set' to set properties of axis 
   
   % [pks,locs] = findpeaks(f(Adc(L1:L2)));%pks return the peak value of adc.And the locs return the location of peak
   [pks,locs] = max(f(Adc(L1:L2))); 
   locs;
   locs=locs+L1;
   Lpeak=Adc(locs)
    else
        Lpeak=0;
    fid2=fopen('K:\dhcal\A\wrong.txt','a+');
    fprintf(fid2,'%s%d\n',File_str(n),k); 
    fclose(fid2);
   end 
   
    fid1=fopen('K:\dhcal\A\1.txt','a+');
    %fprintf(fid1,'%s%d %d %d\n',File_str(n),k,locs,Lpeak); 
    fprintf(fid1,'%s%d  %d\n',File_str(n),k,Lpeak); 
    fclose(fid1);
  %  int32(pks);
   %FAdc=f(Adc(L1:L2))/sum(f(Adc(L1:L2)));
    %FAdc=FAdc.';
    %Average=Adc(L1:L2)*FAdc';
  %  S = std(Adc(L1:L2),FAdc);
    %L(k)=2.354*S;
   % fclose(fid);
   
    [File_str(n),num2str(k)] 
  
  % H2
    end
  end
 %filename

 end
FCounts 
 %C3DSumData = zeros(8,8);   
%for i = 1:8
  %  for j = 1:8        
  %      C3DSumData(i,j) = Locs((i - 1)*8 + j);
 %   end
%end
%width = 1;
%figure;
%b = bar3(C3DSumData,width);
%title('A');
%colormap(flipud(parula))
%colorbar;
%for k = 1:length(b)
%    zdata = b(k).ZData;
%    b(k).CData = zdata;
%    b(k).FaceColor = 'interp';
%end