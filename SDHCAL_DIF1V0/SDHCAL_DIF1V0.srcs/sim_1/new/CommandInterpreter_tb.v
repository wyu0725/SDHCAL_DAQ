`timescale 1ns / 1ns

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:50:25 07/03/2018
// Design Name:   CommandInterpreter
// Module Name:   E:/workspace/Xilinx/ISE/auto/CommandInterpreter_tb.v
// Project Name:  auto
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CommandInterpreter
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module CommandInterpreter_tb;

	// Inputs
	reg Clk;
	reg IFCLK;
	reg reset_n;
	reg CommandWordEn;
	reg [15:0] CommandWord;
	reg SweepTestDone;
	reg UsbFifoEmpty;

	// Outputs
	wire AcquisitionStartStop;
	wire ResetDataFifo;
	wire [3:0] AsicChainSelect;
	wire MicrorocSlowControlOrReadScopeSelect;
	wire MicrorocParameterLoadStart;
	wire [1:0] MicrorocDataoutChannelSelect;
	wire [1:0] MicrorocTransmitOnChannelSelect;
	wire MicrorocStartReadoutChannelSelect;
	wire MicrorocEndReadoutChannelSelect;
	wire [1:0] MicrorocInternalRazSignalLength;
	wire MicrorocCkMux;
	wire MicrorocLvdsReceiverPPEnable;
	wire MicrorocExternalRazSignalEnable;
	wire MicrorocInternalRazSignalEnable;
	wire MicrorocExternalTriggerEnable;
	wire MicrorocTriggerNor64OrDirectSelect;
	wire MicrorocTriggerOutputEnable;
	wire [2:0] MicrorocTriggerToWriteSelect;
	wire [9:0] MicrorocDac2Vth;
	wire [9:0] MicrorocDac1Vth;
	wire [9:0] MicrorocDac0Vth;
	wire MicrorocDacEnable;
	wire MicrorocDacPPEnable;
	wire MicrorocBandGapEnable;
	wire MicrorocBandGapPPEnable;
	wire [7:0] MicrorocChipID;
	wire [191:0] MicrorocChannelDiscriminatorMask;
	wire MicrorocLatchedOrDirectOutput;
	wire MicrorocDiscriminator2PPEnable;
	wire MicrorocDisriminator1PPEnable;
	wire MicrorocDiscriminator0PPEnable;
	wire MicrorocOTAqPPEnable;
	wire MicrorocOTAqEnable;
	wire MicrorocDac4bitPPEnable;
	wire [255:0] ChannelAdjust;
	wire [1:0] MicrorocHighGainShaperFeedbackSelect;
	wire MicrorocShaperOutLowGainOrHighGain;
	wire MicrorocWidlarPPEnable;
	wire [1:0] MicrorocLowGainShaperFeedbackSelect;
	wire MicrorocLowGainShaperPPEnable;
	wire MicrorocHighGainShaperPPEnable;
	wire MicrorocGainBoostEnable;
	wire MicrorocPreAmplifierPPEnable;
	wire [63:0] MicrorocCTestChannel;
	wire [63:0] MicrorocReadScopeChannel;
	wire MicrorocReadRedundancy;
	wire [1:0] MicrorocExternalRazMode;
	wire [3:0] MicrorocExternalRazDelayTime;
	wire MicrorocResetTimeStamp;
	wire [3:0] ModeSelect;
	wire [1:0] DacSelect;
	wire [9:0] StartDac;
	wire [9:0] EndDac;
	wire [9:0] DacStep;
	wire SingleOr64Channel;
	wire CTestOrInput;
	wire [5:0] SingleTestChannel;
	wire [15:0] TriggerCountMax;
	wire [3:0] TriggerDelay;
	wire SweepTestStartStop;
	wire UnmaskAllChannel;
	wire TriggerEfficiencyOrCountEfficiency;
	wire [15:0] CounterMax;
	wire [15:0] SweepAcqMaxPackageNumber;
	wire ForceMicrorocAcqReset;
	wire AdcStartStop;
	wire [3:0] AdcStartDelayTime;
	wire [7:0] AdcDataNumber;
	wire [1:0] TriggerCoincidence;
	wire [7:0] HoldDelay;
	wire [15:0] HoldTime;
	wire HoldEnable;
	wire [15:0] EndHoldTime;
	wire DaqSelect;
	wire [3:0] LED;

	// Instantiate the Unit Under Test (UUT)
	CommandInterpreter uut (
		.Clk                                 (Clk),
		.IFCLK                               (IFCLK),
		.reset_n                             (reset_n),
		.CommandWordEn                       (CommandWordEn),
		.CommandWord                         (CommandWord),
		.AcquisitionStartStop                (AcquisitionStartStop),
		.ResetDataFifo                       (ResetDataFifo),
		.AsicChainSelect                     (AsicChainSelect),
		.MicrorocSlowControlOrReadScopeSelect(MicrorocSlowControlOrReadScopeSelect),
		.MicrorocParameterLoadStart          (MicrorocParameterLoadStart),
		.MicrorocDataoutChannelSelect        (MicrorocDataoutChannelSelect),
		.MicrorocTransmitOnChannelSelect     (MicrorocTransmitOnChannelSelect),
		.MicrorocStartReadoutChannelSelect   (MicrorocStartReadoutChannelSelect),
		.MicrorocEndReadoutChannelSelect     (MicrorocEndReadoutChannelSelect),
		.MicrorocInternalRazSignalLength     (MicrorocInternalRazSignalLength),
		.MicrorocCkMux                       (MicrorocCkMux),
		.MicrorocLvdsReceiverPPEnable        (MicrorocLvdsReceiverPPEnable),
		.MicrorocExternalRazSignalEnable     (MicrorocExternalRazSignalEnable),
		.MicrorocInternalRazSignalEnable     (MicrorocInternalRazSignalEnable),
		.MicrorocExternalTriggerEnable       (MicrorocExternalTriggerEnable),
		.MicrorocTriggerNor64OrDirectSelect  (MicrorocTriggerNor64OrDirectSelect),
		.MicrorocTriggerOutputEnable         (MicrorocTriggerOutputEnable),
		.MicrorocTriggerToWriteSelect        (MicrorocTriggerToWriteSelect),
		.MicrorocDac2Vth                     (MicrorocDac2Vth),
		.MicrorocDac1Vth                     (MicrorocDac1Vth),
		.MicrorocDac0Vth                     (MicrorocDac0Vth),
		.MicrorocDacEnable                   (MicrorocDacEnable),
		.MicrorocDacPPEnable                 (MicrorocDacPPEnable),
		.MicrorocBandGapEnable               (MicrorocBandGapEnable),
		.MicrorocBandGapPPEnable             (MicrorocBandGapPPEnable),
		.MicrorocChipID                      (MicrorocChipID),
		.MicrorocChannelDiscriminatorMask    (MicrorocChannelDiscriminatorMask),
		.MicrorocLatchedOrDirectOutput       (MicrorocLatchedOrDirectOutput),
		.MicrorocDiscriminator2PPEnable      (MicrorocDiscriminator2PPEnable),
		.MicrorocDiscriminator1PPEnable      (MicrorocDisriminator1PPEnable),
		.MicrorocDiscriminator0PPEnable      (MicrorocDiscriminator0PPEnable),
		.MicrorocOTAqPPEnable                (MicrorocOTAqPPEnable),
		.MicrorocOTAqEnable                  (MicrorocOTAqEnable),
		.MicrorocDac4bitPPEnable             (MicrorocDac4bitPPEnable),
		.ChannelAdjust                       (ChannelAdjust),
		.MicrorocHighGainShaperFeedbackSelect(MicrorocHighGainShaperFeedbackSelect),
		.MicrorocShaperOutLowGainOrHighGain  (MicrorocShaperOutLowGainOrHighGain),
		.MicrorocWidlarPPEnable              (MicrorocWidlarPPEnable),
		.MicrorocLowGainShaperFeedbackSelect (MicrorocLowGainShaperFeedbackSelect),
		.MicrorocLowGainShaperPPEnable       (MicrorocLowGainShaperPPEnable),
		.MicrorocHighGainShaperPPEnable      (MicrorocHighGainShaperPPEnable),
		.MicrorocGainBoostEnable             (MicrorocGainBoostEnable),
		.MicrorocPreAmplifierPPEnable        (MicrorocPreAmplifierPPEnable),
		.MicrorocCTestChannel                (MicrorocCTestChannel),
		.MicrorocReadScopeChannel            (MicrorocReadScopeChannel),
		.MicrorocReadRedundancy              (MicrorocReadRedundancy),
		.MicrorocExternalRazMode             (MicrorocExternalRazMode),
		.MicrorocExternalRazDelayTime        (MicrorocExternalRazDelayTime),
		.MicrorocResetTimeStamp              (MicrorocResetTimeStamp),
		.ModeSelect                          (ModeSelect),
		.DacSelect                           (DacSelect),
		.StartDac                            (StartDac),
		.EndDac                              (EndDac),
		.DacStep                             (DacStep),
		.SingleOr64Channel                   (SingleOr64Channel),
		.CTestOrInput                        (CTestOrInput),
		.SingleTestChannel                   (SingleTestChannel),
		.TriggerCountMax                     (TriggerCountMax),
		.TriggerDelay                        (TriggerDelay),
		.SweepTestStartStop                  (SweepTestStartStop),
		.UnmaskAllChannel                    (UnmaskAllChannel),
		.TriggerEfficiencyOrCountEfficiency  (TriggerEfficiencyOrCountEfficiency),
		.CounterMax                          (CounterMax),
		.SweepTestDone                       (SweepTestDone),
		.UsbFifoEmpty                        (UsbFifoEmpty),
		.SweepAcqMaxPackageNumber            (SweepAcqMaxPackageNumber),
		.ForceMicrorocAcqReset               (ForceMicrorocAcqReset),
		.AdcStartStop                        (AdcStartStop),
		.AdcStartDelayTime                   (AdcStartDelayTime),
		.AdcDataNumber                       (AdcDataNumber),
		.TriggerCoincidence                  (TriggerCoincidence),
		.HoldDelay                           (HoldDelay),
		.HoldTime                            (HoldTime),
		.HoldEnable                          (HoldEnable),
		.EndHoldTime                         (EndHoldTime),
		.DaqSelect                           (DaqSelect),
		.LED                                 (LED)
  );

  parameter IFCLK_PEROID = 20;
	initial begin
		// Initialize Inputs
		Clk = 0;
		IFCLK = 0;
		reset_n = 0;
		CommandWordEn = 0;
		CommandWord = 16'b0;
		SweepTestDone = 0;
		UsbFifoEmpty = 0;

		// Wait 100 ns for global reset to finish
		#100;
    reset_n = 1'b1;
    #10000;
    CommandWordEn = 1'b1;
    CommandWord = 16'hA0A1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA0B2;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA0C2;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA0D0;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA0E0;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA0F1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA000;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA031;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA040;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA050;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA060;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA070;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA085;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA090;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA1A0;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA1B0;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA1CB;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA1D1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA1E1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA2A2;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA2B1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA2C0;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA2D1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA2A1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA2B0;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA1C0;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA2D1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #2000;
    CommandWord = 16'hA2D3;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA100;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA110;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA121;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA131;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA141;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA150;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA161;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA171;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA185;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA190;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA2E1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA2F1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA201;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA211;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA221;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA231;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA241;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA251;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA261;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA271;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA280;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA292;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA3AF;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hC00F;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hC013;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hC021;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hC03E;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hC042;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hC052;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hC061;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hC07F;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hC083;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hD0A1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE0A1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE0B1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE0CF;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE0D3;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE0E1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE0FA;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE00B;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE012;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE02F;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE03F;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE043;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE050;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE060;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE07F;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE081;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE1A7;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE1B7;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE1C2;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE1D2;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE1E3;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hF0A1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE1F1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE100;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE117;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE127;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;

    #180;
    CommandWord = 16'hE138;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE142;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE15A;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE16B;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE17A;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE183;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE191;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hF0B1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE2A7;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE2B2;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE2BF;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE2C1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE2D1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE2E7;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE2FA;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE207;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE21A;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE222;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE23F;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE241;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE255;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE26A;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE27C;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE28D;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hB0A1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hB007;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hF0F1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hF1A1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hA3B1;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
    #180;
    CommandWord = 16'hE291;
    CommandWordEn = 1'b1;
    #20;
    CommandWordEn = 1'b0;
	end
  always #(IFCLK_PEROID/2) IFCLK = ~IFCLK;
  localparam LOW = 13;
  localparam HIGH = 12;
  always begin
    #(LOW) Clk = ~Clk;
    #(HIGH) Clk = ~Clk;
  end
endmodule

