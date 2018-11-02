`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Yu Wang
//
// Create Date: 2018/05/21 10:57:19
// Design Name: SDHCAL DIF 1V0
// Module Name: FPGA_Top
// Project Name: SDHCAL DIF 1V0
// Target Devices: XC7A100TFGG484-2l
// Tool Versions: Vivado 2018.1
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////
//
//                                                    `:/+:
//                                                 .odNmydMs
//                                               :hMNy: `dMh
//     ./+oo+-   -://////+oo`  `:/ooso/`       :dMNy.  .dMm-
//   /dNy/:/hM/ odyNMmssso+. +dNNd+/+yMM/    .hMMh- ..oNMd-
// `hMd-     -  ` .MMo      -m+sMN-   mMy   /NMN+ .yMMMNs`
// yMm.         `ymMMmddd+  .- dMd` -hMh.  yMMd- :NMMNy.
// NMh          .:NMh...`   .ymMMmdmds:   yMMm.  /dd+.    `
// dMm.    `+h`  :MM/         yMm-`      :MMN/         `oh-
// .hMNysydNd+   /MMdyyhdd`  `NMs        sMMN.       :yd+`
//   ./++/:.      ./++/:-`   -mm:        /MMMh:..-+ymd/`
//                                        +mMMMMMNdo-
//                                          .:/:-`
//
//////////////////////////////////////////////////////////////////
module FPGA_Top(
  //*** Clock and reset
  input Clk40M,
  input rst_n,
  //*** USB interface
  input CLKOUT,
  output IFCLK,
  input FLAGA,
  input FLAGB,
  input FLAGC,
  output SLCS,
  output SLOE,
  output SLRD,
  output SLWR,
  output PKTEND,
  output [1:0] FIFOADR,
  inout [15:0] FD,
  //*** External ADC interface
  input [11:0] ADC_DATA,
  input OTR,
  output ADC_CLK,
  //*** Microroc Pins
  // Chain1
  input Dout1b_A,
  input Dout2b_A,
  input TransmitOn1b_A,
  input TransmitOn2b_A,
  input ChipSatb_A,
  output TriggerExt_A,
  output StartAcq_A,
  output StartReadout1_A,
  output StartReadout2_A,
  input EndReadout1_A,
  input EndReadout2_A,
  output sr_rstb_A,
  output sr_ck_A,
  output sr_in_A,
  input sr_out_A,
  // Chain2
  input Dout1b_B,
  input Dout2b_B,
  input TransmitOn1b_B,
  input TransmitOn2b_B,
  input ChipSatb_B,
  output TriggerExt_B,
  output StartAcq_B,
  output StartReadout1_B,
  output StartReadout2_B,
  input EndReadout1_B,
  input EndReadout2_B,
  output sr_rstb_B,
  output sr_ck_B,
  output sr_in_B,
  input sr_out_B,
  // Chain3
  input Dout1b_C,
  input Dout2b_C,
  input TransmitOn1b_C,
  input TransmitOn2b_C,
  input ChipSatb_C,
  output TriggerExt_C,
  output StartAcq_C,
  output StartReadout1_C,
  output StartReadout2_C,
  input EndReadout1_C,
  input EndReadout2_C,
  output sr_rstb_C,
  output sr_ck_C,
  output sr_in_C,
  input sr_out_C,
  // Chain4
  input Dout1b_D,
  input Dout2b_D,
  input TransmitOn1b_D,
  input TransmitOn2b_D,
  input ChipSatb_D,
  output TriggerExt_D,
  output StartAcq_D,
  output StartReadout1_D,
  output StartReadout2_D,
  input EndReadout1_D,
  input EndReadout2_D,
  output sr_rstb_D,
  output sr_ck_D,
  output sr_in_D,
  input sr_out_D,
  // Chain5
  /*input Dout1b_E,
  input Dout2b_E,
  input TransmitOn1b_E,
  input TransmitOn2b_E,
  input ChipSatb_E,
  output TriggerExt_E,
  output StartAcq_E,
  output StartReadout1_E,
  output StartReadout2_E,
  input EndReadout1_E,
  input EndReadout2_E,
  output sr_rstb_E,
  output sr_ck_E,
  output sr_in_E,
  input sr_out_E,
  */
  // Command control signal
  output hold,
  output select,
  output reset_b,
  output rst_counterb,
  output pwr_on_d,
  output pwr_on_a,
  output pwr_on_adc,
  output pwr_on_dac,
  // LVDS
  output ck_5p,
  output ck_5n,
  output ck_40p,
  output ck_40n,
  output val_evtp,
  output val_evtn,
  output raz_chnp,
  output raz_chnn,
  // Test signal
  input out_trigger0b,
  input out_trigger1b,
  input out_trigger2b,
  // Trigger in out and clock in
  input EXT_TRIG_IN,
  output EXT_TRIG_OUT,
  input EXT_CLK_IN,
  output [3:0] TP,
  // TEST COLUMN and ROW
  output [2:0] COLUMN,
  output [2:0] ROW,
  // Calibration
  output nCS,
  output SCLK,
  output DIN,
  output SwitcherOn_A,
  output SwitcherOn_B,
  //*** LED
  output [7:0] LED
  );

  wire [3:0] MicrorocAcquisitionOnceDone;
  assign EXT_TRIG_OUT = |MicrorocAcquisitionOnceDone;

  wire Clk;
  wire Clk5M;
  wire SyncClk;
  wire reset_n;
  wire UsbIfclk;
  wire ClockGood;
  //---------- Clock Generator ----------//
  ClockManagement ClockGenerator(
    .Clk40M(Clk40M),
    .UsbClockout(CLKOUT),
    .rst_n(rst_n),
    .Clk(Clk),
    .Clk5M(Clk5M),
    .SyncClk(SyncClk),
    .IFCLK(IFCLK),
    .UsbIfclk(UsbIfclk),
    .reset_n(reset_n),
    .ClockGood(ClockGood)
    );
  assign LED[7] = ClockGood;

  //---------- USB2.0 instantiation ----------//
  wire UsbStartStop;
  wire [15:0] CommandWord;
  wire CommandWordEn;
  wire [15:0] ExternalFifoData;
  wire ExternalFifoDataReadEnable;
  wire ExternalFifoEmpty;
  wire ExternalFifoFull;
  usb_synchronous_slavefifo usb_cy7c68013A(

    .IFCLK(IFCLK),
    .FLAGA(FLAGA),                   // EP6 Empty flag
    .FLAGB(FLAGB),                   // EP6 full flag
    .FLAGC(FLAGC),                   // EP2 Empty flag
    .nSLCS(SLCS),                    // Chip select
    .nSLOE(SLOE),                    // READ
    .nSLRD(SLRD),                    // READ
    .nSLWR(SLWR),                    // WRITE
    .nPKTEND(PKTEND),                // WRITE
    .FIFOADR(FIFOADR),
    .FD_BUS(FD),

    .Acq_Start_Stop(UsbStartStop), // maybe from other Clock domain
    .Ctr_rd_en(CommandWordEn),
    .ControlWord(CommandWord),

    .in_from_ext_fifo_dout(ExternalFifoData),
    .in_from_ext_fifo_empty(ExternalFifoEmpty),
    .out_to_ext_fifo_rd_en(ExternalFifoDataReadEnable)
    );
  reg nPKTEND_r1;
  reg nPKTEND_r2;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      nPKTEND_r1 <= 1'b1;
      nPKTEND_r2 <= 1'b1;
    end
    else begin
      nPKTEND_r1 <= PKTEND;
      nPKTEND_r2 <= nPKTEND_r1;
    end
  end
  wire nPKTEND;
  BUFG BUFG_NPKTEND (
    .O(nPKTEND), // 1-bit output: Clock output
    .I(nPKTEND_r2)  // 1-bit input: Clock input
    );

  (* ASYNC_REG = "true" *)reg ExternalFifoEmptySync1;
  reg ExternalFifoEmptySync2;
  wire ExternalFifoEmptySync;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      ExternalFifoEmptySync1 <= 1'b0;
      ExternalFifoEmptySync2 <= 1'b0;
    end
    else begin
      ExternalFifoEmptySync1 <= ExternalFifoEmpty;
      ExternalFifoEmptySync2 <= ExternalFifoEmptySync1;
    end
  end
    BUFG BUFG_EXTERNAL_FIFO_EMPTY (
    .O(ExternalFifoEmptySync), // 1-bit output: Clock output
    .I(ExternalFifoEmptySync2)  // 1-bit input: Clock input
    );

  wire ExternalDataFifoFull;
  wire [15:0] OutTestData;
  wire OutTestDataEnable;
  wire CommandResetDataFifo;
  ExternalDataFifo UsbDataFifo (
    .rst(~reset_n || CommandResetDataFifo),                  // input wire rst
    .wr_clk(~Clk),            // input wire wr_clk
    .rd_clk(~IFCLK),            // input wire rd_clk
    .din(OutTestData),                  // input wire [15 : 0] din
    .wr_en(OutTestDataEnable),              // input wire wr_en
    .rd_en(ExternalFifoDataReadEnable),              // input wire rd_en
    .dout(ExternalFifoData),                // output wire [15 : 0] dout
    .full(ExternalFifoFull),                // output wire full
    .empty(ExternalFifoEmpty),              // output wire empty
    .wr_rst_busy(),  // output wire wr_rst_busy
    .rd_rst_busy()  // output wire rd_rst_busy
    );

  //---------- Command Interpreter ----------//
  wire [3:0] AsicChainSelect;
  wire [3:0] CommandAsicNumberSet;
  wire [3:0] CommandSCurveTestAsicSelect;
  wire CommandMicrorocSlowControlOrReadScopeSelect;
  wire CommandMicrorocConfigurationParameterLoadStart;
  wire [1:0] CommandMicrorocDataoutChannelSelect;
  wire [1:0] CommandMicrorocTransmitOnChannelSelect;
  wire CommandMicrorocStartReadoutChannelSelect;
  wire CommandMicrorocEndReadoutChannelSelect;
  wire [1:0] CommandMicrorocInternalRazSignalLength;
  wire CommandMicrorocCkMux;
  wire CommandMicrorocLvdsReceiverPPEnable;
  wire CommandMicrorocExternalRazSignalEnable;
  wire CommandMicrorocInternalRazSignalEnable;
  wire CommandMicrorocExternalTriggerEnable;
  wire CommandMicrorocTriggerNor64OrDirectSelect;
  wire CommandMicrorocTriggerOutputEnable;
  wire [2:0] CommandMicrorocTriggerToWriteSelect;
  wire [9:0] CommandMicrorocDac2Vth;
  wire [9:0] CommandMicrorocDac1Vth;
  wire [9:0] CommandMicrorocDac0Vth;
  wire CommandMicrorocDacEnable;
  wire CommandMicrorocDacPPEnable;
  wire CommandMicrorocBandGapEnable;
  wire CommandMicrorocBandGapPPEnable;
  wire [7:0] CommandMicrorocChipID;
  wire [191:0] CommandMicrorocChannelDiscriminatorMask;
  wire CommandMicrorocLatchedOrDirectOutput;
  wire CommandMicrorocDiscriminator2PPEnable;
  wire CommandMicrorocDiscriminator1PPEnable;
  wire CommandMicrorocDiscriminator0PPEnable;
  wire CommandMicrorocOTAqPPEnable;
  wire CommandMicrorocOTAqEnable;
  wire CommandMicrorocDac4bitPPEnable;
  wire [255:0] CommandChannelAdjust;
  wire [1:0] CommandMicrorocHighGainShaperFeedbackSelect;
  wire CommandMicrorocShaperOutLowGainOrHighGain;
  wire CommandMicrorocWidlarPPEnable;
  wire [1:0] CommandMicrorocLowGainShaperFeedbackSelect;
  wire CommandMicrorocLowGainShaperPPEnable;
  wire CommandMicrorocHighGainShaperPPEnable;
  wire CommandMicrorocGainBoostEnable;
  wire CommandMicrorocPreAmplifierPPEnable;
  wire [63:0] CommandMicrorocCTestChannel;
  wire [63:0] CommandMicrorocReadScopeChannel;
  wire CommandMicrorocReadRedundancy;
  wire [1:0] CommandMicrorocExternalRazMode;
  wire [3:0] CommandMicrorocExternalRazDelayTime;
  wire CommandMicrorocResetTimeStamp;
  wire CommandMicrorocPowerPulsingPinEnable;
  wire [3:0] CommandMicrorocEndReadoutParameter;
  wire [3:0] CommandMicrorocAcquisitionStartStop;

  wire CommandSCurveTestStartStop;
  wire SCurveTestDone;
  wire CommandAdcStartStop;
  wire [3:0] CommandModeSelect;
  wire [1:0] CommandDacSelect;
  wire [9:0] SCurveTestDacStart;
  wire [9:0] SCurveTestDacStop;
  wire [9:0] SCurveTestDacStep;
  wire SCurveTestSingleOr64Channel;
  wire SCurveTestCTestOrInput;
  wire [5:0] SCurveTestSingleTestChannel;
  wire [15:0] SCurveTestTriggerCountMax;
  wire [3:0] SCurveTestTriggerDelay;
  wire SCurveTestUnmaskAllChannel;
  wire CommandSCurveTestInnerClockEnable;
  wire SCurveTestTriggerEfficiencyOrCountEfficiency;
  wire [15:0] SCurveTestCounterMax;
  wire ForceMicrorocAcqReset;
  wire [3:0] AdcStartDelayTime;
  wire [7:0] AdcDataNumber;
  wire [3:0] TriggerCoincidence;
  wire [7:0] HoldDelay;
  wire [15:0] HoldTime;
  wire HoldEnable;
  wire [15:0] EndHoldTime;
  wire DaqSelect;
  wire [15:0] CommandMicrorocStartAcquisitionTime;
  wire ResetSCurveTest;
  wire [19:0] CommandSCurveTestTriggerSuppressWidth;

  wire CommandChipFullEnable;
  wire CommandAutoDaqAcquisitionModeSelect;
  wire CommandAutoDaqTriggerModeSelect;
  wire [15:0] CommandAutoDaqTriggerDelayTime;
  wire [15:0] CommandInternalSynchronousClockPeriod;
  wire CommandAutoCalibrationDacPowerDown;
  wire CommandAutoCalibrationDacSpeed;
  wire [11:0] CommandAutoCalibrationDac1Data;
  wire [11:0] CommandAutoCalibrationDac2Data;
  wire [1:0] CommandAutoCalibrationDacSelect;
  wire CommandAutoCalibrationDacLoadStart;
  wire [15:0] CommandAutoCalibrationSwitcherOnTime;
  wire [1:0] CommandAutoCalibrationSwitcherSelect;

  CommandInterpreter Command(
    .Clk(Clk),
    .IFCLK(IFCLK),
    .reset_n(reset_n),
    // USB interface
    .CommandWordEn(CommandWordEn),
    .CommandWord(CommandWord),
    //--- Command ---//
    .AcquisitionStartStop(CommandMicrorocAcquisitionStartStop),
    .ResetDataFifo(CommandResetDataFifo),
    .AsicChainSelect(AsicChainSelect), // Considering the expand board in the future,
    //  the max ASIC chain is set to 16
    .AsicNumberSet(CommandAsicNumberSet),
    .SCurveTestAsicSelect(CommandSCurveTestAsicSelect),
    //*** Microorc Parameter
    // MICROROC slow control parameter
    .MicrorocSlowControlOrReadScopeSelect(CommandMicrorocSlowControlOrReadScopeSelect),
    .MicrorocParameterLoadStart(CommandMicrorocConfigurationParameterLoadStart),
    .MicrorocDataoutChannelSelect(CommandMicrorocDataoutChannelSelect),
    .MicrorocTransmitOnChannelSelect(CommandMicrorocTransmitOnChannelSelect),
    // ChipSatbEnable
    .MicrorocStartReadoutChannelSelect(CommandMicrorocStartReadoutChannelSelect),
    .MicrorocEndReadoutChannelSelect(CommandMicrorocEndReadoutChannelSelect),
    // [1:0] NC
    .MicrorocInternalRazSignalLength(CommandMicrorocInternalRazSignalLength),
    .MicrorocCkMux(CommandMicrorocCkMux),
    .MicrorocLvdsReceiverPPEnable(CommandMicrorocLvdsReceiverPPEnable),
    .MicrorocExternalRazSignalEnable(CommandMicrorocExternalRazSignalEnable),
    .MicrorocInternalRazSignalEnable(CommandMicrorocInternalRazSignalEnable),
    .MicrorocExternalTriggerEnable(CommandMicrorocExternalTriggerEnable),
    .MicrorocTriggerNor64OrDirectSelect(CommandMicrorocTriggerNor64OrDirectSelect),
    .MicrorocTriggerOutputEnable(CommandMicrorocTriggerOutputEnable),
    .MicrorocTriggerToWriteSelect(CommandMicrorocTriggerToWriteSelect),
    .MicrorocDac2Vth(CommandMicrorocDac2Vth),
    .MicrorocDac1Vth(CommandMicrorocDac1Vth),
    .MicrorocDac0Vth(CommandMicrorocDac0Vth),
    .MicrorocDacEnable(CommandMicrorocDacEnable),
    .MicrorocDacPPEnable(CommandMicrorocDacPPEnable),
    .MicrorocBandGapEnable(CommandMicrorocBandGapEnable),
    .MicrorocBandGapPPEnable(CommandMicrorocBandGapPPEnable),
    .MicrorocChipID(CommandMicrorocChipID),
    .MicrorocChannelDiscriminatorMask(CommandMicrorocChannelDiscriminatorMask),
    .MicrorocLatchedOrDirectOutput(CommandMicrorocLatchedOrDirectOutput),
    .MicrorocDiscriminator2PPEnable(CommandMicrorocDiscriminator2PPEnable),
    .MicrorocDiscriminator1PPEnable(CommandMicrorocDiscriminator1PPEnable),
    .MicrorocDiscriminator0PPEnable(CommandMicrorocDiscriminator0PPEnable),
    .MicrorocOTAqPPEnable(CommandMicrorocOTAqPPEnable),
    .MicrorocOTAqEnable(CommandMicrorocOTAqEnable),
    .MicrorocDac4bitPPEnable(CommandMicrorocDac4bitPPEnable),
    .MicrorocChannelAdjust(CommandChannelAdjust),
    .MicrorocHighGainShaperFeedbackSelect(CommandMicrorocHighGainShaperFeedbackSelect),
    .MicrorocShaperOutLowGainOrHighGain(CommandMicrorocShaperOutLowGainOrHighGain),
    .MicrorocWidlarPPEnable(CommandMicrorocWidlarPPEnable),
    .MicrorocLowGainShaperFeedbackSelect(CommandMicrorocLowGainShaperFeedbackSelect),
    .MicrorocLowGainShaperPPEnable(CommandMicrorocLowGainShaperPPEnable),
    .MicrorocHighGainShaperPPEnable(CommandMicrorocHighGainShaperPPEnable),
    .MicrorocGainBoostEnable(CommandMicrorocGainBoostEnable),
    .MicrorocPreAmplifierPPEnable(CommandMicrorocPreAmplifierPPEnable),
    .MicrorocCTestChannel(CommandMicrorocCTestChannel),
    .MicrorocReadScopeChannel(CommandMicrorocReadScopeChannel),
    .MicrorocReadRedundancy(CommandMicrorocReadRedundancy),// To redundancy module
    .MicrorocExternalRazMode(CommandMicrorocExternalRazMode),
    .MicrorocExternalRazDelayTime(CommandMicrorocExternalRazDelayTime),

    // Microroc Control
    .MicrorocResetTimeStamp(CommandMicrorocResetTimeStamp),
    .MicrorocPowerPulsingPinEnable(CommandMicrorocPowerPulsingPinEnable),
    .MicrorocEndReadoutParameter(CommandMicrorocEndReadoutParameter),

    //*** Acquisition Control
    .MicrorocStartAcquisitionTime(CommandMicrorocStartAcquisitionTime),
    // Mode Select
    .ModeSelect(CommandModeSelect),
    .DacSelect(CommandDacSelect),
    // Acquisition parameter
    .ChipFullEnable(CommandChipFullEnable),
    .AutoDaqAcquisitionModeSelect(CommandAutoDaqAcquisitionModeSelect),
    .AutoDaqTriggerModeSelect(CommandAutoDaqTriggerModeSelect),
    .AutoDaqTriggerDelayTime(CommandAutoDaqTriggerDelayTime),
    // Sweep Dac parameter
    .StartDac(SCurveTestDacStart),
    .EndDac(SCurveTestDacStop),
    .DacStep(SCurveTestDacStep),
    // SCurve Test Port
    .SingleOr64Channel(SCurveTestSingleOr64Channel),
    .CTestOrInput(SCurveTestCTestOrInput),
    .SingleTestChannel(SCurveTestSingleTestChannel),
    .TriggerCountMax(SCurveTestTriggerCountMax),
    .TriggerDelay(SCurveTestTriggerDelay),
    .SweepTestStartStop(CommandSCurveTestStartStop),
    .UnmaskAllChannel(SCurveTestUnmaskAllChannel),
    .SCurveTestInnerClockEnable(CommandSCurveTestInnerClockEnable),
    // Count Efficiency
    .TriggerEfficiencyOrCountEfficiency(SCurveTestTriggerEfficiencyOrCountEfficiency),
    .CounterMax(SCurveTestCounterMax),
    .SweepTestDone(SCurveTestDone),
    .UsbFifoEmpty(ExternalFifoEmpty),
    // Sweep Acq
    .SweepAcqMaxPackageNumber(),
    // Reset Microroc
    .ForceMicrorocAcqReset(ForceMicrorocAcqReset),
    // ADC Control
    .AdcStartStop(CommandAdcStartStop),
    .AdcStartDelayTime(AdcStartDelayTime),
    .AdcDataNumber(AdcDataNumber),
    .TriggerCoincidence(TriggerCoincidence),
    .HoldDelay(HoldDelay),
    .HoldTime(HoldTime),
    .HoldEnable(HoldEnable),
    // Slave DAQ
    .EndHoldTime(EndHoldTime),
    .DaqSelect(DaqSelect),
    // Column and row select
    .ColumnSelect(COLUMN),
    .RowSelect(ROW),
    .ResetSCurveTest(ResetSCurveTest),
    .SCurveTestTriggerSuppressWidth(CommandSCurveTestTriggerSuppressWidth),
    // AutoCalibration port
    .InternalSynchronousClockPeriod(CommandInternalSynchronousClockPeriod),
    .AutoCalibrationDacPowerDown(CommandAutoCalibrationDacPowerDown),
    .AutoCalibrationDacSpeed(CommandAutoCalibrationDacSpeed),
    .AutoCalibrationDac1Data(CommandAutoCalibrationDac1Data),
    .AutoCalibrationDac2Data(CommandAutoCalibrationDac2Data),
    .AutoCalibrationDacSelect(CommandAutoCalibrationDacSelect),
    .AutoCalibrationDacLoadStart(CommandAutoCalibrationDacLoadStart),// pulse
    .AutoCalibrationSwitcherOnTime(CommandAutoCalibrationSwitcherOnTime),
    .AutoCalibrationSwitcherSelect(CommandAutoCalibrationSwitcherSelect),
    // LED
    .LED(LED[3:0])
    );

  //---------- Configuration Parameter Distributiom ----------//
  localparam ASIC_CHAIN_NUMBER = 4;
  // Controled by AcquisitionControl module
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocSlowControlOrReadScopeSelectChain;
  wire MicrorocSlowControlOrReadScopeSelect;
  wire MicrorocConfigurationParameterLoadStart;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocConfigurationParameterLoadStartChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocConfigurationParameterLoadDoneChain;
  wire MicrorocConfigurationParameterLoadDone;
  wire [9:0] MicrorocDac0Vth;
  wire [9:0] MicrorocDac1Vth;
  wire [9:0] MicrorocDac2Vth;
  wire [10*ASIC_CHAIN_NUMBER - 1:0] MicrorocDac0VthChain;
  wire [10*ASIC_CHAIN_NUMBER - 1:0] MicrorocDac1VthChain;
  wire [10*ASIC_CHAIN_NUMBER - 1:0] MicrorocDac2VthChain;
  wire [63:0] MicrorocCTestChannel;
  wire [64*ASIC_CHAIN_NUMBER - 1:0] MicrorocCTestChannelChain;
  wire [191:0] MicrorocChannelDiscriminatorMask;
  wire [192*ASIC_CHAIN_NUMBER - 1:0] MicrorocChannelDiscriminatorMaskChain;

  // Controled directly by USB
  wire [2*ASIC_CHAIN_NUMBER - 1:0] MicrorocDataoutChannelSelectChain;
  wire [2*ASIC_CHAIN_NUMBER - 1:0] MicrorocTransmitOnChannelSelectChain;
  // ChipSatbEnable
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocStartReadoutChannelSelectChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocEndReadoutChannelSelectChain;
  // [1:0] NC
  wire [2*ASIC_CHAIN_NUMBER - 1:0] MicrorocInternalRazSignalLengthChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocCkMuxChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocLvdsReceiverPPEnableChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocExternalRazSignalEnableChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocInternalRazSignalEnableChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocExternalTriggerEnableChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocTriggerNor64OrDirectSelectChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocTriggerOutputEnableChain;
  wire [3*ASIC_CHAIN_NUMBER - 1:0] MicrorocTriggerToWriteSelectChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocDacEnableChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocDacPPEnableChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocBandGapEnableChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocBandGapPPEnableChain;
  wire [8*ASIC_CHAIN_NUMBER - 1:0] MicrorocChipIDChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocLatchedOrDirectOutputChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocDiscriminator2PPEnableChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocDiscriminator1PPEnableChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocDiscriminator0PPEnableChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocOTAqPPEnableChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocOTAqEnableChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocDac4bitPPEnableChain;
  wire [256*ASIC_CHAIN_NUMBER - 1:0] MicrorocChannelAdjustChain;
  wire [2*ASIC_CHAIN_NUMBER - 1:0] MicrorocHighGainShaperFeedbackSelectChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocShaperOutLowGainOrHighGainChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocWidlarPPEnableChain;
  wire [2*ASIC_CHAIN_NUMBER - 1:0] MicrorocLowGainShaperFeedbackSelectChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocLowGainShaperPPEnableChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocHighGainShaperPPEnableChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocGainBoostEnableChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocPreAmplifierPPEnableChain;
  wire [64*ASIC_CHAIN_NUMBER - 1:0] MicrorocReadScopeChannelChain;
  wire [ASIC_CHAIN_NUMBER - 1:0] MicrorocReadRedundancyChain;// To redundancy module

  ConfigurationParameterDistribution
  #(
    .ASIC_CHAIN_NUMBER(4'd4)
  )
  ConfigurationSelect(
    .Clk(Clk),
    .reset_n(reset_n),
    .AsicChainSelect(AsicChainSelect),
    //*** Microorc Parameter
    // MICROROC slow control parameter
    .MicrorocSlowControlOrReadScopeSelect_Input(MicrorocSlowControlOrReadScopeSelect),
    .MicrorocParameterLoadStart_Input(MicrorocConfigurationParameterLoadStart),
    .MicrorocParameterLoadDone_Input(MicrorocConfigurationParameterLoadDoneChain),
    .MicrorocDataoutChannelSelect_Input(CommandMicrorocDataoutChannelSelect),
    .MicrorocTransmitOnChannelSelect_Input(CommandMicrorocTransmitOnChannelSelect),
    // ChipSatbEnable
    .MicrorocStartReadoutChannelSelect_Input(CommandMicrorocStartReadoutChannelSelect),
    .MicrorocEndReadoutChannelSelect_Input(CommandMicrorocEndReadoutChannelSelect),
    // [1:0] NC
    .MicrorocInternalRazSignalLength_Input(CommandMicrorocInternalRazSignalLength),
    .MicrorocCkMux_Input(CommandMicrorocCkMux),
    .MicrorocLvdsReceiverPPEnable_Input(CommandMicrorocLvdsReceiverPPEnable),
    .MicrorocExternalRazSignalEnable_Input(CommandMicrorocExternalRazSignalEnable),
    .MicrorocInternalRazSignalEnable_Input(CommandMicrorocInternalRazSignalEnable),
    .MicrorocExternalTriggerEnable_Input(CommandMicrorocExternalTriggerEnable),
    .MicrorocTriggerNor64OrDirectSelect_Input(CommandMicrorocTriggerNor64OrDirectSelect),
    .MicrorocTriggerOutputEnable_Input(CommandMicrorocTriggerOutputEnable),
    .MicrorocTriggerToWriteSelect_Input(CommandMicrorocTriggerToWriteSelect),
    .MicrorocDac2Vth_Input(MicrorocDac2Vth),
    .MicrorocDac1Vth_Input(MicrorocDac1Vth),
    .MicrorocDac0Vth_Input(MicrorocDac0Vth),
    .MicrorocDacEnable_Input(CommandMicrorocDacEnable),
    .MicrorocDacPPEnable_Input(CommandMicrorocDacPPEnable),
    .MicrorocBandGapEnable_Input(CommandMicrorocBandGapEnable),
    .MicrorocBandGapPPEnable_Input(CommandMicrorocBandGapPPEnable),
    .MicrorocChipID_Input(CommandMicrorocChipID),
    .MicrorocChannelDiscriminatorMask_Input(MicrorocChannelDiscriminatorMask),
    .MicrorocLatchedOrDirectOutput_Input(CommandMicrorocLatchedOrDirectOutput),
    .MicrorocDiscriminator2PPEnable_Input(CommandMicrorocDiscriminator2PPEnable),
    .MicrorocDiscriminator1PPEnable_Input(CommandMicrorocDiscriminator1PPEnable),
    .MicrorocDiscriminator0PPEnable_Input(CommandMicrorocDiscriminator0PPEnable),
    .MicrorocOTAqPPEnable_Input(CommandMicrorocOTAqPPEnable),
    .MicrorocOTAqEnable_Input(CommandMicrorocOTAqEnable),
    .MicrorocDac4bitPPEnable_Input(CommandMicrorocDac4bitPPEnable),
    .ChannelAdjust_Input(CommandChannelAdjust),
    .MicrorocHighGainShaperFeedbackSelect_Input(CommandMicrorocHighGainShaperFeedbackSelect),
    .MicrorocShaperOutLowGainOrHighGain_Input(CommandMicrorocShaperOutLowGainOrHighGain),
    .MicrorocWidlarPPEnable_Input(CommandMicrorocWidlarPPEnable),
    .MicrorocLowGainShaperFeedbackSelect_Input(CommandMicrorocLowGainShaperFeedbackSelect),
    .MicrorocLowGainShaperPPEnable_Input(CommandMicrorocLowGainShaperPPEnable),
    .MicrorocHighGainShaperPPEnable_Input(CommandMicrorocHighGainShaperPPEnable),
    .MicrorocGainBoostEnable_Input(CommandMicrorocGainBoostEnable),
    .MicrorocPreAmplifierPPEnable_Input(CommandMicrorocPreAmplifierPPEnable),
    .MicrorocCTestChannel_Input(MicrorocCTestChannel),
    .MicrorocReadScopeChannel_Input(CommandMicrorocReadScopeChannel),
    .MicrorocReadRedundancy_Input(CommandMicrorocReadRedundancy),// To redundancy module
    //*** Microorc Parameter output
    // MICROROC slow control parameter
    .MicrorocSlowControlOrReadScopeSelect_Output(MicrorocSlowControlOrReadScopeSelectChain),
    .MicrorocParameterLoadStart_Output(MicrorocConfigurationParameterLoadStartChain),
    .MicrorocParameterLoadDone_Output(MicrorocConfigurationParameterLoadDone),
    .MicrorocDataoutChannelSelect_Output(MicrorocDataoutChannelSelectChain),
    .MicrorocTransmitOnChannelSelect_Output(MicrorocTransmitOnChannelSelectChain),
    // ChipSatbEnable
    .MicrorocStartReadoutChannelSelect_Output(MicrorocStartReadoutChannelSelectChain),
    .MicrorocEndReadoutChannelSelect_Output(MicrorocEndReadoutChannelSelectChain),
    // [1:0] NC
    .MicrorocInternalRazSignalLength_Output(MicrorocInternalRazSignalLengthChain),
    .MicrorocCkMux_Output(MicrorocCkMuxChain),
    .MicrorocLvdsReceiverPPEnable_Output(MicrorocLvdsReceiverPPEnableChain),
    .MicrorocExternalRazSignalEnable_Output(MicrorocExternalRazSignalEnableChain),
    .MicrorocInternalRazSignalEnable_Output(MicrorocInternalRazSignalEnableChain),
    .MicrorocExternalTriggerEnable_Output(MicrorocExternalTriggerEnableChain),
    .MicrorocTriggerNor64OrDirectSelect_Output(MicrorocTriggerNor64OrDirectSelectChain),
    .MicrorocTriggerOutputEnable_Output(MicrorocTriggerOutputEnableChain),
    .MicrorocTriggerToWriteSelect_Output(MicrorocTriggerToWriteSelectChain),
    .MicrorocDac2Vth_Output(MicrorocDac2VthChain),
    .MicrorocDac1Vth_Output(MicrorocDac1VthChain),
    .MicrorocDac0Vth_Output(MicrorocDac0VthChain),
    .MicrorocDacEnable_Output(MicrorocDacEnableChain),
    .MicrorocDacPPEnable_Output(MicrorocDacPPEnableChain),
    .MicrorocBandGapEnable_Output(MicrorocBandGapEnableChain),
    .MicrorocBandGapPPEnable_Output(MicrorocBandGapPPEnableChain),
    .MicrorocChipID_Output(MicrorocChipIDChain),
    .MicrorocChannelDiscriminatorMask_Output(MicrorocChannelDiscriminatorMaskChain),
    .MicrorocLatchedOrDirectOutput_Output(MicrorocLatchedOrDirectOutputChain),
    .MicrorocDiscriminator2PPEnable_Output(MicrorocDiscriminator2PPEnableChain),
    .MicrorocDiscriminator1PPEnable_Output(MicrorocDiscriminator1PPEnableChain),
    .MicrorocDiscriminator0PPEnable_Output(MicrorocDiscriminator0PPEnableChain),
    .MicrorocOTAqPPEnable_Output(MicrorocOTAqPPEnableChain),
    .MicrorocOTAqEnable_Output(MicrorocOTAqEnableChain),
    .MicrorocDac4bitPPEnable_Output(MicrorocDac4bitPPEnableChain),
    .ChannelAdjust_Output(MicrorocChannelAdjustChain),
    .MicrorocHighGainShaperFeedbackSelect_Output(MicrorocHighGainShaperFeedbackSelectChain),
    .MicrorocShaperOutLowGainOrHighGain_Output(MicrorocShaperOutLowGainOrHighGainChain),
    .MicrorocWidlarPPEnable_Output(MicrorocWidlarPPEnableChain),
    .MicrorocLowGainShaperFeedbackSelect_Output(MicrorocLowGainShaperFeedbackSelectChain),
    .MicrorocLowGainShaperPPEnable_Output(MicrorocLowGainShaperPPEnableChain),
    .MicrorocHighGainShaperPPEnable_Output(MicrorocHighGainShaperPPEnableChain),
    .MicrorocGainBoostEnable_Output(MicrorocGainBoostEnableChain),
    .MicrorocPreAmplifierPPEnable_Output(MicrorocPreAmplifierPPEnableChain),
    .MicrorocCTestChannel_Output(MicrorocCTestChannelChain),
    .MicrorocReadScopeChannel_Output(MicrorocReadScopeChannelChain),
    .MicrorocReadRedundancy_Output(MicrorocReadRedundancyChain)// To redundancy module
    );

  //---------- Acquisition Control ----------//
  wire [15:0] MicrorocChain1Data;
  wire [15:0] MicrorocChain2Data;
  wire [15:0] MicrorocChain3Data;
  wire [15:0] MicrorocChain4Data;
  wire MicrorocChain1DataEnable;
  wire MicrorocChain2DataEnable;
  wire MicrorocChain3DataEnable;
  wire MicrorocChain4DataEnable;
  wire HoldSignal;
  wire [3:0] MicrorocAcquisitionUsbStartStop;
  wire SCurveTestForceExternalRaz;
  wire RamReadoutDone;
  wire ExternalSynchronousSignalIn;
  wire InternalSynchronousSignalIn;

  AcquisitionControl Acquisition(
    .Clk(Clk),
    .Clk5M(Clk5M),
    .reset_n(reset_n),
    .ResetSCurveTest_n(~ResetSCurveTest),
    .ForceMicrorocAcqReset_n(~ForceMicrorocAcqReset),
    .ModeSelect(CommandModeSelect),
    // Data interface
    // Microroc Chain data
    .MicrorocChain1Data(MicrorocChain1Data),
    .MicrorocChain1DataEnable(MicrorocChain1DataEnable),
    .MicrorocChain2Data(MicrorocChain2Data),
    .MicrorocChain2DataEnable(MicrorocChain2DataEnable),
    .MicrorocChain3Data(MicrorocChain3Data),
    .MicrorocChain3DataEnable(MicrorocChain3DataEnable),
    .MicrorocChain4Data(MicrorocChain4Data),
    .MicrorocChain4DataEnable(MicrorocChain4DataEnable),
    .EndReadout(RamReadoutDone),
    .ExternalFifoFull(ExternalFifoFull),
    .OutTestData(OutTestData),
    .OutTestDataEnable(OutTestDataEnable),
    // Configuration interface
    .CommandMicrorocConfigurationParameterLoad(CommandMicrorocConfigurationParameterLoadStart),
    .MicrorocConfigurationParameterLoad(MicrorocConfigurationParameterLoadStart),
    .MicrorocConfigurationDone(MicrorocConfigurationParameterLoadDone),
    // CTest channel
    .CommandMicrorocCTestChannel(CommandMicrorocCTestChannel),
    .MicrorocCTestChannel(MicrorocCTestChannel),
    // Channel discriminator mask
    .CommandMicrorocChannelDiscriminatorMask(CommandMicrorocChannelDiscriminatorMask),
    .MicrorocChannelDiscriminatorMask(MicrorocChannelDiscriminatorMask),
    // Vth DAC
    .CommandMicrorocVth0Dac(CommandMicrorocDac0Vth),
    .CommandMicrorocVth1Dac(CommandMicrorocDac1Vth),
    .CommandMicrorocVth2Dac(CommandMicrorocDac2Vth),
    .OutMicrorocVth0Dac(MicrorocDac0Vth),
    .OutMicrorocVth1Dac(MicrorocDac1Vth),
    .OutMicrorocVth2Dac(MicrorocDac2Vth),
    // SlowControl or ReadScope Select
    .CommandMicrorocSlowControlOrReadScopeSelect(CommandMicrorocSlowControlOrReadScopeSelect),
    .MicrorocSlowControlOrReadScopeSelect(MicrorocSlowControlOrReadScopeSelect),
    // Force External RAZ
    .ForceExternalRaz(SCurveTestForceExternalRaz),
    // StartStop
    .CommandMicrorocAcquisitionStartStop(|MicrorocAcquisitionUsbStartStop),
    .CommandSCurveTestStartStop(CommandSCurveTestStartStop),
    .CommandAdcStartStop(CommandAdcStartStop),
    .OutUsbStartStop(UsbStartStop),
    // Data Transmit signal
    .nPKTEND(nPKTEND),
    .TestDone(SCurveTestDone),

    //*** SCurve ports
    .TriggerEfficiencyOrCountEfficiency(SCurveTestTriggerEfficiencyOrCountEfficiency),
    .SingleTestChannel(SCurveTestSingleTestChannel),
    .SingleOr64Channel(SCurveTestSingleOr64Channel),
    .CTestOrInput(SCurveTestCTestOrInput),
    .TriggerCountMax(SCurveTestTriggerCountMax),
    .CounterMax(SCurveTestCounterMax),
    .StartDac(SCurveTestDacStart),
    .EndDac(SCurveTestDacStop),
    .DacStep(SCurveTestDacStep),
    .TriggerDelay(SCurveTestTriggerDelay),
    .AsicNumber(CommandAsicNumberSet[2:0]),
    .TestAsicNumber(CommandSCurveTestAsicSelect[2:0]),
    .UnmaskAllChannel(SCurveTestUnmaskAllChannel),
    .InnerClockEnable(CommandSCurveTestInnerClockEnable),
    .InternalSynchronousSignalIn(InternalSynchronousSignalIn),
    .TriggerSuppressWidth(CommandSCurveTestTriggerSuppressWidth),
    // Pins
    .SynchronousSignalIn(ExternalSynchronousSignalIn),
    .OutTrigger0b(out_trigger0b),
    .OutTrigger1b(out_trigger1b),
    .OutTrigger2b(out_trigger2b),

    //*** External ADC
    .HoldSignal(HoldSignal),
    .AdcStartDelay(AdcStartDelayTime),
    .AdcDataNumber(AdcDataNumber),
    // Pins
    .ADC_DATA(ADC_DATA),
    .ADC_OTR(OTR),
    .ADC_CLK(ADC_CLK)
    );

  //---------- Trigger Switcher ----------//
  wire ExternalTriggerIn;
  wire TriggerSelected;
  wire TriggerOr;
  wire TriggerAnd;
  TriggerSwitcher TriggerSwitcher(
    .SyncClk(SyncClk),
    .reset_n(reset_n),
    .TriggerSelect(TriggerCoincidence),
    .OutTrigger0b(out_trigger0b),
    .OutTrigger1b(out_trigger1b),
    .OutTrigger2b(out_trigger2b),
    .TriggerExt(EXT_TRIG_IN),
    .Trigger(TriggerSelected),
    .TriggerAnd(TriggerAnd),
    .TriggerOr(TriggerOr),
    .ExternalTriggerSyncOut(ExternalTriggerIn),
    .ExternalSyncSignalIn(EXT_CLK_IN),
    .SyncSignalOut(ExternalSynchronousSignalIn)
    );

  //---------- Auto Calibration Module ----------//
  AutoCalibrationSignalGen MicrorocAutoCaliSignalGen(
    .Clk(Clk),
    .reset_n(reset_n),
    .SynchronousClockPeroid(CommandInternalSynchronousClockPeriod),
    .SynchronousClock(InternalSynchronousSignalIn),
    // DAC control port
    .PowerDown(CommandAutoCalibrationDacPowerDown),
    .Speed(CommandAutoCalibrationDacSpeed),
    .Dac1Data(CommandAutoCalibrationDac1Data),
    .Dac2Data(CommandAutoCalibrationDac2Data),
    .LoadDacSelect(CommandAutoCalibrationDacSelect),
    .DacLoad(CommandAutoCalibrationDacLoadStart),
    // DAC PIN
    .nCS(nCS),
    .SCLK(SCLK),
    .DIN(DIN),
    // Switcher Control port
    .SwitcherOnTime(CommandAutoCalibrationSwitcherOnTime),
    .SwitcherSelect(CommandAutoCalibrationSwitcherSelect),
    // pin
    .SwitcherOn_A(SwitcherOn_A),
    .SwitcherOn_B(SwitcherOn_B)
    );

  //---------- Microroc Control ----------//
  wire [3:0] ForceExternalRaz;
  wire [3:0] ResetMicrorocDigitalPart;
  wire [3:0] PowerOnAnalog;
  wire [3:0] PowerOnDigital;
  wire [3:0] PowerOnAdc;
  wire [3:0] PowerOnDac;

  wire TRIG_EXT;
  MicrorocCommonControl
  #(
    .ASIC_CHAIN_NUMBER(4'd4)
  )
  CommonControlSignalGenerator(
    .Clk(Clk),
    .reset_n(reset_n & ~ForceMicrorocAcqReset),
    .SlowClock(Clk5M),
    .SyncClk(SyncClk),
    .TriggerIn(TriggerSelected),
    .TriggerOr(TriggerOr),
    .TriggerAnd(TriggerAnd),
    // Hold
    .HoldEnable(HoldEnable),
    .HoldDelay(HoldDelay),
    .HoldTime(HoldTime),
    .HoldSignal(HoldSignal),
    // ExternalRaz
    .RazMode(CommandMicrorocExternalRazMode),
    .ExternalRazSignalEnable(CommandMicrorocExternalRazSignalEnable),
    .ForceExternalRaz(ForceExternalRaz),
    .ExternalRazDelayTime(CommandMicrorocExternalRazDelayTime),
    // Select 1:Slow Control Register, 0:Read Register
    .SlowControlOrReadScopeSelect(MicrorocSlowControlOrReadScopeSelect),
    .SELECT(select),
    .reset_b(ResetMicrorocDigitalPart),
    .RESET_B(reset_b),
    .ResetTimeStamp(CommandMicrorocResetTimeStamp),
    .rst_counterb(rst_counterb),
    .DataTrigger(),
    .DataTriggerEnable(1'b0),
    .TRIG_EXT(TRIG_EXT),
    .pwr_on_a(PowerOnAnalog),
    .pwr_on_d(PowerOnDigital),
    .pwr_on_adc(PowerOnAdc),
    .pwr_on_dac(PowerOnDac),
    .OnceEnd(MicrorocAcquisitionOnceDone),
    .EndReadoutParameter(CommandMicrorocEndReadoutParameter),
    .RamReadoutDone(RamReadoutDone),
    .PWR_ON_A(pwr_on_a),
    .PWR_ON_D(pwr_on_d),
    .PWR_ON_ADC(pwr_on_adc),
    .PWR_ON_DAC(pwr_on_dac),
    .CK_5P(ck_5p),
    .CK_5N(ck_5n),
    .CK_40P(ck_40p),
    .CK_40N(ck_40n),
    .RAZ_CHNP(raz_chnp),
    .RAZ_CHNN(raz_chnn),
    .VAL_EVTP(val_evtp),
    .VAL_EVTN(val_evtn)
    );
  assign TriggerExt_A = TRIG_EXT;
  assign TriggerExt_B = TRIG_EXT;
  assign TriggerExt_C = TRIG_EXT;
  assign TriggerExt_D = TRIG_EXT;
  //*** Microorc Chain1
  MicrorocControl MicrorocChain1(
    .Clk(Clk),
    .reset_n(reset_n),
    .SlowClock(Clk5M),                          // Slow clock for MICROROC, typically 5M. It is worth to try 10M clock
    .Clk5M(Clk5M),                              // Clock for Microroc Configuration. If SlowClock is 5M, this clock shoudl be same as SlowClock
    //.SyncClk(SyncClk),                            // This clock is a fast clock to synchronous the TriggerIn signal to generate the hold signal
    // The 'jitter' of the hold signal depends on the peroid of this signal
    .MicrorocReset_n(~ForceMicrorocAcqReset),
    .SlowControlOrReadScopeSelect(MicrorocSlowControlOrReadScopeSelectChain[0]),
    .ParameterLoadStart(MicrorocConfigurationParameterLoadStartChain[0]),
    .ParameterLoadDone(MicrorocConfigurationParameterLoadDoneChain[0]),
    // *** Slow Contro Parameter, from MSB to LSB. These parameter is out from
    // the same secquence, pulsed by the SlowClock.
    .DataoutChannelSelect(MicrorocDataoutChannelSelectChain[1:0]),         // Default: 11 Valid
    .TransmitOnChannelSelect(MicrorocTransmitOnChannelSelectChain[1:0]),      // Default: 11 Valid
    .ChipSatbEnable(1'b1),                     // Default: 1 Valid
    .StartReadoutChannelSelect(MicrorocStartReadoutChannelSelectChain[0]),          // Default: 1 StartReadout1
    .EndReadoutChannelSelect(MicrorocEndReadoutChannelSelectChain[0]),            // Default: 1 EndReadout1
    .NC(2'b11),
    .InternalRazSignalLength(MicrorocInternalRazSignalLengthChain[1:0]),      // 00: 75ns, 01: 250ns, 10: 500ns, 11: 1us Default: 11
    .CkMux(MicrorocCkMuxChain[0]),                              // Bypass Synchronous PowerOnDigital for SRo, CK5, CK40 Default: 1 bypass POD
    .LvdsReceiverPPEnable(MicrorocLvdsReceiverPPEnableChain[0]),               // Default:0 Disable
    .ExternalRazSignalEnable(MicrorocExternalRazSignalEnableChain[0]),            // Default: 0 Disable
    .InternalRazSignalEnable(MicrorocInternalRazSignalEnableChain[0]),            // Default: 1 Enable
    .ExternalTriggerEnable(MicrorocExternalTriggerEnableChain[0]),              // Default: 1 Enable
    .TriggerNor64OrDirectSelect(MicrorocTriggerNor64OrDirectSelectChain[0]),         // Default: 1 Nor64
    .TriggerOutputEnable(MicrorocTriggerOutputEnableChain[0]),                // Default: 1 Enable
    .TriggerToWriteSelect(MicrorocTriggerToWriteSelectChain[2:0]),         // Default: 111 all
    .Dac2Vth(MicrorocDac2VthChain[9:0]),                      // MSB->LSB
    .Dac1Vth(MicrorocDac1VthChain[9:0]),
    .Dac0Vth(MicrorocDac0VthChain[9:0]),
    .DacEnable(MicrorocDacEnableChain[0]),                          // Default: 1 Enable
    .DacPPEnable(MicrorocDacPPEnableChain[0]),
    .BandGapEnable(MicrorocBandGapEnableChain[0]),                      // Default: 1 Enable
    .BandGapPPEnable(MicrorocBandGapPPEnableChain[0]),
    .ChipID(MicrorocChipIDChain[7:0]),
    .ChannelDiscriminatorMask(MicrorocChannelDiscriminatorMaskChain[191:0]),   // MSB correspones to Channel 63
    .LatchedOrDirectOutput(MicrorocLatchedOrDirectOutputChain[0]),              // Default: 1 Latched
    .Discriminator1PPEnable(MicrorocDiscriminator2PPEnableChain[0]),
    .Discriminator2PPEnable(MicrorocDiscriminator1PPEnableChain[0]),
    .Discriminator0PPEnable(MicrorocDiscriminator0PPEnableChain[0]),
    .OTAqPPEnable(MicrorocOTAqPPEnableChain[0]),
    .OTAqEnable(MicrorocOTAqEnableChain[0]),
    .Dac4bitPPEnable(MicrorocDac4bitPPEnableChain[0]),
    .ChannelAdjust(MicrorocChannelAdjustChain[255:0]),              // MSB to LSB from channel0 to channel 63
    .HighGainShaperFeedbackSelect(MicrorocHighGainShaperFeedbackSelectChain[1:0]), // Default: 10
    .ShaperOutLowGainOrHighGain(MicrorocShaperOutLowGainOrHighGainChain[0]),         // Default: 0 High gain
    .WidlarPPEnable(MicrorocWidlarPPEnableChain[0]),                     // Default: 0 Disable
    .LowGainShaperFeedbackSelect(MicrorocLowGainShaperFeedbackSelectChain[1:0]),  // Default: 10
    .LowGainShaperPPEnable(MicrorocLowGainShaperPPEnableChain[0]),              // Default: 0
    .HighGainShaperPPEnable(MicrorocHighGainShaperPPEnableChain[0]),             // Default: 0
    .GainBoostEnable(MicrorocGainBoostEnableChain[0]),                    // Default: 1
    .PreAmplifierPPEnable(MicrorocPreAmplifierPPEnableChain[0]),               // Default: 0
    .CTestChannel(MicrorocCTestChannelChain[63:0]),
    // ***64bit read register
    .ReadScopeChannel(MicrorocReadScopeChannelChain[63:0]),
    // *** Redundancy
    .PowerPulsingPinEnable(CommandMicrorocPowerPulsingPinEnable),
    .ReadoutChannelSelect(MicrorocReadRedundancyChain[0]),
    // *** Trigger In
    .ExternalTriggerIn(ExternalTriggerIn),
    .SCurveForceExternalRaz(SCurveTestForceExternalRaz),
    .ForceExternalRaz(ForceExternalRaz[0]),
    // *** Dataout interface
    .ExternalFifoData(MicrorocChain1Data),
    .ExternalFifoDataEnable(MicrorocChain1DataEnable),
    .TestDone(),
    .OnceEnd(MicrorocAcquisitionOnceDone[0]),
    .nPKTEND(nPKTEND),
    .ExternalFifoFull(ExternalFifoFull),
    .ExternalFifoEmpty(ExternalFifoEmptySync),
    // AcqControl
    .DaqSelect(DaqSelect),
    .AcqStart(CommandMicrorocAcquisitionStartStop[0]),
    .UsbStartStop(MicrorocAcquisitionUsbStartStop[0]),
    .StartEnable(RamReadoutDone),
    // Acquisition parameter
    .ChipFullEnable(CommandChipFullEnable),
    .AcquisitionModeSelect(CommandAutoDaqAcquisitionModeSelect),
    .TriggerModeSelect(CommandAutoDaqTriggerModeSelect),
    .TriggerDelayTime(CommandAutoDaqTriggerDelayTime),
    .AcquisitionStartTime(CommandMicrorocStartAcquisitionTime),
    .EndHoldTime(EndHoldTime),
    // *** Pins
    // Slow control and ReadScope
    .SR_RSTB(sr_rstb_A),                           // Selected Register Reset
    .SR_CK(sr_ck_A),                             // Selected Register Clock
    .SR_IN(sr_in_A),                             // Selected Register Input
    // input  SR_OUT, //Selected Register Output,Asic's daisy chain slow control output
    // Power pulsingPin
    .PWR_ON_D(PowerOnDigital[0]),
    .PWR_ON_A(PowerOnAnalog[0]),
    .PWR_ON_DAC(PowerOnDac[0]),
    .PWR_ON_ADC(PowerOnAdc[0]),
    // DAQ Control
    .START_ACQ(StartAcq_A),
    .RESET_B(ResetMicrorocDigitalPart[0]),
    .CHIPSATB(ChipSatb_A),
    .START_READOUT1(StartReadout1_A),
    .START_READOUT2(StartReadout2_A),
    .END_READOUT1(EndReadout1_A),
    .END_READOUT2(EndReadout2_A),
    // RAM readout
    .DOUT1B(Dout1b_A),
    .DOUT2B(Dout2b_A),
    .TRANSMITON1B(TransmitOn1b_A),
    .TRANSMITON2B(TransmitOn2b_A)
    );

  //*** Microroc Chain2
  MicrorocControl MicrorocChain2(
    .Clk(Clk),
    .reset_n(reset_n),
    .SlowClock(Clk5M),                          // Slow clock for MICROROC, typically 5M. It is worth to try 10M clock
    .Clk5M(Clk5M),                              // Clock for Microroc Configuration. If SlowClock is 5M, this clock shoudl be same as SlowClock
    //.SyncClk(SyncClk),                            // This clock is a fast clock to synchronous the TriggerIn signal to generate the hold signal
    // The 'jitter' of the hold signal depends on the peroid of this signal
    .MicrorocReset_n(~ForceMicrorocAcqReset),
    .SlowControlOrReadScopeSelect(MicrorocSlowControlOrReadScopeSelectChain[1]),
    .ParameterLoadStart(MicrorocConfigurationParameterLoadStartChain[1]),
    .ParameterLoadDone(MicrorocConfigurationParameterLoadDoneChain[1]),
    // *** Slow Contro Parameter, from MSB to LSB. These parameter is out from
    // the same secquence, pulsed by the SlowClock.
    .DataoutChannelSelect(MicrorocDataoutChannelSelectChain[3:2]),         // Default: 11 Valid
    .TransmitOnChannelSelect(MicrorocTransmitOnChannelSelectChain[3:2]),      // Default: 11 Valid
    .ChipSatbEnable(1'b1),                     // Default: 1 Valid
    .StartReadoutChannelSelect(MicrorocStartReadoutChannelSelectChain[1]),          // Default: 1 StartReadout1
    .EndReadoutChannelSelect(MicrorocEndReadoutChannelSelectChain[1]),            // Default: 1 EndReadout1
    .NC(2'b11),
    .InternalRazSignalLength(MicrorocInternalRazSignalLengthChain[3:2]),      // 00: 75ns, 01: 250ns, 10: 500ns, 11: 1us Default: 11
    .CkMux(MicrorocCkMuxChain[1]),                              // Bypass Synchronous PowerOnDigital for SRo, CK5, CK40 Default: 1 bypass POD
    .LvdsReceiverPPEnable(MicrorocLvdsReceiverPPEnableChain[1]),               // Default:0 Disable
    .ExternalRazSignalEnable(MicrorocExternalRazSignalEnableChain[1]),            // Default: 0 Disable
    .InternalRazSignalEnable(MicrorocInternalRazSignalEnableChain[1]),            // Default: 1 Enable
    .ExternalTriggerEnable(MicrorocExternalTriggerEnableChain[1]),              // Default: 1 Enable
    .TriggerNor64OrDirectSelect(MicrorocTriggerNor64OrDirectSelectChain[1]),         // Default: 1 Nor64
    .TriggerOutputEnable(MicrorocTriggerOutputEnableChain[1]),                // Default: 1 Enable
    .TriggerToWriteSelect(MicrorocTriggerToWriteSelectChain[5:3]),         // Default: 111 all
    .Dac2Vth(MicrorocDac2VthChain[19:10]),                      // MSB->LSB
    .Dac1Vth(MicrorocDac1VthChain[19:10]),
    .Dac0Vth(MicrorocDac0VthChain[19:10]),
    .DacEnable(MicrorocDacEnableChain[1]),                          // Default: 1 Enable
    .DacPPEnable(MicrorocDacPPEnableChain[1]),
    .BandGapEnable(MicrorocBandGapEnableChain[1]),                      // Default: 1 Enable
    .BandGapPPEnable(MicrorocBandGapPPEnableChain[1]),
    .ChipID(MicrorocChipIDChain[15:8]),
    .ChannelDiscriminatorMask(MicrorocChannelDiscriminatorMaskChain[383:192]),   // MSB correspones to Channel 63
    .LatchedOrDirectOutput(MicrorocLatchedOrDirectOutputChain[1]),              // Default: 1 Latched
    .Discriminator1PPEnable(MicrorocDiscriminator2PPEnableChain[1]),
    .Discriminator2PPEnable(MicrorocDiscriminator1PPEnableChain[1]),
    .Discriminator0PPEnable(MicrorocDiscriminator0PPEnableChain[1]),
    .OTAqPPEnable(MicrorocOTAqPPEnableChain[1]),
    .OTAqEnable(MicrorocOTAqEnableChain[1]),
    .Dac4bitPPEnable(MicrorocDac4bitPPEnableChain[1]),
    .ChannelAdjust(MicrorocChannelAdjustChain[511:256]),              // MSB to LSB from channel0 to channel 63
    .HighGainShaperFeedbackSelect(MicrorocHighGainShaperFeedbackSelectChain[3:2]), // Default: 10
    .ShaperOutLowGainOrHighGain(MicrorocShaperOutLowGainOrHighGainChain[1]),         // Default: 0 High gain
    .WidlarPPEnable(MicrorocWidlarPPEnableChain[1]),                     // Default: 0 Disable
    .LowGainShaperFeedbackSelect(MicrorocLowGainShaperFeedbackSelectChain[3:2]),  // Default: 10
    .LowGainShaperPPEnable(MicrorocLowGainShaperPPEnableChain[1]),              // Default: 0
    .HighGainShaperPPEnable(MicrorocHighGainShaperPPEnableChain[1]),             // Default: 0
    .GainBoostEnable(MicrorocGainBoostEnableChain[1]),                    // Default: 1
    .PreAmplifierPPEnable(MicrorocPreAmplifierPPEnableChain[1]),               // Default: 0
    .CTestChannel(MicrorocCTestChannelChain[127:64]),
    // ***64bit read register
    .ReadScopeChannel(MicrorocReadScopeChannelChain[127:64]),
    // *** Redundancy
    .PowerPulsingPinEnable(CommandMicrorocPowerPulsingPinEnable),
    .ReadoutChannelSelect(MicrorocReadRedundancyChain[1]),
    // *** Trigger In
    .ExternalTriggerIn(ExternalTriggerIn),
    .SCurveForceExternalRaz(SCurveTestForceExternalRaz),
    .ForceExternalRaz(ForceExternalRaz[1]),
    // *** Dataout interface
    .ExternalFifoData(MicrorocChain2Data),
    .ExternalFifoDataEnable(MicrorocChain2DataEnable),
    .TestDone(),
    .OnceEnd(MicrorocAcquisitionOnceDone[1]),
    .nPKTEND(nPKTEND),
    .ExternalFifoFull(ExternalFifoFull),
    .ExternalFifoEmpty(ExternalFifoEmptySync),
    // AcqControl
    .DaqSelect(DaqSelect),
    .AcqStart(CommandMicrorocAcquisitionStartStop[1]),
    .UsbStartStop(MicrorocAcquisitionUsbStartStop[1]),
    .StartEnable(RamReadoutDone),
    // Acquisition parameter
    .ChipFullEnable(CommandChipFullEnable),
    .AcquisitionModeSelect(CommandAutoDaqAcquisitionModeSelect),
    .TriggerModeSelect(CommandAutoDaqTriggerModeSelect),
    .TriggerDelayTime(CommandAutoDaqTriggerDelayTime),
    .AcquisitionStartTime(CommandMicrorocStartAcquisitionTime),
    .EndHoldTime(EndHoldTime),
    // *** Pins
    // Slow control and ReadScope
    .SR_RSTB(sr_rstb_B),                           // Selected Register Reset
    .SR_CK(sr_ck_B),                             // Selected Register Clock
    .SR_IN(sr_in_B),                             // Selected Register Input
    // input  SR_OUT, //Selected Register Output,Asic's daisy chain slow control output
    // Power pulsingPin
    .PWR_ON_D(PowerOnDigital[1]),
    .PWR_ON_A(PowerOnAnalog[1]),
    .PWR_ON_DAC(PowerOnDac[1]),
    .PWR_ON_ADC(PowerOnAdc[1]),
    // DAQ Control
    .START_ACQ(StartAcq_B),
    .RESET_B(ResetMicrorocDigitalPart[1]),
    .CHIPSATB(ChipSatb_B),
    .START_READOUT1(StartReadout1_B),
    .START_READOUT2(StartReadout2_B),
    .END_READOUT1(EndReadout1_B),
    .END_READOUT2(EndReadout2_B),
    // RAM readout
    .DOUT1B(Dout1b_B),
    .DOUT2B(Dout2b_B),
    .TRANSMITON1B(TransmitOn1b_B),
    .TRANSMITON2B(TransmitOn2b_B)
    );

  //*** Microroc Chain3
  MicrorocControl MicrorocChain3(
    .Clk(Clk),
    .reset_n(reset_n),
    .SlowClock(Clk5M),                          // Slow clock for MICROROC, typically 5M. It is worth to try 10M clock
    .Clk5M(Clk5M),                              // Clock for Microroc Configuration. If SlowClock is 5M, this clock shoudl be same as SlowClock
    //.SyncClk(SyncClk),                            // This clock is a fast clock to synchronous the TriggerIn signal to generate the hold signal
    // The 'jitter' of the hold signal depends on the peroid of this signal
    .MicrorocReset_n(~ForceMicrorocAcqReset),
    .SlowControlOrReadScopeSelect(MicrorocSlowControlOrReadScopeSelectChain[2]),
    .ParameterLoadStart(MicrorocConfigurationParameterLoadStartChain[2]),
    .ParameterLoadDone(MicrorocConfigurationParameterLoadDoneChain[2]),
    // *** Slow Contro Parameter, from MSB to LSB. These parameter is out from
    // the same secquence, pulsed by the SlowClock.
    .DataoutChannelSelect(MicrorocDataoutChannelSelectChain[5:4]),         // Default: 11 Valid
    .TransmitOnChannelSelect(MicrorocTransmitOnChannelSelectChain[5:4]),      // Default: 11 Valid
    .ChipSatbEnable(1'b1),                     // Default: 1 Valid
    .StartReadoutChannelSelect(MicrorocStartReadoutChannelSelectChain[2]),          // Default: 1 StartReadout1
    .EndReadoutChannelSelect(MicrorocEndReadoutChannelSelectChain[2]),            // Default: 1 EndReadout1
    .NC(2'b11),
    .InternalRazSignalLength(MicrorocInternalRazSignalLengthChain[5:4]),      // 00: 75ns, 01: 250ns, 10: 500ns, 11: 1us Default: 11
    .CkMux(MicrorocCkMuxChain[2]),                              // Bypass Synchronous PowerOnDigital for SRo, CK5, CK40 Default: 1 bypass POD
    .LvdsReceiverPPEnable(MicrorocLvdsReceiverPPEnableChain[2]),               // Default:0 Disable
    .ExternalRazSignalEnable(MicrorocExternalRazSignalEnableChain[2]),            // Default: 0 Disable
    .InternalRazSignalEnable(MicrorocInternalRazSignalEnableChain[2]),            // Default: 1 Enable
    .ExternalTriggerEnable(MicrorocExternalTriggerEnableChain[2]),              // Default: 1 Enable
    .TriggerNor64OrDirectSelect(MicrorocTriggerNor64OrDirectSelectChain[2]),         // Default: 1 Nor64
    .TriggerOutputEnable(MicrorocTriggerOutputEnableChain[2]),                // Default: 1 Enable
    .TriggerToWriteSelect(MicrorocTriggerToWriteSelectChain[8:6]),         // Default: 111 all
    .Dac2Vth(MicrorocDac2VthChain[29:20]),                      // MSB->LSB
    .Dac1Vth(MicrorocDac1VthChain[29:20]),
    .Dac0Vth(MicrorocDac0VthChain[29:20]),
    .DacEnable(MicrorocDacEnableChain[2]),                          // Default: 1 Enable
    .DacPPEnable(MicrorocDacPPEnableChain[2]),
    .BandGapEnable(MicrorocBandGapEnableChain[2]),                      // Default: 1 Enable
    .BandGapPPEnable(MicrorocBandGapPPEnableChain[2]),
    .ChipID(MicrorocChipIDChain[23:16]),
    .ChannelDiscriminatorMask(MicrorocChannelDiscriminatorMaskChain[575:384]),   // MSB correspones to Channel 63
    .LatchedOrDirectOutput(MicrorocLatchedOrDirectOutputChain[2]),              // Default: 1 Latched
    .Discriminator1PPEnable(MicrorocDiscriminator2PPEnableChain[2]),
    .Discriminator2PPEnable(MicrorocDiscriminator1PPEnableChain[2]),
    .Discriminator0PPEnable(MicrorocDiscriminator0PPEnableChain[2]),
    .OTAqPPEnable(MicrorocOTAqPPEnableChain[2]),
    .OTAqEnable(MicrorocOTAqEnableChain[2]),
    .Dac4bitPPEnable(MicrorocDac4bitPPEnableChain[2]),
    .ChannelAdjust(MicrorocChannelAdjustChain[767:512]),              // MSB to LSB from channel0 to channel 63
    .HighGainShaperFeedbackSelect(MicrorocHighGainShaperFeedbackSelectChain[5:4]), // Default: 10
    .ShaperOutLowGainOrHighGain(MicrorocShaperOutLowGainOrHighGainChain[2]),         // Default: 0 High gain
    .WidlarPPEnable(MicrorocWidlarPPEnableChain[2]),                     // Default: 0 Disable
    .LowGainShaperFeedbackSelect(MicrorocLowGainShaperFeedbackSelectChain[5:4]),  // Default: 10
    .LowGainShaperPPEnable(MicrorocLowGainShaperPPEnableChain[2]),              // Default: 0
    .HighGainShaperPPEnable(MicrorocHighGainShaperPPEnableChain[2]),             // Default: 0
    .GainBoostEnable(MicrorocGainBoostEnableChain[2]),                    // Default: 1
    .PreAmplifierPPEnable(MicrorocPreAmplifierPPEnableChain[2]),               // Default: 0
    .CTestChannel(MicrorocCTestChannelChain[191:128]),
    // ***64bit read register
    .ReadScopeChannel(MicrorocReadScopeChannelChain[191:128]),
    // *** Redundancy
    .PowerPulsingPinEnable(CommandMicrorocPowerPulsingPinEnable),
    .ReadoutChannelSelect(MicrorocReadRedundancyChain[2]),
    // *** Trigger In
    .ExternalTriggerIn(ExternalTriggerIn),
    .SCurveForceExternalRaz(SCurveTestForceExternalRaz),
    .ForceExternalRaz(ForceExternalRaz[2]),
    // *** Dataout interface
    .ExternalFifoData(MicrorocChain3Data),
    .ExternalFifoDataEnable(MicrorocChain3DataEnable),
    .TestDone(),
    .OnceEnd(MicrorocAcquisitionOnceDone[2]),
    .nPKTEND(nPKTEND),
    .ExternalFifoFull(ExternalFifoFull),
    .ExternalFifoEmpty(ExternalFifoEmptySync),
    // AcqControl
    .DaqSelect(DaqSelect),
    .AcqStart(CommandMicrorocAcquisitionStartStop[2]),
    .UsbStartStop(MicrorocAcquisitionUsbStartStop[2]),
    .StartEnable(RamReadoutDone),
    // Acquisition parameter
    .ChipFullEnable(CommandChipFullEnable),
    .AcquisitionModeSelect(CommandAutoDaqAcquisitionModeSelect),
    .TriggerModeSelect(CommandAutoDaqTriggerModeSelect),
    .TriggerDelayTime(CommandAutoDaqTriggerDelayTime),
    .AcquisitionStartTime(CommandMicrorocStartAcquisitionTime),
    .EndHoldTime(EndHoldTime),
    // *** Pins
    // Slow control and ReadScope
    .SR_RSTB(sr_rstb_C),                           // Selected Register Reset
    .SR_CK(sr_ck_C),                             // Selected Register Clock
    .SR_IN(sr_in_C),                             // Selected Register Input
    // input  SR_OUT, //Selected Register Output,Asic's daisy chain slow control output
    // Power pulsingPin
    .PWR_ON_D(PowerOnDigital[2]),
    .PWR_ON_A(PowerOnAnalog[2]),
    .PWR_ON_DAC(PowerOnDac[2]),
    .PWR_ON_ADC(PowerOnAdc[2]),
    // DAQ Control
    .START_ACQ(StartAcq_C),
    .RESET_B(ResetMicrorocDigitalPart[2]),
    .CHIPSATB(ChipSatb_C),
    .START_READOUT1(StartReadout1_C),
    .START_READOUT2(StartReadout2_C),
    .END_READOUT1(EndReadout1_C),
    .END_READOUT2(EndReadout2_C),
    // RAM readout
    .DOUT1B(Dout1b_C),
    .DOUT2B(Dout2b_C),
    .TRANSMITON1B(TransmitOn1b_C),
    .TRANSMITON2B(TransmitOn2b_C)
    );

  //*** Microroc Chain4
  MicrorocControl MicrorocChain4(
    .Clk(Clk),
    .reset_n(reset_n),
    .SlowClock(Clk5M),                          // Slow clock for MICROROC, typically 5M. It is worth to try 10M clock
    .Clk5M(Clk5M),                              // Clock for Microroc Configuration. If SlowClock is 5M, this clock shoudl be same as SlowClock
    //.SyncClk(SyncClk),                            // This clock is a fast clock to synchronous the TriggerIn signal to generate the hold signal
    // The 'jitter' of the hold signal depends on the peroid of this signal
    .MicrorocReset_n(~ForceMicrorocAcqReset),
    .SlowControlOrReadScopeSelect(MicrorocSlowControlOrReadScopeSelectChain[3]),
    .ParameterLoadStart(MicrorocConfigurationParameterLoadStartChain[3]),
    .ParameterLoadDone(MicrorocConfigurationParameterLoadDoneChain[3]),
    // *** Slow Contro Parameter, from MSB to LSB. These parameter is out from
    // the same secquence, pulsed by the SlowClock.
    .DataoutChannelSelect(MicrorocDataoutChannelSelectChain[7:6]),         // Default: 11 Valid
    .TransmitOnChannelSelect(MicrorocTransmitOnChannelSelectChain[7:6]),      // Default: 11 Valid
    .ChipSatbEnable(1'b1),                     // Default: 1 Valid
    .StartReadoutChannelSelect(MicrorocStartReadoutChannelSelectChain[3]),          // Default: 1 StartReadout1
    .EndReadoutChannelSelect(MicrorocEndReadoutChannelSelectChain[3]),            // Default: 1 EndReadout1
    .NC(2'b11),
    .InternalRazSignalLength(MicrorocInternalRazSignalLengthChain[7:6]),      // 00: 75ns, 01: 250ns, 10: 500ns, 11: 1us Default: 11
    .CkMux(MicrorocCkMuxChain[3]),                              // Bypass Synchronous PowerOnDigital for SRo, CK5, CK40 Default: 1 bypass POD
    .LvdsReceiverPPEnable(MicrorocLvdsReceiverPPEnableChain[3]),               // Default:0 Disable
    .ExternalRazSignalEnable(MicrorocExternalRazSignalEnableChain[3]),            // Default: 0 Disable
    .InternalRazSignalEnable(MicrorocInternalRazSignalEnableChain[3]),            // Default: 1 Enable
    .ExternalTriggerEnable(MicrorocExternalTriggerEnableChain[3]),              // Default: 1 Enable
    .TriggerNor64OrDirectSelect(MicrorocTriggerNor64OrDirectSelectChain[3]),         // Default: 1 Nor64
    .TriggerOutputEnable(MicrorocTriggerOutputEnableChain[3]),                // Default: 1 Enable
    .TriggerToWriteSelect(MicrorocTriggerToWriteSelectChain[11:9]),         // Default: 111 all
    .Dac2Vth(MicrorocDac2VthChain[39:30]),                      // MSB->LSB
    .Dac1Vth(MicrorocDac1VthChain[39:30]),
    .Dac0Vth(MicrorocDac0VthChain[39:30]),
    .DacEnable(MicrorocDacEnableChain[3]),                          // Default: 1 Enable
    .DacPPEnable(MicrorocDacPPEnableChain[3]),
    .BandGapEnable(MicrorocBandGapEnableChain[3]),                      // Default: 1 Enable
    .BandGapPPEnable(MicrorocBandGapPPEnableChain[3]),
    .ChipID(MicrorocChipIDChain[31:24]),
    .ChannelDiscriminatorMask(MicrorocChannelDiscriminatorMaskChain[767:576]),   // MSB correspones to Channel 63
    .LatchedOrDirectOutput(MicrorocLatchedOrDirectOutputChain[3]),              // Default: 1 Latched
    .Discriminator1PPEnable(MicrorocDiscriminator2PPEnableChain[3]),
    .Discriminator2PPEnable(MicrorocDiscriminator1PPEnableChain[3]),
    .Discriminator0PPEnable(MicrorocDiscriminator0PPEnableChain[3]),
    .OTAqPPEnable(MicrorocOTAqPPEnableChain[3]),
    .OTAqEnable(MicrorocOTAqEnableChain[3]),
    .Dac4bitPPEnable(MicrorocDac4bitPPEnableChain[3]),
    .ChannelAdjust(MicrorocChannelAdjustChain[1023:768]),              // MSB to LSB from channel0 to channel 63
    .HighGainShaperFeedbackSelect(MicrorocHighGainShaperFeedbackSelectChain[7:6]), // Default: 10
    .ShaperOutLowGainOrHighGain(MicrorocShaperOutLowGainOrHighGainChain[3]),         // Default: 0 High gain
    .WidlarPPEnable(MicrorocWidlarPPEnableChain[3]),                     // Default: 0 Disable
    .LowGainShaperFeedbackSelect(MicrorocLowGainShaperFeedbackSelectChain[7:6]),  // Default: 10
    .LowGainShaperPPEnable(MicrorocLowGainShaperPPEnableChain[3]),              // Default: 0
    .HighGainShaperPPEnable(MicrorocHighGainShaperPPEnableChain[3]),             // Default: 0
    .GainBoostEnable(MicrorocGainBoostEnableChain[3]),                    // Default: 1
    .PreAmplifierPPEnable(MicrorocPreAmplifierPPEnableChain[3]),               // Default: 0
    .CTestChannel(MicrorocCTestChannelChain[255:192]),
    // ***64bit read register
    .ReadScopeChannel(MicrorocReadScopeChannelChain[255:192]),
    // *** Redundancy
    .PowerPulsingPinEnable(CommandMicrorocPowerPulsingPinEnable),
    .ReadoutChannelSelect(MicrorocReadRedundancyChain[3]),
    // *** Trigger In
    .ExternalTriggerIn(ExternalTriggerIn),
    .SCurveForceExternalRaz(SCurveTestForceExternalRaz),
    .ForceExternalRaz(ForceExternalRaz[3]),
    // *** Dataout interface
    .ExternalFifoData(MicrorocChain4Data),
    .ExternalFifoDataEnable(MicrorocChain4DataEnable),
    .TestDone(),
    .OnceEnd(MicrorocAcquisitionOnceDone[3]),
    .nPKTEND(nPKTEND),
    .ExternalFifoFull(ExternalFifoFull),
    .ExternalFifoEmpty(ExternalFifoEmptySync),
    // AcqControl
    .DaqSelect(DaqSelect),
    .AcqStart(CommandMicrorocAcquisitionStartStop[3]),
    .UsbStartStop(MicrorocAcquisitionUsbStartStop[3]),
    .StartEnable(RamReadoutDone),
    // Acquisition parameter
    .ChipFullEnable(CommandChipFullEnable),
    .AcquisitionModeSelect(CommandAutoDaqAcquisitionModeSelect),
    .TriggerModeSelect(CommandAutoDaqTriggerModeSelect),
    .TriggerDelayTime(CommandAutoDaqTriggerDelayTime),
    .AcquisitionStartTime(CommandMicrorocStartAcquisitionTime),
    .EndHoldTime(EndHoldTime),
    // *** Pins
    // Slow control and ReadScope
    .SR_RSTB(sr_rstb_D),                           // Selected Register Reset
    .SR_CK(sr_ck_D),                             // Selected Register Clock
    .SR_IN(sr_in_D),                             // Selected Register Input
    // input  SR_OUT, //Selected Register Output,Asic's daisy chain slow control output
    // Power pulsingPin
    .PWR_ON_D(PowerOnDigital[3]),
    .PWR_ON_A(PowerOnAnalog[3]),
    .PWR_ON_DAC(PowerOnDac[3]),
    .PWR_ON_ADC(PowerOnAdc[3]),
    // DAQ Control
    .START_ACQ(StartAcq_D),
    .RESET_B(ResetMicrorocDigitalPart[3]),
    .CHIPSATB(ChipSatb_D),
    .START_READOUT1(StartReadout1_D),
    .START_READOUT2(StartReadout2_D),
    .END_READOUT1(EndReadout1_D),
    .END_READOUT2(EndReadout2_D),
    // RAM readout
    .DOUT1B(Dout1b_D),
    .DOUT2B(Dout2b_D),
    .TRANSMITON1B(TransmitOn1b_D),
    .TRANSMITON2B(TransmitOn2b_D)
    );
  assign hold = HoldSignal;
  assign TP[0] = InternalSynchronousSignalIn;
  assign TP[1] = StartReadout1_A;
  assign TP[2] = EndReadout1_A;
  assign TP[3] = MicrorocConfigurationParameterLoadStart;


  (* MARK_DEBUG="true" *)wire [15:0] UsbData_debug;
  (* MARK_DEBUG="true" *)wire UsbDataEnable_debug;
  /*(* MARK_DEBUG="true" *)wire [15:0] Chain1Data_debug;
  (* MARK_DEBUG="true" *)wire Chain1DataEnable_debug;
  (* MARK_DEBUG="true" *)wire [15:0] Chain2Data_debug;
  (* MARK_DEBUG="true" *)wire Chain2DataEnable_debug;
  (* MARK_DEBUG="true" *)wire [15:0] Chain3Data_debug;
  (* MARK_DEBUG="true" *)wire Chain3DataEnable_debug;
  (* MARK_DEBUG="true" *)wire [15:0] Chain4Data_debug;
  (* MARK_DEBUG="true" *)wire Chain4DataEnable_debug;*/
  assign UsbData_debug = ExternalFifoData;
  assign UsbDataEnable_debug = ExternalFifoDataReadEnable;
  /*assign Chain1Data_debug = MicrorocChain1Data;
  assign Chain1DataEnable_debug = MicrorocChain1DataEnable;
  assign Chain2Data_debug = MicrorocChain2Data;
  assign Chain2DataEnable_debug = MicrorocChain2DataEnable;
  assign Chain3Data_debug = MicrorocChain3Data;
  assign Chain3DataEnable_debug = MicrorocChain3DataEnable;
  assign Chain4Data_debug = MicrorocChain4Data;
  assign Chain4DataEnable_debug = MicrorocChain4DataEnable;*/
  (* MARK_DEBUG="true" *)wire UsbStartStop_Debug;
  assign UsbStartStop_Debug = UsbStartStop;
  (* MARK_DEBUG="true" *)wire MicrorocConfigurationParameterLoadStart_Debug;
  assign MicrorocConfigurationParameterLoadStart_Debug = MicrorocConfigurationParameterLoadStart;
  (* MARK_DEBUG="true" *)wire [3:0] MicrorocConfigurationParameterLoadDoneChain_Debug;
  assign MicrorocConfigurationParameterLoadDoneChain_Debug = MicrorocConfigurationParameterLoadDoneChain;
  (* MARK_DEBUG="true" *)wire MicrorocConfigurationParameterLoadDone_Debug;
  assign MicrorocConfigurationParameterLoadDone_Debug = MicrorocConfigurationParameterLoadDone;
  (* MARK_DEBUG="true" *)wire [3:0] CommandModeSelect_Debug;
  assign CommandModeSelect_Debug = CommandModeSelect;
  (* MARK_DEBUG="true" *)wire [15:0] OutTestData_Debug;
  assign OutTestData_Debug = OutTestData;
  (* MARK_DEBUG="true" *)wire OutTestDataEnable_Debug;
  assign OutTestDataEnable_Debug = OutTestDataEnable;
  (* MARK_DEBUG="true" *)wire ExternalFifoFull_Debug;
  (* MARK_DEBUG="true" *)wire ExternalFifoEmpty_Debug;
  assign ExternalFifoFull_Debug = ExternalFifoFull;
  assign ExternalFifoEmpty_Debug = ExternalFifoEmpty;
endmodule
