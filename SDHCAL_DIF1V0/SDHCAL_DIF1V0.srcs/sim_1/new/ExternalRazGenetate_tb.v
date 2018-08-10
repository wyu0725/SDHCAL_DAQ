`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/25 17:54:25
// Design Name: 
// Module Name: ExternalRazGenetate_tb
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


module ExternalRazGenetate_tb();
	reg Clk;
	reg reset_n;
	reg TriggerIn;
	reg ExternalRaz_en;
	reg [3:0] ExternalRazDelayTime;
	reg [1:0] RazMode;
	reg ForceRaz;
	wire RAZ_CHN;

	ExternalRazGenerate uut(
	.Clk(Clk),
	.reset_n(reset_n),
	.TriggerIn(TriggerIn),
	.ExternalRaz_en(ExternalRaz_en),
	.ExternalRazDelayTime(ExternalRazDelayTime),
	.RazMode(RazMode),
	.ForceRaz(ForceRaz),
	.RAZ_CHN(RAZ_CHN)
	);
	localparam PEROID = 25;
	initial begin
		Clk = 1'b0;
		reset_n = 1'b0;
		TriggerIn = 1'b0;
		ExternalRaz_en = 1'b0;
		ExternalRazDelayTime = 4'd5;
		RazMode = 2'd2;
		ForceRaz = 0;
		#100;
		reset_n = 1'b1;
		#1000;
		TriggerIn = 1'b1;
		#PEROID;
		TriggerIn = 1'b0;
		#1000;
		ExternalRaz_en = 1'b1;
		#200;
		TriggerIn = 1'b1;
		#PEROID;
		TriggerIn = 1'b0;
		#2000;
		ForceRaz = 1'b1;
		#100;
		TriggerIn = 1'b1;
		#PEROID;
		TriggerIn = 1'b0;
		#1000;
		ForceRaz = 1'b0;
		#500;
		RazMode = 2'd0;
		#100;
		TriggerIn = 1'b1;
		#PEROID;
		TriggerIn = 1'b0;
    #262;
    TriggerIn = 1'b1;
    #PEROID;
    TriggerIn = 1'b0;
	end
	localparam Low = 12;
	localparam High = 13;
	always begin
		#Low Clk = ~Clk;
		#High Clk = ~Clk;
	end
endmodule
