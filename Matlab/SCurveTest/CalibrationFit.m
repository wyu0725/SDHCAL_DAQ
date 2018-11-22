Dac0Code = zeros(64,16);
Dac1Code = zeros(64,16);
Dac2Code = zeros(64,10);
Dac0Sigma  = zeros(64, 16);
Dac1Sigma  = zeros(64, 16);
Dac2Sigma  = zeros(64, 10);
ChargeHigh = [2 4 6 8 10 12 14 16 18 20 40 60 80 100 120 140];
ChargeLow = [50 100 150 200 250 300 350 400 450 500];
for i = 1:1:64
    for j = 1:1:16
        Dac0Code(i,j) = Dac0FitP(j,i,2);
        Dac1Code(i,j) = Dac1FitP(j,i,2);
        Dac0Sigma(i, j) = 1/(Dac0FitP(j,i, 1)*sqrt(2));
        Dac1Sigma(i, j) = 1/(Dac1FitP(j,i, 1)*sqrt(2));
    end
end
for i = 1:1:64
    for j = 1:1:10
        Dac2Code(i,j) = Dac2FitP(j,i,2);
        Dac2Sigma(i, j) = 1/(Dac2FitP(j,i, 1)*sqrt(2));
    end
end

figure;
for i = 1:1:16
    stairs(Dac0Code(:,i));
    hold on;
end
hold off;
title('\bf DAC0 2-140fC');
xlabel('\bf Channel');
ylabel('\bf DAC Code');
figure;
for i = 1:1:16
    stairs(Dac1Code(:,i));
    hold on;
end
hold off;
title('\bf DAC1 2-140fC');
xlabel('\bf Channel');
ylabel('\bf DAC Code');
figure;
for i = 1:1:10
    stairs(Dac2Code(:,i));
    hold on;
end
hold off;
title('\bf DAC2 50-500fC');
xlabel('\bf Channel');
ylabel('\bf DAC Code');
figure;
for i = 1:1:10
    stairs(Dac0Code(:,i));
    hold on;
end
hold off;
title('\bf DAC0 2-20fC');
xlabel('\bf Channel');
ylabel('\bf DAC Code');
figure;
for i = 1:1:10
    stairs(Dac1Code(:,i));
    hold on;
end
hold off;
title('\bf DAC1 2-20fC');
xlabel('\bf Channel');
ylabel('\bf DAC Code');

[p0,R0] = ThresholdCalibrationLinearfit(ChargeHigh,Dac0Code);
[p1,R1] = ThresholdCalibrationLinearfit(ChargeHigh,Dac1Code);
[p2,R2] = ThresholdCalibrationLinearfit(ChargeLow,Dac2Code);
p0Value = p0;
p1Value = p1;
p2Value = p2;
k = 1;
for i = 1:1:64
    if( i == 15 ...,
        || i == 18 ...,
        || i == 27 ...,
        || i == 28 ...,
        || i == 55 ...,
        || i == 56 ...,
        || i == 57 ...,
        || i == 58 ...,
        || i == 59 ...,
        || i == 60)
    p0Value(k,:) = [];
    p1Value(k,:) = [];
        continue;
    end
    k = k+1;
end
k = 1;
for i = 1:1:64
    if( i == 15 ...,
        || i == 18 ...,
        || i == 27 ...,
        || i == 28 ...,
        || i == 55 ...,
        || i == 56)
    p2Value(k,:) = [];
        continue;
    end
    k = k+1;
end
MeanP0 = mean(p0Value);
MeanP1 = mean(p1Value);
MeanP2 = mean(p2Value);