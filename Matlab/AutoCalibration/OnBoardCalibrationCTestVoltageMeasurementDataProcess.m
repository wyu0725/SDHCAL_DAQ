CTestVoltage = zeros(4,4,11);
CTestVoltage(1,1,:) = ASIC11;
CTestVoltage(1,2,:) = ASIC12;
CTestVoltage(1,3,:) = ASIC13;
CTestVoltage(1,4,:) = ASIC14;
CTestVoltage(2,1,:) = ASIC21;
CTestVoltage(2,2,:) = ASIC22;
CTestVoltage(2,3,:) = ASIC23;
CTestVoltage(2,4,:) = ASIC24;
CTestVoltage(3,1,:) = ASIC31;
CTestVoltage(3,2,:) = ASIC32;
CTestVoltage(3,3,:) = ASIC33;
CTestVoltage(3,4,:) = ASIC34;
CTestVoltage(4,1,:) = ASIC41;
CTestVoltage(4,2,:) = ASIC42;
CTestVoltage(4,3,:) = ASIC43;
CTestVoltage(4,4,:) = ASIC44;
Slope = zeros(4,4);
Intercept = zeros(4,4);
R = zeros(4,4);
Voltage = zeros(11,1);
for i = 1:1:4
    for j = 1:1:4
        AsicID = sprintf('%d%d',i,j);
        for k = 1:1:11
            Voltage(k) = CTestVoltage(i,j,k);
        end
        [Slope(i,j),Intercept(i,j),R(i,j)] = CTestVoltageTest(DACCode,Voltage,AsicID);
    end
end