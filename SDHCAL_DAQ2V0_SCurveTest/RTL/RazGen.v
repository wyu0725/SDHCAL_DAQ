`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Yu Wang
// 
// Create Date: 2017/06/17 11:00:35
// Design Name: 
// Module Name: RazGen
// Project Name: 
// Target Devices: XC7A100TFGG484-2
// Tool Versions: Vivado 16.3
// Description: This module is used to generate the 
// external raz enable signal for Trig_Gen module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RazGen(
    input Clk,
    input reset_n,
    input ExternalRaz_en,
    input [3:0] ExternalRazDelayTime,
    output reg SingleRaz_en
    );
    always @(posedge Clk or negedge reset_n) begin
      if(~reset_n) begin
      end
      else begin
      end
    end
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
      else if(RazDelayuCount < ExternalRazDelayTime && (TrigAndRise || RazDelayCount != 4'b0)) begin
        SignelRaz_en <= 1'b0;
        RazDelayCount <= RazDelayCount + 1'b1;
      end
      else begin
        SingleRaz_en <= 1'b0;
        RazDelayCount <= 4'b0;
      end
    end
endmodule
