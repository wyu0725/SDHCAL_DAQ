`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Yu Wang
//
// Create Date: 2018/06/27 15:22:58
// Design Name: SDHCAL DIF 1V0
// Module Name: CommandDecoder
// Project Name: SDHCAL DIF 1V0
// Target Devices: XC7A100TFGG484-2l
// Tool Versions: Vivado 2018.1
// Description: As desccriped in the upper module, the command need to be
// decoded by address and sub-address. The maxumun command length is
//
// Dependencies: CommandInterpreter.v___
// 									    |
// 										|________________CommandDecoder.v
// 										|
// 										|________________CommandDecoder.v
// 										|
// 										|________________CommandDecoder.v
// 										|
// 										|...
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module CommandDecoder
	#(
		parameter LEVEL_OR_PULSE = 1'b1,
		parameter [1:0] COMMAND_WIDTH = 2'b0,
		parameter [15:0] COMMAND_ADDRESS_AND_DEFAULT = 16'hFFFF
	)
	(
	input Clk,
	input reset_n,
	input CommandFifoReadEn,
	input [15:0] COMMAND_WORD,
	// input [COMMAND_WIDTH:0] DefaultValue,
	output reg [COMMAND_WIDTH:0] CommandOut
	);

	always @ (posedge Clk or negedge reset_n) begin
		if(~reset_n)
			CommandOut <= COMMAND_ADDRESS_AND_DEFAULT[COMMAND_WIDTH:0];
		else if(CommandFifoReadEn && COMMAND_WORD[15:4] == COMMAND_ADDRESS_AND_DEFAULT[15:4])
			CommandOut <= COMMAND_WORD[COMMAND_WIDTH:0];
		else
			CommandOut <= LEVEL_OR_PULSE ? CommandOut : COMMAND_ADDRESS_AND_DEFAULT[COMMAND_WIDTH:0];
	end
endmodule
