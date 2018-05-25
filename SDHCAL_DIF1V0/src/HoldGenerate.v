`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Yu Wang
//
// Create Date: 2018/05/25 18:20:56
// Design Name: SDHCAL DIF 1V0
// Module Name: HoldGenerate
// Project Name: SDHCAL DIF 1V0
// Target Devices: SC7A100TFGG484-2L
// Tool Versions: Vivado 2018.1
// Description: This module generates a hold signal when the trigger is
// assert. Use a fast clock to synchronous the TriggerIn to insure the Hold
// delay
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module HoldGenerate(
	input Clk,
	input SyncClk,
	input reset_n,
	input TriggerIn,
	input Hold_en,
	input [7:0] HoldDelay,
	input [15:0] HoldTime,
	output reg HoldOut
	);
	reg [255:0] TriggerShift;
	always @(posedge SyncClk or negedge reset_n) begin
		if(~reset_n) begin
			TriggerShift <= 256'b0;
		end
		else begin
			TriggerShift <= {TriggerShift[254:0],TriggerIn};
		end
	end
	wire TriggerDelayed = TriggerShift[HoldDelay];
	reg ResetHold_n;
	reg [15:0] HoldTimeCount;
	always @(posedge Clk or negedge reset_n) begin
		if(~reset_n) begin
			ResetHold_n <= 1'b0;
			HoldTimeCount <= 16'b0;
		end
		else if(HoldTimeCount == HoldTime) begin
			HoldTimeCount <= 16'b0;
			ResetHold_n <= 1'b0;
		end
		else if((HoldTimeCount < HoldTime) && (HoldOut || HoldTimeCount != 0)) begin
			ResetHold_n <= 1'b1;
			HoldTimeCount <= HoldTimeCount + 1'b1;
		end
		else begin
			ResetHold_n <= 1'b1;
			HoldTimeCount <= 16'b0;
		end
	end
	always @(posedge TriggerDelayed or negedge ResetHold_n) begin
		if(~ResetHold_n)
			HoldOut <= 1'b0;
		else if(Hold_en)
			HoldOut <= 1'b1;
		else
			HoldOut <= 1'b0;
	end
endmodule
