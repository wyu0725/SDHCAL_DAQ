`timescale 1ns / 1ns

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:42:00 07/04/2018
// Design Name:   ConfigurationParameterDistribution
// Module Name:   C:/WangYu/TestBenchInst/ConfigurationParameterDistribution_tb.v
// Project Name:  TestBenchInst
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ConfigurationParameterDistribution
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ConfigurationParameterDistribution_tb;

	// Inputs
	reg Clk;
	reg reset_n;
  reg [3:0] AsicChainSelect;
	reg MicrorocSlowControlOrReadScopeSelect_Input;
	reg MicrorocParameterLoadStart_Input;
	reg [1:0] MicrorocDataoutChannelSelect_Input;
	reg [1:0] MicrorocTransmitOnChannelSelect_Input;
	reg MicrorocStartReadoutChannelSelect_Input;
	reg MicrorocEndReadoutChannelSelect_Input;
	reg [1:0] MicrorocInternalRazSignalLength_Input;
	reg MicrorocCkMux_Input;
	reg MicrorocLvdsReceiverPPEnable_Input;
	reg MicrorocExternalRazSignalEnable_Input;
	reg MicrorocInternalRazSignalEnable_Input;
	reg MicrorocExternalTriggerEnable_Input;
	reg MicrorocTriggerNor64OrDirectSelect_Input;
	reg MicrorocTriggerOutputEnable_Input;
	reg [2:0] MicrorocTriggerToWriteSelect_Input;
	reg [9:0] MicrorocDac2Vth_Input;
	reg [9:0] MicrorocDac1Vth_Input;
	reg [9:0] MicrorocDac0Vth_Input;
	reg MicrorocDacEnable_Input;
	reg MicrorocDacPPEnable_Input;
	reg MicrorocBandGapEnable_Input;
	reg MicrorocBandGapPPEnable_Input;
	reg [7:0] MicrorocChipID_Input;
	reg [191:0] MicrorocChannelDiscriminatorMask_Input;
	reg MicrorocLatchedOrDirectOutput_Input;
	reg MicrorocDiscriminator2PPEnable_Input;
	reg MicrorocDiscriminator1PPEnable_Input;
	reg MicrorocDiscriminator0PPEnable_Input;
	reg MicrorocOTAqPPEnable_Input;
	reg MicrorocOTAqEnable_Input;
	reg MicrorocDac4bitPPEnable_Input;
	reg [255:0] ChannelAdjust_Input;
	reg [1:0] MicrorocHighGainShaperFeedbackSelect_Input;
	reg MicrorocShaperOutLowGainOrHighGain_Input;
	reg MicrorocWidlarPPEnable_Input;
	reg [1:0] MicrorocLowGainShaperFeedbackSelect_Input;
	reg MicrorocLowGainShaperPPEnable_Input;
	reg MicrorocHighGainShaperPPEnable_Input;
	reg MicrorocGainBoostEnable_Input;
	reg MicrorocPreAmplifierPPEnable_Input;
	reg [63:0] MicrorocCTestChannel_Input;
	reg [63:0] MicrorocReadScopeChannel_Input;
	reg [1:0] MicrorocExternalRazMode_Input;
	reg [3:0] MicrorocExternalRazDelayTime_Input;
	reg MicrorocResetTimeStamp_Input;
	reg MicrorocReadRedundancy_Input;

	// Outputs
	wire [3:0] MicrorocSlowControlOrReadScopeSelect_Output;
	wire [3:0] MicrorocParameterLoadStart_Output;
	wire [7:0] MicrorocDataoutChannelSelect_Output;
	wire [7:0] MicrorocTransmitOnChannelSelect_Output;
	wire [3:0] MicrorocStartReadoutChannelSelect_Output;
	wire [3:0] MicrorocEndReadoutChannelSelect_Output;
	wire [7:0] MicrorocInternalRazSignalLength_Output;
	wire [3:0] MicrorocCkMux_Output;
	wire [3:0] MicrorocLvdsReceiverPPEnable_Output;
	wire [3:0] MicrorocExternalRazSignalEnable_Output;
	wire [3:0] MicrorocInternalRazSignalEnable_Output;
	wire [3:0] MicrorocExternalTriggerEnable_Output;
	wire [3:0] MicrorocTriggerNor64OrDirectSelect_Output;
	wire [3:0] MicrorocTriggerOutputEnable_Output;
	wire [11:0] MicrorocTriggerToWriteSelect_Output;
	wire [39:0] MicrorocDac2Vth_Output;
	wire [39:0] MicrorocDac1Vth_Output;
	wire [39:0] MicrorocDac0Vth_Output;
	wire [3:0] MicrorocDacEnable_Output;
	wire [3:0] MicrorocDacPPEnable_Output;
	wire [3:0] MicrorocBandGapEnable_Output;
	wire [3:0] MicrorocBandGapPPEnable_Output;
	wire [31:0] MicrorocChipID_Output;
	wire [767:0] MicrorocChannelDiscriminatorMask_Output;
	wire [3:0] MicrorocLatchedOrDirectOutput_Output;
	wire [3:0] MicrorocDiscriminator2PPEnable_Output;
	wire [3:0] MicrorocDiscriminator1PPEnable_Output;
	wire [3:0] MicrorocDiscriminator0PPEnable_Output;
	wire [3:0] MicrorocOTAqPPEnable_Output;
	wire [3:0] MicrorocOTAqEnable_Output;
	wire [3:0] MicrorocDac4bitPPEnable_Output;
	wire [1023:0] ChannelAdjust_Output;
	wire [7:0] MicrorocHighGainShaperFeedbackSelect_Output;
	wire [3:0] MicrorocShaperOutLowGainOrHighGain_Output;
	wire [3:0] MicrorocWidlarPPEnable_Output;
	wire [7:0] MicrorocLowGainShaperFeedbackSelect_Output;
	wire [3:0] MicrorocLowGainShaperPPEnable_Output;
	wire [3:0] MicrorocHighGainShaperPPEnable_Output;
	wire [3:0] MicrorocGainBoostEnable_Output;
	wire [3:0] MicrorocPreAmplifierPPEnable_Output;
	wire [255:0] MicrorocCTestChannel_Output;
	wire [255:0] MicrorocReadScopeChannel_Output;
	wire [7:0] MicrorocExternalRazMode_Output;
	wire [15:0] MicrorocExternalRazDelayTime_Output;
	wire [3:0] MicrorocResetTimeStamp_Output;
  wire [3:0] MicrorocReadRedundancy_Output;

	// Instantiate the Unit Under Test (UUT)
	ConfigurationParameterDistribution 
  #(
    .ASIC_CHAIN_NUMBER(4'd4)
  )
  uut (
		.Clk(Clk), 
		.reset_n(reset_n),
    .AsicChainSelect(AsicChainSelect),
		.MicrorocSlowControlOrReadScopeSelect_Input(MicrorocSlowControlOrReadScopeSelect_Input), 
		.MicrorocParameterLoadStart_Input(MicrorocParameterLoadStart_Input), 
		.MicrorocDataoutChannelSelect_Input(MicrorocDataoutChannelSelect_Input), 
		.MicrorocTransmitOnChannelSelect_Input(MicrorocTransmitOnChannelSelect_Input), 
		.MicrorocStartReadoutChannelSelect_Input(MicrorocStartReadoutChannelSelect_Input), 
		.MicrorocEndReadoutChannelSelect_Input(MicrorocEndReadoutChannelSelect_Input), 
		.MicrorocInternalRazSignalLength_Input(MicrorocInternalRazSignalLength_Input), 
		.MicrorocCkMux_Input(MicrorocCkMux_Input), 
		.MicrorocLvdsReceiverPPEnable_Input(MicrorocLvdsReceiverPPEnable_Input), 
		.MicrorocExternalRazSignalEnable_Input(MicrorocExternalRazSignalEnable_Input), 
		.MicrorocInternalRazSignalEnable_Input(MicrorocInternalRazSignalEnable_Input), 
		.MicrorocExternalTriggerEnable_Input(MicrorocExternalTriggerEnable_Input), 
		.MicrorocTriggerNor64OrDirectSelect_Input(MicrorocTriggerNor64OrDirectSelect_Input), 
		.MicrorocTriggerOutputEnable_Input(MicrorocTriggerOutputEnable_Input), 
		.MicrorocTriggerToWriteSelect_Input(MicrorocTriggerToWriteSelect_Input), 
		.MicrorocDac2Vth_Input(MicrorocDac2Vth_Input), 
		.MicrorocDac1Vth_Input(MicrorocDac1Vth_Input), 
		.MicrorocDac0Vth_Input(MicrorocDac0Vth_Input), 
		.MicrorocDacEnable_Input(MicrorocDacEnable_Input), 
		.MicrorocDacPPEnable_Input(MicrorocDacPPEnable_Input), 
		.MicrorocBandGapEnable_Input(MicrorocBandGapEnable_Input), 
		.MicrorocBandGapPPEnable_Input(MicrorocBandGapPPEnable_Input), 
		.MicrorocChipID_Input(MicrorocChipID_Input), 
		.MicrorocChannelDiscriminatorMask_Input(MicrorocChannelDiscriminatorMask_Input), 
		.MicrorocLatchedOrDirectOutput_Input(MicrorocLatchedOrDirectOutput_Input), 
		.MicrorocDiscriminator2PPEnable_Input(MicrorocDiscriminator2PPEnable_Input), 
		.MicrorocDiscriminator1PPEnable_Input(MicrorocDiscriminator1PPEnable_Input), 
		.MicrorocDiscriminator0PPEnable_Input(MicrorocDiscriminator0PPEnable_Input), 
		.MicrorocOTAqPPEnable_Input(MicrorocOTAqPPEnable_Input), 
		.MicrorocOTAqEnable_Input(MicrorocOTAqEnable_Input), 
		.MicrorocDac4bitPPEnable_Input(MicrorocDac4bitPPEnable_Input), 
		.ChannelAdjust_Input(ChannelAdjust_Input), 
		.MicrorocHighGainShaperFeedbackSelect_Input(MicrorocHighGainShaperFeedbackSelect_Input), 
		.MicrorocShaperOutLowGainOrHighGain_Input(MicrorocShaperOutLowGainOrHighGain_Input), 
		.MicrorocWidlarPPEnable_Input(MicrorocWidlarPPEnable_Input), 
		.MicrorocLowGainShaperFeedbackSelect_Input(MicrorocLowGainShaperFeedbackSelect_Input), 
		.MicrorocLowGainShaperPPEnable_Input(MicrorocLowGainShaperPPEnable_Input), 
		.MicrorocHighGainShaperPPEnable_Input(MicrorocHighGainShaperPPEnable_Input), 
		.MicrorocGainBoostEnable_Input(MicrorocGainBoostEnable_Input), 
		.MicrorocPreAmplifierPPEnable_Input(MicrorocPreAmplifierPPEnable_Input), 
		.MicrorocCTestChannel_Input(MicrorocCTestChannel_Input), 
		.MicrorocReadScopeChannel_Input(MicrorocReadScopeChannel_Input), 
		.MicrorocReadRedundancy_Input(MicrorocReadRedundancy_Input), 
		.MicrorocExternalRazMode_Input(MicrorocExternalRazMode_Input), 
		.MicrorocExternalRazDelayTime_Input(MicrorocExternalRazDelayTime_Input), 
		.MicrorocResetTimeStamp_Input(MicrorocResetTimeStamp_Input), 
		.MicrorocSlowControlOrReadScopeSelect_Output(MicrorocSlowControlOrReadScopeSelect_Output), 
		.MicrorocParameterLoadStart_Output(MicrorocParameterLoadStart_Output), 
		.MicrorocDataoutChannelSelect_Output(MicrorocDataoutChannelSelect_Output), 
		.MicrorocTransmitOnChannelSelect_Output(MicrorocTransmitOnChannelSelect_Output), 
		.MicrorocStartReadoutChannelSelect_Output(MicrorocStartReadoutChannelSelect_Output), 
		.MicrorocEndReadoutChannelSelect_Output(MicrorocEndReadoutChannelSelect_Output), 
		.MicrorocInternalRazSignalLength_Output(MicrorocInternalRazSignalLength_Output), 
		.MicrorocCkMux_Output(MicrorocCkMux_Output), 
		.MicrorocLvdsReceiverPPEnable_Output(MicrorocLvdsReceiverPPEnable_Output), 
		.MicrorocExternalRazSignalEnable_Output(MicrorocExternalRazSignalEnable_Output), 
		.MicrorocInternalRazSignalEnable_Output(MicrorocInternalRazSignalEnable_Output), 
		.MicrorocExternalTriggerEnable_Output(MicrorocExternalTriggerEnable_Output), 
		.MicrorocTriggerNor64OrDirectSelect_Output(MicrorocTriggerNor64OrDirectSelect_Output), 
		.MicrorocTriggerOutputEnable_Output(MicrorocTriggerOutputEnable_Output), 
		.MicrorocTriggerToWriteSelect_Output(MicrorocTriggerToWriteSelect_Output), 
		.MicrorocDac2Vth_Output(MicrorocDac2Vth_Output), 
		.MicrorocDac1Vth_Output(MicrorocDac1Vth_Output), 
		.MicrorocDac0Vth_Output(MicrorocDac0Vth_Output), 
		.MicrorocDacEnable_Output(MicrorocDacEnable_Output), 
		.MicrorocDacPPEnable_Output(MicrorocDacPPEnable_Output), 
		.MicrorocBandGapEnable_Output(MicrorocBandGapEnable_Output), 
		.MicrorocBandGapPPEnable_Output(MicrorocBandGapPPEnable_Output), 
		.MicrorocChipID_Output(MicrorocChipID_Output), 
		.MicrorocChannelDiscriminatorMask_Output(MicrorocChannelDiscriminatorMask_Output), 
		.MicrorocLatchedOrDirectOutput_Output(MicrorocLatchedOrDirectOutput_Output), 
		.MicrorocDiscriminator2PPEnable_Output(MicrorocDiscriminator2PPEnable_Output), 
		.MicrorocDiscriminator1PPEnable_Output(MicrorocDiscriminator1PPEnable_Output), 
		.MicrorocDiscriminator0PPEnable_Output(MicrorocDiscriminator0PPEnable_Output), 
		.MicrorocOTAqPPEnable_Output(MicrorocOTAqPPEnable_Output), 
		.MicrorocOTAqEnable_Output(MicrorocOTAqEnable_Output), 
		.MicrorocDac4bitPPEnable_Output(MicrorocDac4bitPPEnable_Output), 
		.ChannelAdjust_Output(ChannelAdjust_Output), 
		.MicrorocHighGainShaperFeedbackSelect_Output(MicrorocHighGainShaperFeedbackSelect_Output), 
		.MicrorocShaperOutLowGainOrHighGain_Output(MicrorocShaperOutLowGainOrHighGain_Output), 
		.MicrorocWidlarPPEnable_Output(MicrorocWidlarPPEnable_Output), 
		.MicrorocLowGainShaperFeedbackSelect_Output(MicrorocLowGainShaperFeedbackSelect_Output), 
		.MicrorocLowGainShaperPPEnable_Output(MicrorocLowGainShaperPPEnable_Output), 
		.MicrorocHighGainShaperPPEnable_Output(MicrorocHighGainShaperPPEnable_Output), 
		.MicrorocGainBoostEnable_Output(MicrorocGainBoostEnable_Output), 
		.MicrorocPreAmplifierPPEnable_Output(MicrorocPreAmplifierPPEnable_Output), 
		.MicrorocCTestChannel_Output(MicrorocCTestChannel_Output), 
		.MicrorocReadScopeChannel_Output(MicrorocReadScopeChannel_Output), 
		.MicrorocReadRedundancy_Output(MicrorocReadRedundancy_Output), 
		.MicrorocExternalRazMode_Output(MicrorocExternalRazMode_Output), 
		.MicrorocExternalRazDelayTime_Output(MicrorocExternalRazDelayTime_Output), 
		.MicrorocResetTimeStamp_Output(MicrorocResetTimeStamp_Output)
	);

	initial begin
		// Initialize Inputs
		Clk = 0;
		reset_n = 0;
    AsicChainSelect = 0;
		MicrorocSlowControlOrReadScopeSelect_Input = 0;
		MicrorocParameterLoadStart_Input = 0;
		MicrorocDataoutChannelSelect_Input = 0;
		MicrorocTransmitOnChannelSelect_Input = 0;
		MicrorocStartReadoutChannelSelect_Input = 0;
		MicrorocEndReadoutChannelSelect_Input = 0;
		MicrorocInternalRazSignalLength_Input = 0;
		MicrorocCkMux_Input = 0;
		MicrorocLvdsReceiverPPEnable_Input = 0;
		MicrorocExternalRazSignalEnable_Input = 0;
		MicrorocInternalRazSignalEnable_Input = 0;
		MicrorocExternalTriggerEnable_Input = 0;
		MicrorocTriggerNor64OrDirectSelect_Input = 0;
		MicrorocTriggerOutputEnable_Input = 0;
		MicrorocTriggerToWriteSelect_Input = 0;
		MicrorocDac2Vth_Input = 0;
		MicrorocDac1Vth_Input = 0;
		MicrorocDac0Vth_Input = 0;
		MicrorocDacEnable_Input = 0;
		MicrorocDacPPEnable_Input = 0;
		MicrorocBandGapEnable_Input = 0;
		MicrorocBandGapPPEnable_Input = 0;
		MicrorocChipID_Input = 0;
		MicrorocChannelDiscriminatorMask_Input = 0;
		MicrorocLatchedOrDirectOutput_Input = 0;
		MicrorocDiscriminator2PPEnable_Input = 0;
		MicrorocDiscriminator1PPEnable_Input = 0;
		MicrorocDiscriminator0PPEnable_Input = 0;
		MicrorocOTAqPPEnable_Input = 0;
		MicrorocOTAqEnable_Input = 0;
		MicrorocDac4bitPPEnable_Input = 0;
		ChannelAdjust_Input = 0;
		MicrorocHighGainShaperFeedbackSelect_Input = 0;
		MicrorocShaperOutLowGainOrHighGain_Input = 0;
		MicrorocWidlarPPEnable_Input = 0;
		MicrorocLowGainShaperFeedbackSelect_Input = 0;
		MicrorocLowGainShaperPPEnable_Input = 0;
		MicrorocHighGainShaperPPEnable_Input = 0;
		MicrorocGainBoostEnable_Input = 0;
		MicrorocPreAmplifierPPEnable_Input = 0;
		MicrorocCTestChannel_Input = 0;
		MicrorocReadScopeChannel_Input = 0;
		MicrorocExternalRazMode_Input = 0;
		MicrorocExternalRazDelayTime_Input = 0;
		MicrorocResetTimeStamp_Input = 0;
		MicrorocReadRedundancy_Input = 0;

		// Wait 100 ns for global reset to finish
		#100;
    reset_n = 1'b1;
    #1000;
    MicrorocSlowControlOrReadScopeSelect_Input = 1;
		MicrorocParameterLoadStart_Input = 1;
		MicrorocDataoutChannelSelect_Input = 2'b11;
		MicrorocTransmitOnChannelSelect_Input = 2'b11;
		MicrorocStartReadoutChannelSelect_Input = 1;
		MicrorocEndReadoutChannelSelect_Input = 1;
		MicrorocInternalRazSignalLength_Input = 2'b11;
		MicrorocCkMux_Input = 1;
		MicrorocLvdsReceiverPPEnable_Input = 1;
		MicrorocExternalRazSignalEnable_Input = 1;
		MicrorocInternalRazSignalEnable_Input = 1;
		MicrorocExternalTriggerEnable_Input = 1;
		MicrorocTriggerNor64OrDirectSelect_Input = 1;
		MicrorocTriggerOutputEnable_Input = 1;
		MicrorocTriggerToWriteSelect_Input = 3'b111;
		MicrorocDac2Vth_Input = 10'h3FF;
		MicrorocDac1Vth_Input = 10'h3FF;
		MicrorocDac0Vth_Input = 10'h3FF;
		MicrorocDacEnable_Input = 1;
		MicrorocDacPPEnable_Input = 1;
		MicrorocBandGapEnable_Input = 1;
		MicrorocBandGapPPEnable_Input = 1;
    MicrorocChipID_Input = 8'hA1;
		MicrorocChannelDiscriminatorMask_Input = {192{1'b1}};
		MicrorocLatchedOrDirectOutput_Input = 1;
		MicrorocDiscriminator2PPEnable_Input = 1;
		MicrorocDiscriminator1PPEnable_Input = 1;
		MicrorocDiscriminator0PPEnable_Input = 1;
		MicrorocOTAqPPEnable_Input = 1;
		MicrorocOTAqEnable_Input = 1;
		MicrorocDac4bitPPEnable_Input = 1;
		ChannelAdjust_Input = {256{1'b1}};
		MicrorocHighGainShaperFeedbackSelect_Input = 2'b11;
		MicrorocShaperOutLowGainOrHighGain_Input = 1;
		MicrorocWidlarPPEnable_Input = 1;
		MicrorocLowGainShaperFeedbackSelect_Input = 2'b11;
		MicrorocLowGainShaperPPEnable_Input = 1;
		MicrorocHighGainShaperPPEnable_Input = 1;
		MicrorocGainBoostEnable_Input = 1;
		MicrorocPreAmplifierPPEnable_Input = 1;
		MicrorocCTestChannel_Input = {64{1'b1}};
		MicrorocReadScopeChannel_Input = {64{1'b1}};
		MicrorocExternalRazMode_Input = 2'b11;
		MicrorocExternalRazDelayTime_Input = 4'b1111;
		MicrorocResetTimeStamp_Input = 1;
		MicrorocReadRedundancy_Input = 1;
    #10000;
    reset_n = 1'b0;
    #100;
    reset_n = 1'b1;
    AsicChainSelect = 4'b1;
    #1000;
    MicrorocSlowControlOrReadScopeSelect_Input = 1;
		MicrorocParameterLoadStart_Input = 1;
		MicrorocDataoutChannelSelect_Input = 2'b11;
		MicrorocTransmitOnChannelSelect_Input = 2'b11;
		MicrorocStartReadoutChannelSelect_Input = 1;
		MicrorocEndReadoutChannelSelect_Input = 1;
		MicrorocInternalRazSignalLength_Input = 2'b11;
		MicrorocCkMux_Input = 1;
		MicrorocLvdsReceiverPPEnable_Input = 1;
		MicrorocExternalRazSignalEnable_Input = 1;
		MicrorocInternalRazSignalEnable_Input = 1;
		MicrorocExternalTriggerEnable_Input = 1;
		MicrorocTriggerNor64OrDirectSelect_Input = 1;
		MicrorocTriggerOutputEnable_Input = 1;
		MicrorocTriggerToWriteSelect_Input = 3'b111;
		MicrorocDac2Vth_Input = 10'h3FF;
		MicrorocDac1Vth_Input = 10'h3FF;
		MicrorocDac0Vth_Input = 10'h3FF;
		MicrorocDacEnable_Input = 1;
		MicrorocDacPPEnable_Input = 1;
		MicrorocBandGapEnable_Input = 1;
		MicrorocBandGapPPEnable_Input = 1;
    MicrorocChipID_Input = 8'hA1;
		MicrorocChannelDiscriminatorMask_Input = {192{1'b1}};
		MicrorocLatchedOrDirectOutput_Input = 1;
		MicrorocDiscriminator2PPEnable_Input = 1;
		MicrorocDiscriminator1PPEnable_Input = 1;
		MicrorocDiscriminator0PPEnable_Input = 1;
		MicrorocOTAqPPEnable_Input = 1;
		MicrorocOTAqEnable_Input = 1;
		MicrorocDac4bitPPEnable_Input = 1;
		ChannelAdjust_Input = {256{1'b1}};
		MicrorocHighGainShaperFeedbackSelect_Input = 2'b11;
		MicrorocShaperOutLowGainOrHighGain_Input = 1;
		MicrorocWidlarPPEnable_Input = 1;
		MicrorocLowGainShaperFeedbackSelect_Input = 2'b11;
		MicrorocLowGainShaperPPEnable_Input = 1;
		MicrorocHighGainShaperPPEnable_Input = 1;
		MicrorocGainBoostEnable_Input = 1;
		MicrorocPreAmplifierPPEnable_Input = 1;
		MicrorocCTestChannel_Input = {64{1'b1}};
		MicrorocReadScopeChannel_Input = {64{1'b1}};
		MicrorocExternalRazMode_Input = 2'b11;
		MicrorocExternalRazDelayTime_Input = 4'b1111;
		MicrorocResetTimeStamp_Input = 1;
		MicrorocReadRedundancy_Input = 1;
        #10000;
    reset_n = 1'b0;
    #100;
    reset_n = 1'b1;
    AsicChainSelect = 4'b0010;
    #1000;
    MicrorocSlowControlOrReadScopeSelect_Input = 1;
		MicrorocParameterLoadStart_Input = 1;
		MicrorocDataoutChannelSelect_Input = 2'b11;
		MicrorocTransmitOnChannelSelect_Input = 2'b11;
		MicrorocStartReadoutChannelSelect_Input = 1;
		MicrorocEndReadoutChannelSelect_Input = 1;
		MicrorocInternalRazSignalLength_Input = 2'b11;
		MicrorocCkMux_Input = 1;
		MicrorocLvdsReceiverPPEnable_Input = 1;
		MicrorocExternalRazSignalEnable_Input = 1;
		MicrorocInternalRazSignalEnable_Input = 1;
		MicrorocExternalTriggerEnable_Input = 1;
		MicrorocTriggerNor64OrDirectSelect_Input = 1;
		MicrorocTriggerOutputEnable_Input = 1;
		MicrorocTriggerToWriteSelect_Input = 3'b111;
		MicrorocDac2Vth_Input = 10'h3FF;
		MicrorocDac1Vth_Input = 10'h3FF;
		MicrorocDac0Vth_Input = 10'h3FF;
		MicrorocDacEnable_Input = 1;
		MicrorocDacPPEnable_Input = 1;
		MicrorocBandGapEnable_Input = 1;
		MicrorocBandGapPPEnable_Input = 1;
    MicrorocChipID_Input = 8'hA1;
		MicrorocChannelDiscriminatorMask_Input = {192{1'b1}};
		MicrorocLatchedOrDirectOutput_Input = 1;
		MicrorocDiscriminator2PPEnable_Input = 1;
		MicrorocDiscriminator1PPEnable_Input = 1;
		MicrorocDiscriminator0PPEnable_Input = 1;
		MicrorocOTAqPPEnable_Input = 1;
		MicrorocOTAqEnable_Input = 1;
		MicrorocDac4bitPPEnable_Input = 1;
		ChannelAdjust_Input = {256{1'b1}};
		MicrorocHighGainShaperFeedbackSelect_Input = 2'b11;
		MicrorocShaperOutLowGainOrHighGain_Input = 1;
		MicrorocWidlarPPEnable_Input = 1;
		MicrorocLowGainShaperFeedbackSelect_Input = 2'b11;
		MicrorocLowGainShaperPPEnable_Input = 1;
		MicrorocHighGainShaperPPEnable_Input = 1;
		MicrorocGainBoostEnable_Input = 1;
		MicrorocPreAmplifierPPEnable_Input = 1;
		MicrorocCTestChannel_Input = {64{1'b1}};
		MicrorocReadScopeChannel_Input = {64{1'b1}};
		MicrorocExternalRazMode_Input = 2'b11;
		MicrorocExternalRazDelayTime_Input = 4'b1111;
		MicrorocResetTimeStamp_Input = 1;
		MicrorocReadRedundancy_Input = 1;
        #10000;
    reset_n = 1'b0;
    #100;
    reset_n = 1'b1;
    AsicChainSelect = 4'b0011;
    #1000;
    MicrorocSlowControlOrReadScopeSelect_Input = 1;
		MicrorocParameterLoadStart_Input = 1;
		MicrorocDataoutChannelSelect_Input = 2'b11;
		MicrorocTransmitOnChannelSelect_Input = 2'b11;
		MicrorocStartReadoutChannelSelect_Input = 1;
		MicrorocEndReadoutChannelSelect_Input = 1;
		MicrorocInternalRazSignalLength_Input = 2'b11;
		MicrorocCkMux_Input = 1;
		MicrorocLvdsReceiverPPEnable_Input = 1;
		MicrorocExternalRazSignalEnable_Input = 1;
		MicrorocInternalRazSignalEnable_Input = 1;
		MicrorocExternalTriggerEnable_Input = 1;
		MicrorocTriggerNor64OrDirectSelect_Input = 1;
		MicrorocTriggerOutputEnable_Input = 1;
		MicrorocTriggerToWriteSelect_Input = 3'b111;
		MicrorocDac2Vth_Input = 10'h3FF;
		MicrorocDac1Vth_Input = 10'h3FF;
		MicrorocDac0Vth_Input = 10'h3FF;
		MicrorocDacEnable_Input = 1;
		MicrorocDacPPEnable_Input = 1;
		MicrorocBandGapEnable_Input = 1;
		MicrorocBandGapPPEnable_Input = 1;
    MicrorocChipID_Input = 8'hA1;
		MicrorocChannelDiscriminatorMask_Input = {192{1'b1}};
		MicrorocLatchedOrDirectOutput_Input = 1;
		MicrorocDiscriminator2PPEnable_Input = 1;
		MicrorocDiscriminator1PPEnable_Input = 1;
		MicrorocDiscriminator0PPEnable_Input = 1;
		MicrorocOTAqPPEnable_Input = 1;
		MicrorocOTAqEnable_Input = 1;
		MicrorocDac4bitPPEnable_Input = 1;
		ChannelAdjust_Input = {256{1'b1}};
		MicrorocHighGainShaperFeedbackSelect_Input = 2'b11;
		MicrorocShaperOutLowGainOrHighGain_Input = 1;
		MicrorocWidlarPPEnable_Input = 1;
		MicrorocLowGainShaperFeedbackSelect_Input = 2'b11;
		MicrorocLowGainShaperPPEnable_Input = 1;
		MicrorocHighGainShaperPPEnable_Input = 1;
		MicrorocGainBoostEnable_Input = 1;
		MicrorocPreAmplifierPPEnable_Input = 1;
		MicrorocCTestChannel_Input = {64{1'b1}};
		MicrorocReadScopeChannel_Input = {64{1'b1}};
		MicrorocExternalRazMode_Input = 2'b11;
		MicrorocExternalRazDelayTime_Input = 4'b1111;
		MicrorocResetTimeStamp_Input = 1;
		MicrorocReadRedundancy_Input = 1;



        
		// Add stimulus here

	end
  localparam LOW = 13;
  localparam HIGH = 12;
  always begin
    #(LOW) Clk = ~Clk;
    #(HIGH) Clk = ~Clk;
  end  
endmodule

