`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/05/28 14:57:15
// Design Name:
// Module Name: TimeStampAndDataTrigger_tb
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


module TimeStampAndDataTrigger_tb();
	reg Clk;
	reg reset_n;
	reg TimeStampReset;
	wire RST_COUNTERB;
	reg DataTrigger;
	reg DataTriggerEnable;
	wire TriggerExt;
	TimeStampSyncAndDataTrigger uut (
		.Clk(Clk),
		.reset_n(reset_n),
		.TimeStampReset(TimeStampReset),
		.RST_COUNTERB(RST_COUNTERB),
		.DataTrigger(DataTrigger),
		.DataTriggerEnable(DataTriggerEnable),
		.TriggerExt(TriggerExt)
		);
	localparam PEROID = 25;
	localparam Low = 12;
	localparam High = 13;
	initial begin
		Clk = 1'b0;
		reset_n = 1'b0;
		TimeStampReset = 1'b0;
		DataTrigger = 1'b0;
		DataTriggerEnable = 1'b0;
		#100;
		reset_n = 1'b1;
		#33;
		TimeStampReset = 1'b1;
		DataTrigger = 1'b1;
		#PEROID;
		TimeStampReset = 1'b0;
		DataTrigger = 1'b0;
		#1000;
		DataTriggerEnable = 1'b1;
		#100;
		DataTrigger = 1'b1;
		#(PEROID*5);
		DataTrigger = 1'b0;
		#1004;
		DataTrigger = 1'b1;
		#PEROID;
		DataTrigger = 1'b0;
		TimeStampReset = 1'b1;
		#PEROID;
		TimeStampReset = 1'b0;



	end
	always begin
		#Low Clk = ~Clk;
		#High Clk = ~Clk;
	end
endmodule
