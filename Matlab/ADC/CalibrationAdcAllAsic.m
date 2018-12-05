DataFolder = uigetdir('*.*','ÇëÑ¡ÔñÎÄ¼þ¼Ð');
AverageNumber = 32;
StartCharge = 0;
EndCharge = 600;
ChargeStep = 50;

DataNumber = (EndCharge - StartCharge)/ChargeStep + 1;
Charge = StartCharge:ChargeStep:EndCharge;
AverageAdc = zeros(1,DataNumber);
StdAdc = zeros(1,DataNumber);
h = zeros(1,DataNumber);
for Row = 1:1:4
    for Column = 1:1:4
%         if(Row==1 && Column == 1)
%             continue;
%         end
        figure;
        AsicID = sprintf('%d%d',Row, Column);
        TestDataFolder = sprintf('%s\\ASIC%d%d',DataFolder, Row, Column);
        for i = 1:1:DataNumber            
            [AverageAdc(i), StdAdc(i), h(i)] = CaculateAdcAutoImport(AverageNumber, 10,Charge(i),AsicID,TestDataFolder);
        end
        xlabel('\bf ADC Code');
        ylabel('\bf Count');
        titleString = sprintf('\\bf Histogram of different charge. ASIC%d%d',Row, Column);
        title(titleString);
        hold off;
        
%         figure;
%         plot(Charge,AverageAdc,'o-')
%         xlabel('\bf Charge(fC)');
%         ylabel('\bf ADC code');
%         titleString = sprintf('\\bf ADC code Vs. Charge. ASIC%d%d',Row, Column);
%         title(titleString);
    end
end