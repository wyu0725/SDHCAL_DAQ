`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Yu Wang
//
// Create Date: 2018/07/19 17:38:08
// Design Name: SDHCAL DIF 1V0
// Module Name: RamReadDoneSync
// Project Name: SDHCAL DIF 1V0
// Target Devices: XC7A100TFGG484-2L
// Tool Versions: Vivado 2018.1
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module RamReadDoneSync4Chain
(
  input Clk,
  input reset_n,
  input [3:0] OnceEnd,
  input [3:0] EndReadoutParameter,
  output reg RamReadoutDone
  );

  reg EndReadout1Hit;
  reg EndReadout2Hit;
  reg EndReadout3Hit;
  reg EndReadout4Hit;
  reg ResetEndReadout_n;
  always @ (posedge OnceEnd[0] or negedge ResetEndReadout_n) begin
    if(~ResetEndReadout_n)
      EndReadout1Hit <= 1'b0;
    else
      EndReadout1Hit <= 1'b1;
  end
  always @ (posedge OnceEnd[1] or negedge ResetEndReadout_n) begin
    if(~ResetEndReadout_n)
      EndReadout2Hit <= 1'b0;
    else
      EndReadout2Hit <= 1'b1;
  end
  always @ (posedge OnceEnd[2] or negedge ResetEndReadout_n) begin
    if(~ResetEndReadout_n)
      EndReadout3Hit <= 1'b0;
    else
      EndReadout3Hit <= 1'b1;
  end
  always @ (posedge OnceEnd[3] or negedge ResetEndReadout_n) begin
    if(~ResetEndReadout_n)
      EndReadout4Hit <= 1'b0;
    else
      EndReadout4Hit <= 1'b1;
  end
  reg EndReadout;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n)
      EndReadout <= 1'b0;
    else
      EndReadout = {EndReadout4Hit, EndReadout3Hit, EndReadout2Hit, EndReadout1Hit} == EndReadoutParameter;
  end

  reg [3:0] HoldCount;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      RamReadoutDone <= 1'b0;
      HoldCount <= 4'b0;
      ResetEndReadout_n <= 1'b1;
    end
    else if(EndReadout || (HoldCount != 4'b0 && HoldCount <= 4'd10)) begin
      RamReadoutDone <= 1'b1;
      HoldCount <= HoldCount + 1'b1;
      ResetEndReadout_n <= 1'b0;
    end
    else begin
      RamReadoutDone <= 1'b0;
      ResetEndReadout_n <= 1'b1;
      HoldCount <= 4'd0;
    end
  end
endmodule
