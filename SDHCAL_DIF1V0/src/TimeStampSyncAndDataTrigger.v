`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/28 11:13:24
// Design Name: 
// Module Name: TimeStampSyncAndDataTrigger
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


module TimeStampSyncAndDataTrigger(
	input Clk,
	input reset_n,
	input TimeStampReset,
	output reg RST_COUNTERB,
	input DataTrigger,
	input DataTriggerEnable,
	output reg TriggerExt
    );
	
	// Genetate 1us RST_COUNTERB signal
	reg [5:0] ResetCounter;
	always @ (posedge Clk or negedge reset_n) begin
		if(~reset_n) begin
			RST_COUNTERB <= 1'b1;
			ResetCounter <= 6'd0;
		end
		else if(ResetCounter < 6'd40 && (TimeStampReset || ResetCounter != 6'd0)) begin
			RST_COUNTERB <= 1'b0;
			ResetCounter <= ResetCounter + 1'b1;
		end
		else begin
			RST_COUNTERB <= 1'b1;
			ResetCounter <= 6'd0;
		end
	end

	// When DataTrigger is valid, set TriggerExt high in one clock peroid
	reg ResetDataTrigger;

	always @ (posedge DataTrigger or negedge ResetDataTrigger) begin
		if(~ResetDataTrigger) 
			TriggerExt <= 1'b0;
		else if(DataTriggerEnable)
			TriggerExt <= 1'b1;
		else
			TriggerExt <= 1'b0;;
	end 
	reg TriggerExt_i;
	always @ (posedge Clk or negedge reset_n) begin
		if(~reset_n)
			TriggerExt_i <= 1'b0;
		else
			TriggerExt_i <= TriggerExt;
	end	
	always @ (posedge Clk or negedge reset_n) begin
		if(~reset_n)
			ResetDataTrigger <= 1'b1;
		else if(TriggerExt_i)
			ResetDataTrigger <= 1'b0;
		else
			ResetDataTrigger <= 1'b1;
	end
endmodule
