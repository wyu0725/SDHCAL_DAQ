function [ Peak,PeakLocation ] = FindSpectraPeaks( Adc,AdcCount,PlotOrNot )
% 输入采到的能谱，自动寻找峰位
% 使用双高斯拟合找出峰位，并作图
%
    %Filter the spectra
    windowSize = 10;
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    y=filter(b,a,AdcCount);
    [Peak1st,Location ]= max(y);
    %Find the FWHM
    FitStart = 1;
    FitEnd = length(AdcCount);
    HalfPeak = Peak1st/2;
    for i = Location:-1:2
        if((y(i)>= HalfPeak) && y(i - 1) < HalfPeak)
            FitStart = i;
            break;
        end
    end
    for i = Location:1:(length(AdcCount)-1)
        if((y(i)>= HalfPeak) && y(i + 1) < HalfPeak)
            FitEnd = i;
            break;
        end
    end
    fFit = fit(Adc(FitStart:FitEnd).',y(FitStart:FitEnd).','gauss2');
    [Peak,Locs] = findpeaks(fFit(Adc(FitStart:FitEnd)));
    Locs = Locs + FitStart;
    PeakLocation = Adc(Locs);
    if(PlotOrNot == 1)
        figure;
        plot(f3,Adc(FitStart:FitEnd),y(FitStart:FitEnd));
        hold on
        plot(Adc(FitStart:FitEnd),AdcCount(FitStart:FitEnd));
    end
end

