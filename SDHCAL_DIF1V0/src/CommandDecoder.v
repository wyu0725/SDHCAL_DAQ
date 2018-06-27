`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/06/27 15:22:58
// Design Name:
// Module Name: CommandDecoder
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


module CommandDecoder
	#(
		parameter [1:0]COMMAND_WIDTH = 2'b0,
		parameter [11:0] COMMAND_ADDRESS = 12'hFFF
	)
	(
	input Clk,
	input reset_n,
	input CommandEn,
	input [15:0] CommandWord,
	input [COMMAND_WIDTH:0] DefaultValue,
	output reg [COMMAND_WIDTH:0] CommandOut
	);

	always @ (posedge Clk or negedge reset_n) begin
		if(~reset_n)
			CommandOut <= DefaultValue;
		else if(CommandEn && CommandWord[15:4] == COMMAND_ADDRESS)
			CommandOut <= CommandWord[COMMAND_WIDTH:0];
		else
			CommandOut <= CommandOut;
	end
endmodule
