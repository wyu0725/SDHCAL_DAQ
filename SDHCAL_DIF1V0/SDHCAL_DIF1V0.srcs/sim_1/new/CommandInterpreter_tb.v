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
        

	end
  always #(IFCLK_PEROID/2) IFCLK = ~IFCLK;
  localparam LOW = 13;
  localparam HIGH = 12;
  always begin
    #(LOW) Clk = ~Clk;
    #(HIGH) Clk = ~Clk;
  end
endmodule

