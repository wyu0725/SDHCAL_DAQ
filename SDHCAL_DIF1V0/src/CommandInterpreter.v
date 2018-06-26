`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/06/26 11:01:14
// Design Name:
// Module Name: CommandInterpreter
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

parameter ASIC_CHAIN_NUMBER = 4; // 1 stands for [1:0], that is 4 ASIC chains
module CommandInterpreter(
	input Clk,
	input IFCLK,
	input reset_n,
	// USB interface
	input CommandWordEn,
	input [15:0] CommandWord,
	//--- Command ---//
	output AcquisitionStartStop,
	output ResetDataFifo,
	//*** MICROROC slow control parameter
	output reg MicrorocSlowOrReadScopeSelect,
	output reg MicrorocParameterLoadStart,
	output reg [1:0] MicrorocDataoutChannelSelect,
	output reg [1:0] MicrorocTransmitOnChannelSelect,
	// ChipSatbEnable
	output reg MicrorocStartReadoutChannelSelect,
	output reg MicrorocEndReadoutChannelSelect,
	// [1:0] NC
	output reg [1:0] MicrorocInternalRazSignalLength,
	output reg MicrorocCkMux,
	output reg MicrorocLvdsReceiverPPEnable,
	output reg MicrorocExternalRazSignalEnable,
	output reg MicrorocInternalRazSignalEnable,
	output reg MicrorocExternalTriggerEnable,
	output reg MicrorocTriggerNor64OrDirectSelect,
	output reg MicrorocTriggerOutputEnable,
	output reg [2:0] MicrorocTriggerToWriteSelect,
	output reg [9:0] MicrorocDac2Vth,
	output reg [9:0] MicrorocDac1Vth,
	output reg [9:0] MicrorocDac0Vth,
	output reg MicrorocDacEnable,
	output reg MicrorocDacPPEnable,
	output reg MicrorocBandGapEnable,
	output reg MicrorocBandGapPPEnable,
	output reg [7:0] MicrorocChipID,
	output reg [191:0] MicrorocChannelDiscriminatorMask,
	output reg MicrorocLatchedOrDirectOutput,
	output reg MicrorocDisciminator2PPEnable,
	output reg MicrorocDisciminator1PPEnable,
	output reg MicrorocDisciminator0PPEnable,
	output reg MicrorocOTAqPPEnable,
	output reg MicrorocOTAqEnable,
	output reg MicrorocDac4bitPPEnable,
	output reg [255:0] ChannelAdjust,
	output reg [1:0] MicrorocHighGainShaperFeedbackSelect,
	output reg MicrorocShaperOutLowGainOrHighGain,
	output reg MicrorocWidlarPPEnable,
	output reg [1:0] MicrorocLowGainShaperFeedbackSelect,
	output reg MicrorocLowGainShaperPPEnable,
	output reg MicrorocHighGainShaperPPEnable,
	output reg MicrorocGainBoostEnable,
	output reg MicororcPreAmplifierPPEnable,
	output reg [63:0] MicrorocCTestChannel,
	output reg [63:0] MicrorocReadScopeChannel,
	//*** Acquisition Control
	// Mode Select
	output reg [2:0] ModeSelect,
	output reg [1:0] DacSelect,
	// Sweep Dac parameter
	output reg [9:0] StartDac,
	output reg [9:0] EndDac,
	output reg [9:0] AdcStep,
	// SCurve Test Port
	output reg SingleOr64Channel,
	output reg CTestOrInput,
	output reg [5:0] SingleTestChannel,
	output reg [15:0] CPT_MAX,
	output reg [3:0] TriggerDelay,
	output reg SweepTestStartStop,
	output reg UnmaskAlllChannel,
	// Count Efficiency
	output reg TriggerEfficiencyOrCountEfficiency,
	output reg [15:0] CounterMax,
	input SweepTestDone,
	input UsbFifoEmpty,
	// Sweep Acq
	output reg [15:0] MaxPackageNumber,
	// Reset Microroc
	output reg ForceMicrorocAcqReset,
	// ADC Control
	output reg AdcStartStop,
	output reg [3:0] AdcStartDelayTime,
	output reg [7:0] AdcDataNumber,
	// Slave DAQ
	output reg [15:0] EndHoldTime,
	output reg DaqSelect,
	// LED
	output reg [7:0] LED
	);
endmodule
