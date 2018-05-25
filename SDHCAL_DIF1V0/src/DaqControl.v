`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC 
// Engineer: Yu Wang
// 
// Create Date: 2017/06/29 14:26:40
// Design Name: SDHCAL_DAQ2V0
// Module Name: DaqControl
// Project Name: SDHCAL_DAQ2V0
// Target Devices: XC7A100TFGG484-2L
// Tool Versions: Vivado 16.3
// Description: This module is used for controlling the Microroc DAQ. The DAQ
// has 2 models, Auto DAQ and Slave DAQ. The AutoDaq start the DAQ process
// auto and use the power pulsing mode. The SlaveDaq start the DAQ module when 
// the external trigger come 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DaqControl(
    input Clk,
    input reset_n,
    input DaqSelect,
    // Start signal
    input UsbAcqStart,
    output UsbStartStop,
    // Read start and end
    input EndReadout,
    output StartReadout,
    // Pins
    input CHIPSATB,
    output RESET_B,
    output START_ACQ,
    output PWR_ON_A,
    output PWR_ON_D,
    output PWR_ON_ADC,
    output PWR_ON_DAC,
    // Force Raz Signal
    input SCurveForceExternalRaz,
    output ForceExternalRaz,
    // Parameters
    input [15:0] AcquisitionTime,
    input [15:0] EndHoldTime,
    // Done Signal
    output OnceEnd,
    output AllDone,
    input DataTransmitDone,
    input UsbFifoEmpty,
    //Acquire Data
    input [15:0] MicrorocData,
    input MicrorocData_en,
    output [15:0] DaqData,
    output DaqData_en,
    // External trigger
    input ExternalTrigger
    );

    // Daq Switcher
    wire AutoDaq_PWR_ON_A;
    wire AutoDaq_PWR_ON_D;
    wire AutoDaq_PWR_ON_ADC;
    wire AutoDaq_PWR_ON_DAC;
    wire SlaveDaq_PWR_ON_A;
    wire SlaveDaq_PWR_ON_D;
    wire SlaveDaq_PWR_ON_ADC;
    wire SlaveDaq_PWR_ON_DAC;
    wire AutoDaq_RESET_B;
    wire SlaveDaq_RESET_B;
    wire AutoDaq_START_ACQ;
    wire SlaveDaq_START_ACQ;
    wire AutoDaq_Start;
    wire SlaveDaq_Start;
    wire AutoDaq_StartReadout;
    wire SlaveDaq_StartReadout;
    wire AutoDaq_EndReadout;
    wire SlaveDaq_EndReadout;
    wire AutoDaq_OnceEnd;
    wire SlaveDaq_OnceEnd;
    wire AutoDaq_AllDone;
    wire SlaveDaq_AllDone;
    wire AutoDaq_DataTransmitDone;
    wire SlaveDaq_DataTransmitDone;
    wire SingleStart;
    wire AutoDaq_UsbStartStop;
    reg SlaveDaq_UsbStartStop;
    wire [15:0] SlaveDaqData;
    wire SlaveDaqData_en;
    wire [15:0] DataToSlaveDaq;
    wire DataToSlaveDaq_en;
    wire SlaveDaqForceExternalRaz;
    DaqSwitcher DaqModeSelect(
      .DaqSelect(DaqSelect),
      //Power pulsing control
      .AutoDaq_PWR_ON_A(AutoDaq_PWR_ON_A),
      .AutoDaq_PWR_ON_D(AutoDaq_PWR_ON_D),
      .AutoDaq_PWR_ON_ADC(AutoDaq_PWR_ON_ADC),
      .AutoDaq_PWR_ON_DAC(AutoDaq_PWR_ON_DAC),
      .SlaveDaq_PWR_ON_A(SlaveDaq_PWR_ON_A),
      .SlaveDaq_PWR_ON_D(SlaveDaq_PWR_ON_D),
      .SlaveDaq_PWR_ON_ADC(SlaveDaq_PWR_ON_ADC),
      .SlaveDaq_PWR_ON_DAC(SlaveDaq_PWR_ON_DAC),
      .PWR_ON_D(PWR_ON_D),
      .PWR_ON_A(PWR_ON_A),
      .PWR_ON_ADC(PWR_ON_ADC),
      .PWR_ON_DAC(PWR_ON_DAC),
      // pin
      .AutoDaq_RESET_B(AutoDaq_RESET_B),
      .SlaveDaq_RESET_B(SlaveDaq_RESET_B),
      .RESET_B(RESET_B),
      .AutoDaq_START_ACQ(AutoDaq_START_ACQ),
      .SlaveDaq_START_ACQ(SlaveDaq_START_ACQ),
      .START_ACQ(START_ACQ),
      .CHIPSATB(CHIPSATB),
      .AutoDaq_CHIPSATB(AutoDaq_CHIPSATB),
      .SlaveDaq_CHIPSATB(SlaveDaq_CHIPSATB),
      // Force External Raz
      .SCurve_ForceExternalRaz(SCurveForceExternalRaz),
      .SlaveDaq_ForceExternalRaz(SlaveDaqForceExternalRaz),
      .ForceExternalRaz(ForceExternalRaz),
      // Start Signal
      .UsbAcqStart(UsbAcqStart),
      .AutoDaq_Start(AutoDaq_Start),
      .SlaveDaq_Start(SlaveDaq_Start),
      // Read Start and End
      .AutoDaq_StartReadout(AutoDaq_StartReadout),
      .SlaveDaq_StartReadout(SlaveDaq_StartReadout),
      .StartReadout(StartReadout),
      .EndReadout(EndReadout),
      .AutoDaq_EndReadout(AutoDaq_EndReadout),
      .SlaveDaq_EndReadout(SlaveDaq_EndReadout),
      // Done signal
      .AutoDaq_OnceEnd(AutoDaq_OnceEnd),
      .SlaveDaq_OnceEnd(SlaveDaq_OnceEnd),
      .OnceEnd(OnceEnd),
      .AutoDaq_AllDone(AutoDaq_AllDone),
      .SlaveDaq_AllDone(SlaveDaq_AllDone),
      .AllDone(AllDone),
      .DataTransmitDone(DataTransmitDone),
      .AutoDaq_DataTransmitDone(AutoDaq_DataTransmitDone),
      .SlaveDaq_DataTransmitDone(SlaveDaq_DataTransmitDone),
      // Start trigger for SlaveDaq
      .ExternalTrigger(ExternalTrigger),
      .SingleStart(SingleStart),
      .AutoDaq_UsbStartStop(AutoDaq_UsbStartStop),
      .SlaveDaq_UsbStartStop(SlaveDaq_UsbStartStop),
      .UsbStartStop(UsbStartStop),
      // Data Transmit
      .MicrorocData(MicrorocData),
      .MicrorocData_en(MicrorocData_en),
      .SlaveDaqData(SlaveDaqData),
      .SlaveDaqData_en(SlaveDaqData_en),
      .DataToSlaveDaq(DataToSlaveDaq),
      .DataToSlaveDaq_en(DataToSlaveDaq_en),
      .AcquiredData(DaqData),
      .AcquiredData_en(DaqData_en)
    );
    
    AutoDaq AutoDaqControl
    (
      .Clk(Clk),         //40M
      .reset_n(reset_n),
      .start(AutoDaq_Start), //a pulse or a level?
      .End_Readout(AutoDaq_EndReadout), //Digitial RAM end reading signal, Active H
      .Chipsatb(AutoDaq_CHIPSATB),    //Chip is full, Active L, PIN
      .T_acquisition(AcquisitionTime),//Get from USB, default 8
      .Reset_b(AutoDaq_RESET_B),      //Reset ASIC digital part, PIN
      .Start_Acq(AutoDaq_START_ACQ),  //Start & maintain acquisition, Active H,PIN
      .Start_Readout(AutoDaq_StartReadout),//Digital RAM start reading signal
      .Pwr_on_a(AutoDaq_PWR_ON_A),  //Analogue Part Power Pulsing control, active H
      .Pwr_on_d(AutoDaq_PWR_ON_D),  //Digital Power Pulsing control, active H
      .Pwr_on_adc(AutoDaq_PWR_ON_ADC),//Slow shaper Power Pulsing Control, active H
      .Pwr_on_dac(AutoDaq_PWR_ON_DAC),//DAC Power Pulsing Control, Active H
      .Once_end(AutoDaq_OnceEnd) //a pulse
    );
    assign AutoDaq_AllDone = 1'b0;
    SlaveDaq SlaveDaqControl(
      .Clk(Clk),
      .reset_n(reset_n),
      .ModuleStart(SlaveDaq_Start),
      .AcqStart(SingleStart),
      .EndReadout(SlaveDaq_EndReadout),
      .CHIPSATB(SlaveDaq_CHIPSATB),
      .AcquisitionTime(AcquisitionTime),
      .EndHoldTime(EndHoldTime),
      .RESET_B(SlaveDaq_RESET_B),
      .START_ACQ(SlaveDaq_START_ACQ),
      .ForceExternalRaz(SlaveDaqForceExternalRaz),
      .StartReadout(SlaveDaq_StartReadout),
      .PWR_ON_A(SlaveDaq_PWR_ON_A),
      .PWR_ON_D(SlaveDaq_PWR_ON_D),
      .PWR_ON_ADC(SlaveDaq_PWR_ON_ADC),
      .PWR_ON_DAC(SlaveDaq_PWR_ON_DAC),
      .OnceEnd(SlaveDaq_OnceEnd),
      .AllDone(SlaveDaq_AllDone),
      // Data Transmit
      .MicrorocData(DataToSlaveDaq),
      .MicrorocData_en(DataToSlaveDaq_en),
      .SlaveDaqData(SlaveDaqData),
      .SlaveDaqData_en(SlaveDaqData_en),
      .DataTransmitDone(SlaveDaq_DataTransmitDone)
    );
    // Generate the USB start and stop
    assign AutoDaq_UsbStartStop = AutoDaq_Start;
    reg SlaveDaq_ResetUsbStart_n;
    always @(posedge SlaveDaq_Start or negedge SlaveDaq_ResetUsbStart_n) begin
      if(~SlaveDaq_ResetUsbStart_n)
        SlaveDaq_UsbStartStop <= 1'b0;
      else 
        SlaveDaq_UsbStartStop <= 1'b1;
    end
    always @(posedge Clk or negedge reset_n) begin
      if(~reset_n)
        SlaveDaq_ResetUsbStart_n <= 1'b0;
      else if(UsbFifoEmpty && SlaveDaq_AllDone)
        SlaveDaq_ResetUsbStart_n <= 1'b0;
      else
        SlaveDaq_ResetUsbStart_n <= 1'b1;
    end
endmodule
