`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Yu Wang
//
// Create Date: 2018/05/25 17:41:11
// Design Name: SDHCAL DIF 1V0
// Module Name: ExternalRazGenerate
// Project Name: SDHCAL DIF 1V0
// Target Devices: XC7A100TFGG484-2L
// Tool Versions: Vivado 2018.1
// Description: This module generates the external RAZ signal when the
// trigger is assert.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module ExternalRazGenerate(
	input Clk,
	input reset_n,
	input TriggerIn,
	input ExternalRaz_en,
	input [3:0] ExternalRazDelayTime,
	input [1:0] RazMode,
	input ForceRaz,
	output reg RAZ_CHN
	);
	reg TriggerIn1;
	reg TriggerIn2;
	always @(posedge Clk or negedge reset_n) begin
		if(~reset_n) begin
			TriggerIn1 <= 1'b0;
			TriggerIn2 <= 1'b0;
		end
		else begin
			TriggerIn1 <= TriggerIn;
			TriggerIn2 <= TriggerIn1;
		end
	end
	wire TriggerInRise;
	reg SingleRaz_en;
	assign TriggerInRise = ExternalRaz_en && TriggerIn1 && (~TriggerIn2);
	// Generate the delayed enable signal
	reg [3:0] RazDelayCount;
	always @(posedge Clk or negedge reset_n) begin
		if(~reset_n) begin
			SingleRaz_en <= 1'b0;
			RazDelayCount <= 4'b0;
		end
		else if(RazDelayCount == ExternalRazDelayTime) begin
			RazDelayCount <= 4'b0;
			SingleRaz_en <= 1'b1;
		end
		else if(RazDelayCount < ExternalRazDelayTime && (TriggerInRise || RazDelayCount != 4'b0)) begin
			SingleRaz_en <= 1'b0;
			RazDelayCount <= RazDelayCount + 1'b1;
		end
		else begin
			SingleRaz_en <= 1'b0;
			RazDelayCount <= 4'b0;
		end
	end

	reg [5:0] DELAY_CONST;
	always @ (RazMode) begin
		case(RazMode)
			2'b00:DELAY_CONST = 6'd3; //75ns
			2'b01:DELAY_CONST = 6'd10;//250ns
			2'b10:DELAY_CONST = 6'd20;//500ns
			2'b11:DELAY_CONST = 6'd40;//1us
		endcase
	end

	reg [5:0] RazModeCounter;
	reg Raz_r1;
	reg Raz_r2;
	always @(posedge Clk or negedge reset_n) begin
		if(~reset_n) begin
			Raz_r1 <= 1'b0;
			Raz_r2 <= 1'b0;
		end
		else begin
			Raz_r1 <= SingleRaz_en;
			Raz_r2 <= Raz_r1;
		end
	end
	wire RazEnableRise = Raz_r1 && (~Raz_r2);
	always @ (posedge Clk , negedge reset_n) begin
		if(~reset_n) begin
			RAZ_CHN <= 1'b0;
			RazModeCounter <= 6'b0;
		end
		else if (ForceRaz)begin
			RAZ_CHN <= 1'b1;
		end
		else if(RazEnableRise || (RazModeCounter < DELAY_CONST && RazModeCounter != 6'd0))begin
			RAZ_CHN <= 1'b1;
			RazModeCounter <= RazModeCounter +1'b1;
		end
		else begin
			RAZ_CHN <= 1'b0;
			RazModeCounter <= 6'b0;
		end
	end
endmodule
