%% Pesudocolor Plot of 8*8 Square
% Read data from *.dat, and plot as hitmap

%--- Open file and Import data ---%
InitialData = ImportData();
% Read one pack
prompt = {'Which package would you want to display start from','How many package would you like to display'};
dlg_title = 'Input the package number';
answer = inputdlg(prompt,dlg_title);
PackNo = str2double(answer(1));
DisplayNo = str2double(answer(2));
% Get Mapping Function
[ASIC_Channel, Pad_Channel] = GetMapping();

ChannelDataTemp = zeros(64,1);
for i = 1:DisplayNo
    [~, ~, Ch_data] = ReadPackage(InitialData, PackNo + i - 1);
    ChannelDataTemp = ChannelDataTemp + Ch_data;
end
[MaxNumber,FiredChannel] = max(ChannelDataTemp);
%FiredChannel=FiredChannelt-1;
SumData = zeros(64,1);
Sum_t = zeros(64,1);
NotHitted = zeros(64,1);
GreatThan1 = zeros(64,1);
GreatThan2 = zeros(64,1);
GreatThan3 = zeros(64,1);
FiredCount = 0;
t_count=0;
t1=0;t2=0;t3=0;
%f1=0;f2=0;f3=0;
f_count=0;
t11=zeros(DisplayNo,1);t12=zeros(DisplayNo,1);t13=zeros(DisplayNo,1);

for DisplayK = 1:DisplayNo
    [header, BCID, Ch_data] = ReadPackage(InitialData, PackNo + DisplayK - 1);
%     if(header ~= hex2dec('A0'))
%         continue;
%     end
%     NewChannelData = SingleMapping(Ch_data, ASIC_Channel, Pad_Channel);
   if(max(Ch_data) == Ch_data(FiredChannel) && Ch_data(FiredChannel) == 3) 
   %  if(max(Ch_data) == Ch_data(FiredChannel)) 
      for k = 1:1:64
        % if(k==FiredChannel) continue;
        if (  k==FiredChannel+1 || k==FiredChannel-8 || k==FiredChannel-1 || k==FiredChannel-7 || k==FiredChannel-9 ||  k==FiredChannel+7 || k==FiredChannel+9 || k==FiredChannel+8)
           if(Ch_data(k) == 3  && k~=FiredChannel)
                GreatThan3(k) = GreatThan3(k) + 1;
                t3=t3+1;
               
               % k
                 t13(DisplayK)=t13(DisplayK)+1;
               break;
           elseif(Ch_data(k) == 2  && k~=FiredChannel)
                GreatThan2(k) = GreatThan2(k) + 1;
                t2=t2+1;
                 t12(DisplayK)=t12(DisplayK)+1; 
                 DisplayK ;
                break;
           elseif(Ch_data(k) == 1  && k~=FiredChannel)
                GreatThan1(k) = GreatThan1(k) + 1; 
                t1=t1+1;
              %  t1
                 t11(DisplayK)=t11(DisplayK)+1;
               
              break; 
           end
         end
        end
      %end
          FiredCount = FiredCount + 1;  

        SumData =GreatThan3 + GreatThan2 + GreatThan1  ;
    end

 SumData(FiredChannel)=FiredCount;
        SumData;
end    
t1 
t2
t3
%fid2=fopen('K:\dhcal\picture\A23\data\2.txt','w');fprintf(fid2,'%d\n',t12 );  fclose(fid2); 
FiredCount
FiredChannel

%*** Plot Sum Data 2D
NewSumData = SingleMapping(SumData, ASIC_Channel, Pad_Channel);
 X = 1:9;
 Y = 1:9;
CTotal = zeros(9,9);
for i = 1:9
        for j = 1:9        
            if (i == 9) || (j ==9)
                CTotal(i,j) = 0;
            else
                CTotal(i,j) = NewSumData((i - 1)*8 + j);
            end
        end
end
figure;
pcolor(X,Y,CTotal);
title('Sum of the hit data')
    % coclormap summer
colormap(flipud(gray))
colorbar;
axis ij;
axis square;
legend_str = sprintf('The Pad that hitted \n header = %X, BCID = %u',header,BCID);
h = legend(legend_str);
set(h,'Location','northoutside');
for i = 1:8
    for j = 1:8
        PadNum = j + 8*(i - 1);
        str = ['Ch', int2str(PadNum)];
        xText_o = 1.1;
        yText_o = 1.5;
        xText = xText_o + (j - 1);
        yText = yText_o + (i - 1);
        text('String',str,'Position',[xText, yText],'FontSize',10,'Color','r');
    end
end
%*** Plot Sum Data 3D  
C3DSumData = zeros(8,8);   
for i = 1:8
    for j = 1:8        
        C3DSumData(i,j) = NewSumData((i - 1)*8 + j);
    end
end
width = 1;
figure;
b = bar3(C3DSumData,width);
title('Sum of the hit data');
colormap(flipud(parula))
colorbar;
for k = 1:length(b)
    zdata = b(k).ZData;
    b(k).CData = zdata;
    b(k).FaceColor = 'interp';
end
%*** Plot Not Hitted Data 3D
NewNotHitted = SingleMapping(NotHitted, ASIC_Channel, Pad_Channel);
C3DNotHitted = zeros(8,8);   
for i = 1:8
    for j = 1:8        
        C3DNotHitted(i,j) = NewNotHitted((i - 1)*8 + j);
    end
end
width = 1;
figure;
b1 = bar3(C3DNotHitted,width);
StrNotHitted = sprintf('Hitted Count: Charge below 3fC.(Total count:%d)',FiredCount);
title(StrNotHitted);
colormap(flipud(parula))
colorbar;
for k = 1:length(b1)
    zdata = b1(k).ZData;
    b1(k).CData = zdata;
    b1(k).FaceColor = 'interp';
end
%*** Plot Hitted Data between 1 and 2
NewGreatThan1 = SingleMapping(GreatThan1, ASIC_Channel, Pad_Channel);
C3D1 = zeros(8,8);   
for i = 1:8
    for j = 1:8        
        C3D1(i,j) = NewGreatThan1((i - 1)*8 + j);
    end
end
width = 1;
figure;
b1 = bar3(C3D1,width);
StrGreatThan1 = sprintf('Hitted Count: Charge between 3fC and 20fC.(Total count:%d)',FiredCount);
title(StrGreatThan1);
colormap(flipud(parula))
colorbar;
for k = 1:length(b1)
    zdata = b1(k).ZData;
    b1(k).CData = zdata;
    b1(k).FaceColor = 'interp';
end
%*** Plot Hitted Data between 2 and 3
NewGreatThan2 = SingleMapping(GreatThan2, ASIC_Channel, Pad_Channel);
C3D2 = zeros(8,8);   
for i = 1:8
    for j = 1:8        
        C3D2(i,j) = NewGreatThan2((i - 1)*8 + j);
    end
end
width = 1;
figure;
b2 = bar3(C3D2,width);
StrGreatThan2 = sprintf('Hitted Count: Charge between 20fC and 150fC.(Total count:%d)',FiredCount);
title(StrGreatThan2);
colormap(flipud(parula))
colorbar;
for k = 1:length(b2)
    zdata = b2(k).ZData;
    b2(k).CData = zdata;
    b2(k).FaceColor = 'interp';
end
NewGreatThan3 = SingleMapping(GreatThan3, ASIC_Channel, Pad_Channel);
C3D2 = zeros(8,8);   
for i = 1:8
    for j = 1:8        
        C3D2(i,j) = NewGreatThan3((i - 1)*8 + j);
    end
end
width = 1;
figure;
b3 = bar3(C3D2,width);
StrGreatThan3 = sprintf('Hitted Count: Charge Greater Than 150fC.(Total count:%d)',FiredCount);
title(StrGreatThan3);
colormap(flipud(parula))
colorbar;
