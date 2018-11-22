% DAC0 and DAC1
Dac0Caculate = Dac0Code;
Dac1Caculate = Dac1Code;
k = 1;
for i = 1:1:64
    if( i == 27 ...,
        || i == 28  ...,
        || i == 37 ...,
        || i == 38 ...,
        || i == 39 ...,
        || i == 49 ...,
        || i == 0 ...,
        || i == 0 ...,
        || i == 0 ...,
        || i == 0)
    Dac0Caculate(k,:) = [];
        continue;
    end
    k = k+1;
end
k = 1;
for i = 1:1:64
    if( i == 27 ...,
        || i == 28 ...,
        || i == 0 ...,
        || i == 36 ...,
        || i == 37 ...,
        || i == 38 ...,
        || i == 39 ...,
        || i == 0 ...,
        || i == 0 ...,
        || i == 49)
    Dac1Caculate(k,:) = [];
        continue;
    end
    k = k+1;
end
[MinDac0, LocationDac0] = min(Dac0Caculate);
[MinFitSlopeDac0,MinFitInterceptDac0,Dac0R]=LinearFit(ChargeHigh(11:16)',MinDac0(11:16)');
Dac0Function = @(x) MinFitSlopeDac0 * x + MinFitInterceptDac0;
Dac0DataLength = length(Dac0Caculate);
[MinDac1, LocationDac1] = min(Dac1Caculate);
[MinFitSlopeDac1,MinFitInterceptDac1,Dac1R]=LinearFit(ChargeHigh(11:16)',MinDac1(11:16)');
Dac1Function = @(x) MinFitSlopeDac1 * x + MinFitInterceptDac1;
Dac1DataLength = length(Dac1Caculate);
figure
plot(ChargeHigh, MinDac0,'*')
hold on
fplot(Dac0Function,[0 140])
hold off
title('\bf DAC0 Result');
xlabel('\bf Charge (fC)');
ylabel('DAC Code (DAC Unit)');
figure
plot(ChargeHigh, MinDac1,'*')
hold on
fplot(Dac1Function,[0 140])
hold off
title('\bf DAC1 Result');
xlabel('\bf Charge (fC)');
ylabel('DAC Code (DAC Unit)');
% DAC2
Dac2Caculate = Dac2Code;
k = 1;
for i = 1:1:64
    if( i == 27 ...,
        || i == 28 ...,
        || i == 29 ...,
        || i == 36 ...,
        || i == 39 ...,
        || i == 47 ...,
        || i == 48 ...,
        || i == 49 ...,
        || i == 0 ...,
        || i == 0)
    Dac2Caculate(k,:) = [];
        continue;
    end
    k = k+1;
end
[MinDac2, LocationDac2] = min(Dac2Caculate);
[MinFitSlopeDac2,MinFitInterceptDac2,Dac2R]=LinearFit(ChargeLow',MinDac2');
Dac2Function = @(x) MinFitSlopeDac2 * x + MinFitInterceptDac2;
Dac2DataLength = length(Dac2Caculate);
figure
plot(ChargeLow, MinDac2,'*')
hold on
fplot(Dac2Function,[0 500])
hold off
title('\bf DAC2 Result');
xlabel('\bf Charge (fC)');
ylabel('DAC Code (DAC Unit)');
% ErrorDac0 = zeros(64,16);
% figure;
% for i = 1:1:16
%     for j = 1:1:Dac0DataLength
% %         if( j == 27 ...,
% %             || j == 37 ...,
% %             || j == 38 ...,
% %             || j == 39 ...,
% %             || j == 49)
% %             ErrorDac0(j,i) = 0;
% %         else
%             ErrorDac0(j,i) = (Dac0Caculate(j,i) - Dac0Function(ChargeHigh(i)));
% %         end
%     end
%     plot(ErrorDac0(:,i));
%     hold on
% end