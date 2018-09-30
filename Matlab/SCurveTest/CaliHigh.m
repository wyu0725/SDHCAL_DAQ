filepath = uigetdir('*.*','ÇëÑ¡ÔñÎÄ¼þ¼Ð');
prompt = {'Input ASIC ID'};
dlg = 'Input data info';
answer = inputdlg(prompt,dlg);
AsicID = str2double(answer(1));
DacRange = 101;
ChargeHigh = [2 4 6 8 10 12 14 16 18 20 40 60 80 100 120 140 160];
% ChargeHigh = [2 4 6 8 10 40 60 80 100 120 140];

ChargeLow = [50 100 150 200 250 300 350 400 450 500 550 600];

% Charge = [2 4];
PackageNumberHigh = length(ChargeHigh);
PackageNumberLow = length(ChargeLow);
Dac0FitP = zeros(PackageNumberHigh,64,4);
Dac0RSquare = zeros(PackageNumberHigh,64);
Dac1FitP = zeros(PackageNumberHigh,64,4);
Dac1RSquare = zeros(PackageNumberHigh,64);
Dac2FitP = zeros(PackageNumberLow,64,4);
Dac2RSquare = zeros(PackageNumberLow,64);

for i = 1:1:PackageNumberLow
        filename = sprintf('%s\\ASIC%dSCTest%dfCLowGain.dat',filepath,AsicID,ChargeLow(i));
        [fid,~] = fopen(filename,'r');
        if fid <= 0
            % There was an error--tell user
            str = ['File ' filename ' could not be opened.'];
            dlg_title = 'File Open Faild';
            errordlg(str, dlg_title,'modal');
            break;
        else
            %File opend successfully
            InitialData = fread(fid,'uint16','ieee-be');%Big-endian ording
            %Size = length(importdata);
            fclose(fid);%close file
        end
        for j = 0:1:63
            [DacCode, ~, ~, TriggerRatio2] = SingleChannelSCurveReadback(InitialData, j, DacRange);
            [Dac2FitP(i,j+1,:), Dac2RSquare(i,j+1)] = SCurveFitReadback(DacCode, TriggerRatio2);        
        end
end

for i = 1:1:PackageNumberHigh
        filename = sprintf('%s\\ASIC%dSCTest%dfCHighGain.dat',filepath,AsicID,ChargeHigh(i));
        [fid,~] = fopen(filename,'r');
        if fid <= 0
            % There was an error--tell user
            str = ['File ' filename ' could not be opened.'];
            dlg_title = 'File Open Faild';
            errordlg(str, dlg_title,'modal');
            break;
        else
            %File opend successfully
            InitialData = fread(fid,'uint16','ieee-be');%Big-endian ording
            %Size = length(importdata);
            fclose(fid);%close file
        end
        for j = 0:1:63
            [DacCode, TriggerRatio0, TriggerRatio1, ~] = SingleChannelSCurveReadback(InitialData, j, DacRange);
            [Dac0FitP(i,j+1,:), Dac0RSquare(i,j+1)] = SCurveFitReadback(DacCode, TriggerRatio0);
            [Dac1FitP(i,j+1,:), Dac1RSquare(i,j+1)] = SCurveFitReadback(DacCode, TriggerRatio1);        
        end
end

Dac0Value = zeros(PackageNumberHigh,1);
Dac0Sigma = zeros(PackageNumberHigh,1);
Dac1Value = zeros(PackageNumberHigh,1);
Dac1Sigma = zeros(PackageNumberHigh,1);
for i = 1:1:PackageNumberHigh
    Dac0Value(i) = Dac0FitP(i,1,2);
    Dac0Sigma(i) = 1/(sqrt(2)*Dac0FitP(i,1,1));
    Dac1Value(i) = Dac1FitP(i,1,2);
    Dac1Sigma(i) = 1/(sqrt(2)*Dac1FitP(i,1,1));
end
figure;
plot(ChargeHigh,Dac0Value','*');
figure;
plot(ChargeHigh,Dac1Value','*');


Dac2Value = zeros(PackageNumberLow,1);
Dac2Sigma = zeros(PackageNumberLow,1);
for i = 1:1:PackageNumberLow
    Dac2Value(i) = Dac2FitP(i,1,2);
    Dac2Sigma(i) = 1/(sqrt(2)*Dac2FitP(i,1,1));
end
figure;
plot(ChargeLow,Dac2Value','*');