Pedestal = zeros(1,64);

AlignDacValue = zeros(4,4,64);
ErrorChannel = zeros(4,4,13);
ErrorChannel(1,1,:) = [27,37,38,39,49,42,0,0,0,0,0,0,0];
ErrorChannel(1,2,:) = [27,37,38,39,49,0,0,0,0,0,0,0,0];
ErrorChannel(1,3,:) = [27,37,38,39,49,0,0,0,0,0,0,0,0];
ErrorChannel(1,4,:) = [27,37,38,39,49,0,0,0,0,0,0,0,0];
ErrorChannel(2,1,:) = [27,33,37,38,0,0,0,0,0,0,0,0,0];
ErrorChannel(2,2,:) = [28,38,39,49,48,0,0,0,0,0,0,0,0];
ErrorChannel(2,3,:) = [27,37,38,39,49,0,0,0,0,0,0,0,0];
ErrorChannel(2,4,:) = [27,37,38,39,49,0,0,0,0,0,0,0,0];
ErrorChannel(3,1,:) = [27,28,37,38,39,49,0,0,0,0,0,0,0];
ErrorChannel(3,2,:) = [27,28,37,38,39,49,0,0,0,0,0,0,0];
ErrorChannel(3,3,:) = [27,28,37,38,39,49,0,0,0,0,0,0,0];
ErrorChannel(3,4,:) = [3,4,27,28,37,38,39,49,0,0,0,0,0];
ErrorChannel(4,1,:) = [55,56,58,60,0,0,0,0,0,0,0,0,0];
ErrorChannel(4,2,:) = [55,56,60,0,0,0,0,0,0,0,0,0,0];
ErrorChannel(4,3,:) = [55,56,60,0,0,0,0,0,0,0,0,0,0];
ErrorChannel(4,4,:) = [27,28,50,51,52,53,54,55,56,57,58,59,60];
for i=1:1:4
    for j = 1:1:4
        Channel = 1;
        PedestalCaculate = zeros(1,64);
        for k = 1:1:64
            Pedestal(k) = Dac0FitP(i,j,k,2);
            if(k == ErrorChannel(i,j,1)...,
                    || k == ErrorChannel(i,j,2)...,
                    || k == ErrorChannel(i,j,3)...,
                    || k == ErrorChannel(i,j,4)...,
                    || k == ErrorChannel(i,j,5)...,
                    || k == ErrorChannel(i,j,6)...,
                    || k == ErrorChannel(i,j,7)...,
                    || k == ErrorChannel(i,j,8)...,
                    || k == ErrorChannel(i,j,9)...,
                    || k == ErrorChannel(i,j,10)...,
                    || k == ErrorChannel(i,j,11)...,
                    || k == ErrorChannel(i,j,12)...,
                    || k == ErrorChannel(i,j,13)...,
                )
                PedestalCaculate(Channel) = [];
                continue;
            end
            PedestalCaculate(Channel) = Pedestal(k);
            Channel = Channel + 1;
        end
        MinimumPedestal = min(PedestalCaculate);
        Channel = 1;
        for k =1:1:64
            if(k == ErrorChannel(i,j,1)...,
                    || k == ErrorChannel(i,j,2)...,
                    || k == ErrorChannel(i,j,3)...,
                    || k == ErrorChannel(i,j,4)...,
                    || k == ErrorChannel(i,j,5)...,
                    || k == ErrorChannel(i,j,6)...,
                    || k == ErrorChannel(i,j,7)...,
                    || k == ErrorChannel(i,j,8)...,
                    || k == ErrorChannel(i,j,9)...,
                    || k == ErrorChannel(i,j,10)...,
                    || k == ErrorChannel(i,j,11)...,
                    || k == ErrorChannel(i,j,12)...,
                    || k == ErrorChannel(i,j,13)...,
                )
                continue;
            end
            AlignDacTemp = (PedestalCaculate(Channel) - MinimumPedestal) * ThresholdDac0Slope(i, j)*1000 / 0.728;
%             if(AlignDacTemp > 15)
%                 AlignDacValue(i,j,k) = 15;
%             else
%                 AlignDacValue(i,j,k) = round(AlignDacTemp);
%             end
            AlignDacValue(i,j,k) = round(AlignDacTemp);
            Channel = Channel + 1;
        end
    end
end