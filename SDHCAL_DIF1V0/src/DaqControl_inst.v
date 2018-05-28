DaqControl inst_name (
    .Clk(),
    .reset_n(),
    .DaqSelect(),
    // Start signal
    .UsbAcqStart(),
    .UsbStartStop(),
    // Read start and end
    .EndReadout(),
    .StartReadout(),
    // Pins
    .CHIPSATB(),
    .RESET_B(),
    .START_ACQ(),
    .PWR_ON_A(),
    .PWR_ON_D(),
    .PWR_ON_ADC(),
    .PWR_ON_DAC(),
    // Force Raz Signal
    .SCurveForceExternalRaz(),
    .ForceExternalRaz(),
    // Parameters
    .AcquisitionTime(),
    .EndHoldTime(),
    // Done Signal
    .OnceEnd(),
    .AllDone(),
    .DataTransmitDone(),
    .UsbFifoEmpty(),
    //Acquire Data
    .MicrorocData(),
    .MicrorocData_en(),
    .DaqData(),
    .DaqData_en(),
    // External trigger
    .ExternalTrigger()
    );
