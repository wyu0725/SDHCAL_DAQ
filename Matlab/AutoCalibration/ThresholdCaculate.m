ThresholdDac0 = zeros(4,4,9);
ThresholdDac0Slope = zeros(4,4);
ThresholdDac0Intercept = zeros(4,4);
ThresholdDac0R = zeros(4,4);
DacFit = zeros(9,1);
for i = 1:1:4
    for j = 1:1:4
        for k = 1:1:9
            ThresholdDac0(i,j,k) = DacCodeVth0(k,(i-1)*4+(5-j));
            DacFit(k) = DacCodeVth0(k,(i-1)*4+(5-j));
        end
        [ThresholdDac0Slope(i,j),ThresholdDac0Intercept(i,j),ThresholdDac0R(i,j)] = LinearFitBack(DacCode(1:7),DacFit(1:7));
    end
end