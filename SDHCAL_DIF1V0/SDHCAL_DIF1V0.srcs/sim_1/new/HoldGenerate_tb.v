`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/05/25 18:46:34
// Design Name:
// Module Name: HoldGenerate_tb
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


module HoldGenerate_tb();
	reg Clk;
	reg SyncClk;
	reg reset_n;
	reg TriggerIn;
	reg Hold_en;
	reg [7:0] HoldDelay;
	reg [15:0] HoldTime;
	wire HoldOut;

	HoldGenerate uut(
		.Clk      (Clk),
		.SyncClk  (SyncClk),
		.reset_n  (reset_n),
		.TriggerIn(TriggerIn),
		.Hold_en  (Hold_en),
		.HoldDelay(HoldDelay),
		.HoldTime (HoldTime),
		.HoldOut  (HoldOut)
		);
	initial begin
		Clk = 1'b0;
		SyncClk = 1'b0;
		reset_n = 1'b0;
		TriggerIn = 1'b0;
		Hold_en = 1'b0;
		HoldDelay = 8'd11;
		HoldTime = 16'd1024;
		#100;
		reset_n = 1'b1;
		#1006;
		TriggerIn = 1'b1;
		#204;
		TriggerIn = 1'b0;
		#1000;
		Hold_en = 1'b1;
		#508;
		TriggerIn = 1'b1;
		#302;
		TriggerIn = 1'b0;
	end
	localparam Low = 12;
	localparam High = 13;
	always begin
		# Low Clk = ~Clk;
		#High Clk = ~Clk;
	end
	localparam PEROID = 10;
	always #(PEROID/2) SyncClk = ~SyncClk;
endmodule
