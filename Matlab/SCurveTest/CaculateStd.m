function [ Dac0Std, Dac1Std, Dac2Std, Amp0, Amp1, Amp2 ] = CaculateStd( ImportData, Channel_Number )
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
    [~, ~, P0, T0, P1, T1, P2, T2] = ReadData(ImportData, 2 + Channel_Number*7169);
    TrigRatio0 = (T0./P0);
    TrigRatio1 = (T1./P1);
    TrigRatio2 = (T2./P2);
    for i = 1024:-1:2
        if(TrigRatio0(i-1) > TrigRatio0(i))
            TrigRatio0(i-1) = TrigRatio0(i);
        end
        if(TrigRatio1(i-1) > TrigRatio1(i))
            TrigRatio1(i-1) = TrigRatio1(i);
        end
        if(TrigRatio2(i-1) > TrigRatio2(i))
            TrigRatio2(i-1) = TrigRatio2(i);
        end
    end

    DiffT0 = diff(TrigRatio0);
    DiffT1 = diff(TrigRatio1);
    DiffT2 = diff(TrigRatio2);
%     DacCode(1024) = [];
    DacCode = 1:1023;
    MeanDac0 = DacCode*DiffT0';
    NewDac0 = (DacCode - MeanDac0).*(DacCode - MeanDac0);
    VarDac0 = NewDac0*DiffT0';
    Dac0Std = sqrt(VarDac0);
    
    MeanDac1 = DacCode*DiffT1';
    NewDac1 = (DacCode - MeanDac1).*(DacCode - MeanDac1);
    VarDac1 = NewDac1*DiffT1';
    Dac1Std = sqrt(VarDac1);
    
    MeanDac2 = DacCode*DiffT2';
    NewDac2 = (DacCode - MeanDac2).*(DacCode - MeanDac2);
    VarDac2 = NewDac2*DiffT2';
    Dac2Std = sqrt(VarDac2);
    
    Start0 = 1022;
    End0 = 0;
    Start1 = 1022;
    End1 = 0;
    Start2 = 1022;
    End2 = 0;
    for i = 1:1022
        %DAC0
        if((DiffT0(i) == 0) && (DiffT0(i+1) ~= 0))
            Start0 = min(Start0,(2*i + 1)/2);
        end
        if((DiffT0(i) ~= 0) && (DiffT0(i+1) == 0))
            End0 = max(End0,(2*i + 1)/2);
        end
        %DAC1
        if((DiffT1(i) == 0) && (DiffT1(i+1) ~= 0))
            Start1 = min(Start1,(2*i + 1)/2);
        end
        if((DiffT1(i) ~= 0) && (DiffT1(i+1) == 0))
            End1 = max(End1,(2*i + 1)/2);
        end
        %DAC2
        if((DiffT2(i) == 0) && (DiffT2(i+1) ~= 0))
            Start2 = min(Start2,(2*i + 1)/2);
        end
        if((DiffT2(i) ~= 0) && (DiffT2(i+1) == 0))
            End2 = max(End2,(2*i + 1)/2);
        end
    end
    Amp0 = End0 - Start0;
    Amp1 = End1 - Start1;
    Amp2 = End2 - Start2;
    
end

