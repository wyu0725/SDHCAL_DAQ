`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Science and Technology of China
// Engineer: JunbinZhang
// 
// Create Date: 11/17/2016 03:25:58 PM
// Design Name: SDHCAL_DAQ2V0
// Module Name: PULSESYNC
// Project Name: SDHCAL_DAQ2V0
// Target Devices: XC7A100TFGG484
// Tool Versions: Vivado 2016.3
// Description: this is a pulse synchronizer
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PULSESYNC(
	input clk_src,
	input reset_n,
	input pulse_src,
	input clk_dst,
	output pulse_dst
    );
	//-------source time domain------------//
	reg toggle_reg;
	always @(posedge clk_src or negedge reset_n) begin
		if (~reset_n) 
			toggle_reg <= 1'b0;
		else if (pulse_src)
			toggle_reg <= ~toggle_reg;
	end
	//------destination time domain--------//
	reg [2:0] sync_reg;
	always @(posedge clk_dst ) begin
		if (~reset_n) 
			sync_reg <= 3'b0;
		else 
			sync_reg <= {sync_reg[1:0], toggle_reg};	
	end
	//Xor to generate the pulse_dst
	assign pulse_dst = sync_reg[1] ^ sync_reg[2];
endmodule
