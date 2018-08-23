D01 = zeros(64,1);
Trouble = zeros(64,1);
for i = 1:1:64
    D01(i) = D00(i,1)*D00(i,2);
    if(D01(i)<585)
        D01(i) = [];
        Trouble(i) = 1;
    end
end