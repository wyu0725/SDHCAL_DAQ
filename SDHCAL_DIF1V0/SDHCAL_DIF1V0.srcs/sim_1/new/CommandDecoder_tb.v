`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/06/27 17:20:45
// Design Name:
// Module Name: CommandDecoder_tb
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


module CommandDecoder_tb();
	localparam COMMAND_WIDTH = 0;
	reg Clk;
	reg reset_n;
	reg CommandFifoReadEn;
	reg [15:0] COMMAND_WORD;
	wire [COMMAND_WIDTH:0] CommandOut;
	wire CommandOut_r;
	assign CommandOut_r = CommandOut;

	//instance: ../../../src/CommandDecoder.v
	CommandDecoder
	#(
		.LEVEL_OR_PULSE(1'b0),
		.COMMAND_WIDTH(COMMAND_WIDTH),
		.COMMAND_ADDRESS_AND_DEFAULT(16'hF0F0)
	)
	uut(
		.Clk(Clk),
		.reset_n(reset_n),
		.CommandFifoReadEn(CommandFifoReadEn),
		.COMMAND_WORD(COMMAND_WORD),
		// input [COMMAND_WIDTH:0] DefaultValue,
		.CommandOut(CommandOut)
		);

	initial begin
		Clk = 1'b0;
		reset_n = 1'b0;
		CommandFifoReadEn = 1'b0;
		COMMAND_WORD = 16'b0;
		#110;
		reset_n = 1'b1;
		#1003;
		CommandFifoReadEn = 1'b1;
		COMMAND_WORD = 16'hAAF2;
		#25;
		CommandFifoReadEn = 1'b0;
		#1000;
		COMMAND_WORD = 16'hF0FF;
		CommandFifoReadEn = 1'b1;
		#25;
		CommandFifoReadEn = 1'b0;
	end
	localparam Low = 13;
	localparam High = 12;
	always begin
		#(Low) Clk = ~Clk;
		#(High) Clk = ~Clk;
	end
endmodule
