`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/26 16:21:40
// Design Name: 
// Module Name: ConfigurationParameterDistribution
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


module ConfigurationParameterDistribution(
    input Clk,
    input reset_n,
	// MICROROC slow control parameter
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocSlowOrReadScopeSelect,
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocParameterLoadStart,
	output reg [2*ASIC_CHAIN_NUMBER - 1:0] MicrorocDataoutChannelSelect,
	output reg [2*ASIC_CHAIN_NUMBER - 1:0] MicrorocTransmitOnChannelSelect,
	// ChipSatbEnable
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocStartReadoutChannelSelect,
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocEndReadoutChannelSelect,
	// [1:0] NC
	output reg [2*ASIC_CHAIN_NUMBER - 1:0] MicrorocInternalRazSignalLength,
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocCkMux,
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocLvdsReceiverPPEnable,
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocExternalRazSignalEnable,
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocInternalRazSignalEnable,
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocExternalTriggerEnable,
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocTriggerNor64OrDirectSelect,
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocTriggerOutputEnable,
	output reg [3*ASIC_CHAIN_NUMBER - 1:0] MicrorocTriggerToWriteSelect,
	output reg [10*ASIC_CHAIN_NUMBER - 1:0] MicrorocDac2Vth,
	output reg [10*ASIC_CHAIN_NUMBER - 1:0] MicrorocDac1Vth,
	output reg [10*ASIC_CHAIN_NUMBER - 1:0] MicrorocDac0Vth,
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocDacEnable,
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocDacPPEnable,
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocBandGapEnable,
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocBandGapPPEnable,
	output reg [8*ASIC_CHAIN_NUMBER - 1:0] MicrorocChipID,
	output reg [192*ASIC_CHAIN_NUMBER - 1:0] MicrorocChannelDiscriminatorMask,
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocLatchedOrDirectOutput,
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocDisciminator2PPEnable,
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocDisciminator1PPEnable,
	output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocDisciminator0PPEnable
    );
endmodule
