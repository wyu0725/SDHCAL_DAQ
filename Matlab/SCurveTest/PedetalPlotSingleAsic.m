 function [] = PedetalPlotSingleAsic()
    InitialData = Importdata();
    prompt = {'Input DAC Range'};
    dlg = 'Input data info';
    answer = inputdlg(prompt,dlg);
    DacRange = str2double(answer(1));
    Dac0FitP = zeros(64, 4);
    Dac1FitP = zeros(64, 4);
    Dac2FitP = zeros(64, 4);
    Dac0Rsquare = zeros(64, 1);
    Dac1Rsquare = zeros(64, 1);
    Dac2Rsquare = zeros(64, 1);
    for i = 1:1:64
            [DacCode,~,~,~,...,
            Dac0FitP(i,:),Dac1FitP(i,:),Dac2FitP(i,:),...,
                Dac0Rsquare(i),Dac1Rsquare(i),Dac2Rsquare(i)] ...,
            = SingleChannelSCurveCaculate(InitialData,i-1,DacRange);
    end
    
    Channel = 1:1:64;
    figure;
    yyaxis left
    plot(Channel, Dac0FitP(:,2),'*-');
    ylabel('\bf mu');
    yyaxis right
    plot(Channel, Dac0Rsquare,'o-');
    ylabel('\bf R');
    xlabel('\bf Channel')
end

