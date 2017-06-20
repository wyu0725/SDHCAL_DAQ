function [fitresult, gof] = createFit(Adc, AdcCount)
%CREATEFIT(ADC,ADCCOUNT)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : Adc
%      Y Output: AdcCount
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  另请参阅 FIT, CFIT, SFIT.

%  由 MATLAB 于 20-Jun-2017 22:40:57 自动生成


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( Adc, AdcCount );

% Set up fittype and options.
ft = fittype( 'gauss1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf 0];
opts.StartPoint = [1768983 1757.5 0.777328651124371];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, xData, yData );
legend( h, 'AdcCount vs. Adc', 'untitled fit 1', 'Location', 'NorthEast' );
% Label axes
xlabel Adc
ylabel AdcCount
grid on


