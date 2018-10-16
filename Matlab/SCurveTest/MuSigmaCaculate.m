MuDac0 = zeros(1,1024);
SigmaDac0 = zeros(1,1024);
RDac0 = zeros(1,1024);
MuDac1 = zeros(1,1024);
SigmaDac1 = zeros(1,1024);
MuDac2 = zeros(1,1024);
SigmaDac2 = zeros(1,1024);
for i = 1:1:4
    for j = 1:1:4
        for k = 1:1:64
            MuDac0((i-1)*64*4+(j-1)*64+k) = Dac0FitP(i,j,k,2);
            SigmaDac0((i-1)*64*4+(j-1)*64+k) = 1/(sqrt(2)*Dac0FitP(i,j,k,1));
            RDac0 ((i-1)*64*4+(j-1)*64+k) = Dac0Rsquare(i,j,k);
            MuDac1((i-1)*64*4+(j-1)*64+k) = Dac1FitP(i,j,k,2);
            SigmaDac1((i-1)*64*4+(j-1)*64+k) = 1/(sqrt(2)*Dac1FitP(i,j,k,1));
            MuDac2((i-1)*64*4+(j-1)*64+k) = Dac2FitP(i,j,k,2);
            SigmaDac2((i-1)*64*4+(j-1)*64+k) = 1/(sqrt(2)*Dac2FitP(i,j,k,1));
        end
    end
end
MuDac0Select = MuDac0;
SigmaDac0Select = SigmaDac0;
for i = 1:1:1024
    if(RDac0(i) < 0.9995)
        MuDac0Select(i) = 0;
        SigmaDac0Select(i) = 0;
    end
end
j = 1;
k = 1;
for i = 1:1:1024
    if(MuDac0Select(j) == 0)
        MuDac0Select(j) = [];
        j = j-1;
    end
    if(SigmaDac0Select(k) == 0)
        SigmaDac0Select(k) = [];
        k = k-1;
    end
    j = j+1;
    k = k+1;
end
figure;
histogram(MuDac0Select)
SigmaDac0Select = SigmaDac0Select/4;
figure;
histogram(SigmaDac0Select)