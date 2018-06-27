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
	reg CommandEn;
	reg [15:0] CommandWord;
	reg [COMMAND_WIDTH:0] DefaultValue;
	wire [COMMAND_WIDTH:0] CommandOut;
	CommandDecoder
	#(
		.COMMAND_WIDTH(0) ,
		.COMMAND_ADDRESS(16'hF0F) 
	)
	uut (
	.Clk(Clk),
	.reset_n(reset_n),
	.CommandEn(CommandEn),
	.CommandWord(CommandWord),
	.DefaultValue(DefaultValue),
	.CommandOut(CommandOut)
	);

	initial begin
		Clk = 1'b0;
		reset_n = 1'b0;
		CommandEn = 1'b0;
		CommandWord = 16'b0;
		DefaultValue = 3'b0;
		#110;
		reset_n = 1'b1;
		#1003;
		CommandEn = 1'b1;
		CommandWord = 16'hAAF2;
		#25;
		CommandEn = 1'b0;
		#1000;
		CommandWord = 16'hF0F2;
		CommandEn = 1'b1;
		#25;
		CommandEn = 1'b0;
	end
	localparam Low = 13;
	localparam High = 12;
	always begin
		#(Low) Clk = ~Clk;
		#(High) Clk = ~Clk;
	end
endmodule
