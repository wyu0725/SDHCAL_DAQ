function [ AmpAverage, AmpStd ] = GetAdcCaliPeak( Amp,AmpCount )
    FAmp = AmpCount/sum(AmpCount);
    AmpAverage = FAmp*Amp';
    AmpStd = sqrt(FAmp*((Amp-AmpAverage).*(Amp-AmpAverage))');
end

