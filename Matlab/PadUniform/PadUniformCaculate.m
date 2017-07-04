[Header, Peak] = textread('1.txt','%s %f');
MappingData = GetPadMapData();

PadNumber = length(Header);
TotalPeak = 0;
PeakNumber = 0;
ValuePeak = zeros(440,1);
for i = 1:1:PadNumber
    if(Peak(i) ~= 0)
        PeakNumber = PeakNumber + 1;
        ValuePeak(PeakNumber) = Peak(i);
        TotalPeak = TotalPeak + Peak(i);
    end
end

MeanPeak = TotalPeak / PeakNumber;
StdPeak = std(ValuePeak);
UniformPeak = StdPeak / MeanPeak;

PadAmplitude = zeros(30,30);
counts=0;
for k=1:1:PadNumber  
    for m=1:1:30
        for n=1:1:30
            %a2(k);
            if(isequal(Header(k),MappingData(m,n)))
                PadAmplitude(m,n)=Peak(k);
                counts=counts+1;
            end
        end
    end
end
figure;
b = bar3(PadAmplitude);
xlim([0.5 30.5]);
ylim([0.5 30.5]);
xlabel('X(cm)');
ylabel('Y(cm)');
zlabel('Amplitude(V)');

for k = 1:length(b)
    zdata = b(k).ZData;
    b(k).CData = zdata;
    b(k).FaceColor = 'interp';
end
colorbar;
figure;
ChargePeak = zeros(PeakNumber,1);
% for i = 1:1:PeakNumber
%     ChargePeak(i) = Voltage2Charge(ValuePeak(i));
% end
hist(ValuePeak,50);
% MeanCharge = mean(ChargePeak);
% StdCharge = std(ChargePeak);
% UniCharge = StdCharge / MeanCharge;
xlabel('Amplitude(V)');
ylabel('Count');
% TestInfo = sprintf('Mean:%1.4f(fC)\n Std:%1.4f(fC)\n $\\frac{Std}{Mean}$:%2.4f(fC)\n',MeanCharge,StdCharge,UniCharge);
TestInfo = sprintf('Mean:%1.4f(V)\n Std:%1.4f(V)\n $\\frac{Std}{Mean}:%2.4f$\n',MeanPeak,StdPeak,UniformPeak);
text('Interpreter','latex','Position',[0.5 20],'String',TestInfo);