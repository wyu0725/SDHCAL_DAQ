`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Yu Wang
//
// Create Date: 2018/05/23 15:50:13
// Design Name: SDHCAL DIF 1V0
// Module Name: SlowControlAndReadScopeSet
// Project Name: SDHCAL DIF 1V0
// Target Devices: XC7A100TFGG484-2L
// Tool Versions: Vivado 2018.1
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module SlowControlAndReadScopeSet(
  input Clk,
  input reset_n,
  input SlowClock,                          // Slow clock for MICROROC, typically 5M. It is worth to try 10M clock
  input MicrorocReset,
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
  input DacEnable,
  input DacPPEnable,
  input BandGapEnable,
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
  input [1:0] LowGainShaperFeedbackSelect,  // Default: 101
  input LowGainShaperPPEnable,              // Default: 0
  input HighGainShaperPPEnable,             // Default: 0
  input GainBoostEnable,                    // Default: 1
  input PreAmplifierPPEnable,               // Default: 0
  input [63:0] CTestChannel,
  input [63:0] ReadScopeChannel,
  // *** Pins
  output SR_RSTB,                           // Selected Register Reset
  output SR_CK,                             // Selected Register Clock
  output SR_IN                              // Selected Register Input
  );
  wire [15:0] ConfigFifoDataIn;
  wire ConfigFifoWriteEn;
  wire ConfigFifoReadEn;
  wire [15:0] ConfigFifoDataOut;
  wire ConfigFifoEmpty;

  ConfigParameterFIFO ConfigParameter (
    .rst(~reset_n),                  // input wire rst
    .wr_clk(Clk),            // input wire wr_clk
    .rd_clk(~SlowClock),            // input wire rd_clk
    .din(ConfigFifoDataIn),                  // input wire [15 : 0] din
    .wr_en(ConfigFifoWriteEn),              // input wire wr_en
    .rd_en(ConfigFifoReadEn),              // input wire rd_en
    .dout(ConfigFifoDataOut),                // output wire [15 : 0] dout
    .full(),                // output wire full
    .empty(ConfigFifoEmpty),              // output wire empty
    .wr_rst_busy(),  // output wire wr_rst_busy
    .rd_rst_busy()  // output wire rd_rst_busy
    );
  wire ConfigParameterGeneratorDone;
  ParameterGenerator ParameterGen (
    .Clk                         (Clk),
    .reset_n                     (reset_n),
    .SlowClock                   (SlowClock),                    // Slow clock for MICROROC, typically 5M. It is worth to try 10M clock
    .SlowControlOrReadScopeSelect(SlowControlOrReadScopeSelect),
    .ParameterLoadStart          (ParameterLoadStart),
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
    .ExternalFifoWriteEn         (ConfigFifoWriteEn),
    .ExternalFifoData            (ConfigFifoDataIn),
    .ParameterDone               (ConfigParameterGeneratorDone)
    );

  wire BitShiftOutStart;
  PulseSynchronous PulseSync(
    .ClkSource              (Clk),
    .reset_n                (reset_n),
    .PulseSource            (ConfigParameterGeneratorDone),
    .ClkDestination         (SlowClock),
    .PulseDestination       (BitShiftOutStart)
    );

  BitShiftOut ParameterShiftOut(
    .Clk5M                     (SlowClock),
    .reset_n                   (reset_n),
    .BitShiftOutStart          (BitShiftOutStart),
    .ExternalFifoReadEn        (ConfigFifoReadEn),
    .ExternalFifoEmpty         (ConfigFifoEmpty),
    .ExternalFifoDataIn        (ConfigFifoDataOut),
    //*** Pins
    .SerialClock               (SR_CK),
    .SerialReset               (SR_RSTB),
    .SerialDataout             (SR_IN),
    .BitShiftDone              (ParameterLoadDone)
    );
endmodule
