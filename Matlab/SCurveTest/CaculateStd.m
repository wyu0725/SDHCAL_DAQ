function [ Dac0Std, Dac1Std, Dac2Std ] = CaculateStd( ImportData, Channel_Number )
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


end

