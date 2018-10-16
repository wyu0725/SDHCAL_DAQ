Dac0Code = zeros(64,16);
Dac1Code = zeros(64,16);
Dac2Code = zeros(64,10);
ChargeHigh = [2 4 6 8 10 12 14 16 18 20 40 60 80 100 120 140];
ChargeLow = [50 100 150 200 250 300 350 400 450 500];
for i = 1:1:64
    for j = 1:1:16
        Dac0Code(i,j) = Dac0FitP(j,i,2);
        Dac1Code(i,j) = Dac1FitP(j,i,2);
    end
end
for i = 1:1:64
    for j = 1:1:10
        Dac2Code(i,j) = Dac2FitP(j,i,2);
    end
end

[FitSlopeDac0,FitInterceptDac0,FitRDac0] = SingleShaperFitInSingleAsic(ChargeHigh,Dac0Code);
[FitSlopeDac1,FitInterceptDac1,FitRDac1] = SingleShaperFitInSingleAsic(ChargeHigh,Dac1Code);
[FitSlopeDac2,FitInterceptDac2,FitRDac2] = SingleShaperFitInSingleAsic(ChargeLow,Dac2Code);