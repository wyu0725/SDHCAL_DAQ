`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Yu Wang
// 
// Create Date: 2018/05/25 15:22:14
// Design Name: SDHCAL DIF 1V0
// Module Name: Redundancy
// Project Name: SDHCAL DIF 1V0
// Target Devices: XC7A100TFGG484-2L
// Tool Versions: Vivado 2018.1
// Description: This module decides which readout channel is used. Both
// dout and transmiton channel canbe selected in slow control parameter, but
// there is only one data chain. So that, only one readout out channel can be
// selected, which is controled be command interpret module.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Redundancy(
	input ReadoutChannelSelect,
	//*** Readout control
	input StartReadout,
	output EndReadout,
	output Dout,
	output TransmitOn,
	
	//*** Pins
	output START_READOUT1,
	output START_READOUT2,
	input END_READOUT1,
	input END_READOUT2,
	
	input DOUT1B,
	input DOUT2B,
	input TRANSMIION1B,
	input TRANSMITON2B
    );
	assign EndReadout = ReadoutChannelSelect ? END_READOUT1 : END_READOUT2;
	assign START_READOUT1 = ReadoutChannelSelect ? StartReadout : 1'b0;
	assign START_READOUT2 = ReadoutChannelSelect ? 1'b0 : StartReadout;
	assign Dout = ReadoutChannelSelect ? DOUT1B : DOUT2B;
	assign TransmitOn = ReadoutChannelSelect ? TRANSMITON1B : TRANSMITON2B;
endmodule
