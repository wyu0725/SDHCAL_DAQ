`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Yu Wang
//
// Create Date: 2018/05/21 11:23:22
// Design Name: Microroc ASIC Control
// Module Name: MicrorocControl
// Project Name: SDHCAL DIF 1V0
// Target Devices: XC7A100TFGG484-2(l)
// Tool Versions: Vivado 2018.1
// Description: This module provides a control interface to the MICROROC
// ASIC. Contain SlowControlOrReadScope parameter sent, ASIC RAM readout,
// signal redundancy and power on control
// PP: Short for power pulsing: If enable, it will fellow the PWR_ON_X pin
//
// Dependencies:
//    FPGA_Top.V
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module MicrorocControl(
  input Clk,
  input reset_n,
  input SlowClock,                          // Slow clock for MICROROC, typically 5M. It is worth to try 10M clock
  input Clk5M,                              // Clock for Microroc Configuration. If SlowClock is 5M, this clock shoudl be same as SlowClock
  //input SyncClk,                            // This clock is a fast clock to synchronous the TriggerIn signal to generate the hold signal
  // The 'jitter' of the hold signal depends on the peroid of this signal
  input MicrorocReset_n,
  input SlowControlOrReadScopeSelect,
  input ParameterLoadStart,
  output ParameterLoadDone,
  // *** Slow Contro Parameter, from MSB to LSB. These parameter is out from
  // the same secquence, pulsed by the SlowClock.
  input [1:0] DataoutChannelSelect,         // Default: 11 Valid
  input [1:0] TransmitOnChannelSelect,      // Default: 11 Valid
  input ChipSatbEnable,                     // Default: 1 Valid
  input StartReadoutChannelSelect,          // Default: 1 StartReadout1
  input EndReadoutChannelSelect,            // Default: 1 EndReadout1
  input [1:0] NC,
  input [1:0] InternalRazSignalLength,      // 00: 75ns, 01: 250ns, 10: 500ns, 11: 1us Default: 11
  input CkMux,                              // Bypass Synchronous PowerOnDigital for SRo, CK5, CK40 Default: 1 bypass POD
  input LvdsReceiverPPEnable,               // Default:0 Disable
  input ExternalRazSignalEnable,            // Default: 0 Disable
  input InternalRazSignalEnable,            // Default: 1 Enable
  input ExternalTriggerEnable,              // Default: 1 Enable
  input TriggerNor64OrDirectSelect,         // Default: 1 Nor64
  input TriggerOutputEnable,                // Default: 1 Enable
  input [2:0] TriggerToWriteSelect,         // Default: 111 all
  input [9:0] Dac2Vth,                      // MSB->LSB
  input [9:0] Dac1Vth,
  input [9:0] Dac0Vth,
  input DacEnable,                          // Default: 1 Enable
  input DacPPEnable,
  input BandGapEnable,                      // Default: 1 Enable
  input BandGapPPEnable,
  input [7:0] ChipID,
  input [191:0] ChannelDiscriminatorMask,   // MSB correspones to Channel 63
  input LatchedOrDirectOutput,              // Default: 1 Latched
  input Discriminator1PPEnable,
  input Discriminator2PPEnable,
  input Discriminator0PPEnable,
  input OTAqPPEnable,
  input OTAqEnable,
  input Dac4bitPPEnable,
  input [255:0] ChannelAdjust,              // MSB to LSB from channel0 to channel 63
  input [1:0] HighGainShaperFeedbackSelect, // Default: 10
  input ShaperOutLowGainOrHighGain,         // Default: 0 High gain
  input WidlarPPEnable,                     // Default: 0 Disable
  input [1:0] LowGainShaperFeedbackSelect,  // Default: 10
  input LowGainShaperPPEnable,              // Default: 0
  input HighGainShaperPPEnable,             // Default: 0
  input GainBoostEnable,                    // Default: 1
  input PreAmplifierPPEnable,               // Default: 0
  input [63:0] CTestChannel,
  // ***64bit read register
  input [63:0] ReadScopeChannel,
  // *** Redundancy
  input PowerPulsingPinEnable,
  input ReadoutChannelSelect,
  // *** Trigger In
  input ExternalTriggerIn,
  input SCurveForceExternalRaz,
  output ForceExternalRaz,
  // *** Dataout interface
  output [15:0] ExternalFifoData,
  output ExternalFifoDataEnable,
  output TestDone,
  output OnceEnd,
  input nPKTEND,
  input ExternalFifoFull,
  input ExternalFifoEmpty,
  // AcqControl
  input DaqSelect,
  input AcqStart,
  output UsbStartStop,
  input StartEnable,
  input [15:0] AcquisitionStartTime,
  input [15:0] EndHoldTime,
  // *** Pins
  // Slow control and ReadScope
  output SR_RSTB,                           // Selected Register Reset
  output SR_CK,                             // Selected Register Clock
  output SR_IN,                             // Selected Register Input
  // input  SR_OUT, //Selected Register Output,Asic's daisy chain slow control output
  // Power pulsingPin
  output PWR_ON_D,
  output PWR_ON_A,
  output PWR_ON_DAC,
  output PWR_ON_ADC,
  // DAQ Control
  output START_ACQ,
  output RESET_B,
  input  CHIPSATB,
  output START_READOUT1,
  output START_READOUT2,
  input END_READOUT1,
  input END_READOUT2,
  // RAM readout
  input DOUT1B,
  input DOUT2B,
  input TRANSMITON1B,
  input TRANSMITON2B
  );

  SlowControlAndReadScopeSet SlowControlAndReadScope(
    .Clk                         (Clk),
    .reset_n                     (reset_n),
    .SlowClock                   (Clk5M),                    // Slow clock for MICROROC, typically 5M. It is worth to try 10M clock
    .MicrorocReset               (MicrorocReset_n),
    .SlowControlOrReadScopeSelect(SlowControlOrReadScopeSelect),
    .ParameterLoadStart          (ParameterLoadStart),
    .ParameterLoadDone           (ParameterLoadDone),
    // *** Slow Contro Parameter, from MSB to LSB. These parameter is out from
    // the same secquence, pulsed by the SlowClock.
    .DataoutChannelSelect        (DataoutChannelSelect),         // Default: 11 Valid
    .TransmitOnChannelSelect     (TransmitOnChannelSelect),      // Default: 11 Valid
    .ChipSatbEnable              (ChipSatbEnable),               // Default: 1 Valid
    .StartReadoutChannelSelect   (StartReadoutChannelSelect),    // Default: 1 StartReadout1
    .EndReadoutChannelSelect     (EndReadoutChannelSelect),      // Default: 1 EndReadout1
    .NC                          (NC),
    .InternalRazSignalLength     (InternalRazSignalLength),      // 00: 75ns, 01: 250ns, 10: 500ns, 11: 1us Default: 11
    .CkMux                       (CkMux),                        // Bypass Synchronous PowerOnDigital for SRo, CK5, CK40 Default: 1 bypass POD
    .LvdsReceiverPPEnable        (LvdsReceiverPPEnable),         // Default:0 Disable
    .ExternalRazSignalEnable     (ExternalRazSignalEnable),      // Default: 0 Disable
    .InternalRazSignalEnable     (InternalRazSignalEnable),      // Default: 1 Enable
    .ExternalTriggerEnable       (ExternalTriggerEnable),        // Default: 1 Enable
    .TriggerNor64OrDirectSelect  (TriggerNor64OrDirectSelect),   // Default: 1 Nor64
    .TriggerOutputEnable         (TriggerOutputEnable),          // Default: 1 Enable
    .TriggerToWriteSelect        (TriggerToWriteSelect),         // Default: 111 all
    .Dac2Vth                     (Dac2Vth),                      // MSB->LSB
    .Dac1Vth                     (Dac1Vth),
    .Dac0Vth                     (Dac0Vth),
    .DacEnable                   (DacEnable),
    .DacPPEnable                 (DacPPEnable),
    .BandGapEnable               (BandGapEnable),
    .BandGapPPEnable             (BandGapPPEnable),
    .ChipID                      (ChipID),
    .ChannelDiscriminatorMask    (ChannelDiscriminatorMask),     // MSB correspones to Channel 63
    .LatchedOrDirectOutput       (LatchedOrDirectOutput),        // Default: 1 Latched
    .Discriminator1PPEnable      (Discriminator1PPEnable),
    .Discriminator2PPEnable      (Discriminator2PPEnable),
    .Discriminator0PPEnable      (Discriminator0PPEnable),
    .OTAqPPEnable                (OTAqPPEnable),
    .OTAqEnable                  (OTAqEnable),
    .Dac4bitPPEnable             (Dac4bitPPEnable),
    .ChannelAdjust               (ChannelAdjust),                // MSB to LSB from channel0 to channel 63
    .HighGainShaperFeedbackSelect(HighGainShaperFeedbackSelect), // Default: 10
    .ShaperOutLowGainOrHighGain  (ShaperOutLowGainOrHighGain),   // Default: 0 High gain
    .WidlarPPEnable              (WidlarPPEnable),               // Default: 0 Disable
    .LowGainShaperFeedbackSelect (LowGainShaperFeedbackSelect),  // Default: 101
    .LowGainShaperPPEnable       (LowGainShaperPPEnable),        // Default: 0
    .HighGainShaperPPEnable      (HighGainShaperPPEnable),       // Default: 0
    .GainBoostEnable             (GainBoostEnable),              // Default: 1
    .PreAmplifierPPEnable        (PreAmplifierPPEnable),         // Default: 0
    .CTestChannel                (CTestChannel),
    .ReadScopeChannel            (ReadScopeChannel),
    // *** Pins
    .SR_RSTB                     (SR_RSTB),                      // Selected Register Reset
    .SR_CK                       (SR_CK),                        // Selected Register Clock
    .SR_IN                       (SR_IN)                         // Selected Register Input
    );

  wire StartReadout;
  wire EndReadout;
  wire AsicDataout;
  wire TransmitOn;
  Redundancy ReadOutChannelSelect (
    .ReadoutChannelSelect(ReadoutChannelSelect),
    //*** Readout control
    .StartReadout        (StartReadout),
    .EndReadout          (EndReadout),
    .Dout                (AsicDataout),
    .TransmitOn          (TransmitOn),
    //*** Pins
    // Readout
    .START_READOUT1      (START_READOUT1),
    .START_READOUT2      (START_READOUT2),
    .END_READOUT1        (END_READOUT1),
    .END_READOUT2        (END_READOUT2),
    // Data
    .DOUT1B              (DOUT1B),
    .DOUT2B              (DOUT2B),
    .TRANSMITON1B        (TRANSMITON1B),
    .TRANSMITON2B        (TRANSMITON2B)
    );

  wire ReadDone;
  wire MicrorocDataEnable;
  wire [15:0] MicrorocData;
  AsicRamReadout ReadOnChipRam(
    .Clk(Clk),
    .reset_n(reset_n),
    .Dout(AsicDataout), //pin Active L
    .TransmitOn(TransmitOn),//pin  Active L
    //------fifo access-----------//
    .ext_fifo_full(ExternalFifoFull),
    .parallel_data(MicrorocData),
    .parallel_data_en(MicrorocDataEnable)
    );

  /*wire RAZ_CHN;
  wire ForceExternalRaz;
  ExternalRazGenerate ExternalRazGen(
  .Clk                 (Clk),
  .reset_n             (reset_n),
  .TriggerIn           (TriggerIn),
  .ExternalRaz_en      (ExternalRazSignalEnable),
  .ExternalRazDelayTime(ExternalRazDelayTime),
  .RazMode             (RazMode),
  .ForceRaz            (ForceExternalRaz),
  .RAZ_CHN             (RAZ_CHN)
 );

  HoldGenerate HoldGen(
  .Clk              (Clk),
  .SyncClk          (SyncClk),
  .reset_n          (reset_n),
  .TriggerIn        (TriggerIn),
  .HoldEnable       (HoldEnable),
  .HoldDelay        (HoldDelay),
  .HoldTime         (HoldTime),
  .HoldOut          (HOLD)
    );*/

  wire PowerOnAnalog;
  wire PowerOnDigital;
  wire PowerOnDac;
  wire PowerOnAdc;
  wire DataTransmitDone;
  assign DataTransmitDone = ~nPKTEND;
  DaqControl MicrorocDaq
  (
    .Clk                   (Clk),         //40M
    .reset_n               (MicrorocReset_n),
    .DaqSelect             (DaqSelect),
    .UsbAcqStart           (AcqStart),
    .UsbStartStop          (UsbStartStop),
    .StartEnable           (StartEnable),
    .EndReadout            (EndReadout),
    .StartReadout          (StartReadout),
    .CHIPSATB              (CHIPSATB),
    .RESET_B               (RESET_B),
    .START_ACQ             (START_ACQ),
    .PWR_ON_A              (PowerOnAnalog),
    .PWR_ON_D              (PowerOnDigital),
    .PWR_ON_ADC            (PowerOnAdc),
    .PWR_ON_DAC            (PowerOnDac),
    .SCurveForceExternalRaz(SCurveForceExternalRaz),
    .ForceExternalRaz      (ForceExternalRaz),
    .AcquisitionTime       (AcquisitionStartTime),
    .EndHoldTime           (EndHoldTime),
    .OnceEnd               (OnceEnd),
    .AllDone               (TestDone),
    .DataTransmitDone      (DataTransmitDone),
    .UsbFifoEmpty          (ExternalFifoEmpty),
    .MicrorocData          (MicrorocData),//Acquired data
    .MicrorocData_en       (MicrorocDataEnable),
    .DaqData               (ExternalFifoData),//Data output
    .DaqData_en            (ExternalFifoDataEnable),
    .ExternalTrigger       (ExternalTriggerIn)
    );

  PowerOnControl PowerPulsingEnable (
    .PowerPulsingPinEnable(PowerPulsingPinEnable),
    .PowerOnAnalog        (PowerOnAnalog),
    .PowerOnDigital       (PowerOnDigital),
    .PowerOnAdc           (PowerOnAdc),
    .PowerOnDac           (PowerOnDac),
    .PWR_ON_A             (PWR_ON_A),
    .PWR_ON_D             (PWR_ON_D),
    .PWR_ON_ADC           (PWR_ON_ADC),
    .PWR_ON_DAC           (PWR_ON_DAC)
    );


endmodule
