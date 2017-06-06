%%% S Curve º∆À„¥Æ»≈

prompt = {'Start DAC','End DAC'};
DlgTitle = 'Input parameter';
answer = inputdlg(prompt);

StartDac = str2double(answer(1));
EndDac = str2double(answer(2));

ImportDataBase = Importdata();
Dac0_50PercentBase = zeros(1,64);
Dac1_50PercentBase = zeros(1,64);
Dac2_50PercentBase = zeros(1,64);
DacCountBase = EndDac - StartDac + 1;
ImportDataSignal = Importdata();
Dac0_50PercentSignal = zeros(1,64);
Dac1_50PercentSignal = zeros(1,64);
Dac2_50PercentSignal = zeros(1,64);
answer = inputdlg(prompt);
StartDac = str2double(answer(1));
EndDac = str2double(answer(2));
DacCount = EndDac - StartDac + 1;
for i = 0:1:63
    if(i == 28)
        Dac0_50PercentBase(i) = 0;
        Dac1_50PercentBase(i) = 0;
        Dac2_50PercentBase(i) = 0;
        Dac0_50PercentSignal(i) = 0;
        Dac1_50PercentSignal(i) = 0;
        Dac2_50PercentSignal(i) = 0;
        continue;
    end        
    [DacCode, Dac0_50PercentBase(i+1), Dac1_50PercentBase(i+1), Dac2_50PercentBase(i+1)] = SCurveCaculateWiDacRange(ImportDataBase, i, DacCountBase, 1);
    [DacCode1, Dac0_50PercentSignal(i+1), Dac1_50PercentSignal(i+1), Dac2_50PercentSignal(i+1)] = SCurveCaculateWiDacRange(ImportDataSignal, i, DacCount, 2);
end

Crosstalk = abs(Dac0_50PercentBase - Dac0_50PercentSignal);
Crosstalk(2) = 0;
Crosstalk(29) = 0;
Crosstalk(22) = 0.1;
Crosstalk(61) = 0.1;
Amptitude = Crosstalk/4.25;
figure;
plot(Amptitude);

[ASIC_Channel, Pad_Channel] = GetMapping();
NewAmp = SingleMapping(Amptitude, ASIC_Channel, Pad_Channel);
 X = 1:9;
 Y = 1:9;
CAmp = zeros(9,9);
for i = 1:9
        for j = 1:9        
            if (i == 9) || (j ==9)
                CAmp(i,j) = 0;
            else
                CAmp(i,j) = NewAmp((i - 1)*8 + j);
            end
        end
end
figure;
pcolor(X,Y,CAmp);
title('Crosstalk,500fC hitted on A28')
    % coclormap summer
colormap(flipud(gray))
colorbar;
axis ij;
axis square;
legend_str = sprintf('Crosstalk,500fC hitted A28');
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
C3DAmp = zeros(8,8);   
for i = 1:8
    for j = 1:8        
        C3DAmp(i,j) = NewAmp((i - 1)*8 + j);
    end
end
width = 1;
figure;
b = bar3(C3DAmp,width);
title('Crosstalk,500fC hitted A28');
zlabel('fC')
colormap(flipud(parula))
colorbar;
for k = 1:length(b)
    zdata = b(k).ZData;
    b(k).CData = zdata;
    b(k).FaceColor = 'interp';
end