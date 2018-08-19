`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/08/15 10:48:03
// Design Name:
// Module Name: SpiMaster_tb
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


module SpiMaster_tb();

  reg Clk;
  reg reset_n;
  reg [15:0] SerialData;
  reg DataoutStart;
  wire DataoutDone;
  wire SCLK;
  wire SDI;
  wire nCS;

  //instance:../../../src/SpiMaster.v
  SpiMaster uut(
    .Clk(Clk),
    .reset_n(reset_n),
    .SerialData(SerialData),
    .DataoutStart(DataoutStart),
    .DataoutDone(DataoutDone),
    .SCLK(SCLK),
    .SDI(SDI),
    .nCS(nCS)
    );

  initial begin
    Clk = 1'b0;
    reset_n = 1'b0;
    SerialData = 16'b0;
    DataoutStart = 1'b0;
    #100;
    reset_n = 1'b1;
    #500;
    SerialData = 16'hABCD;
    #100;
    DataoutStart = 1'b1;
    #25;
    DataoutStart = 1'b0;
  end
  localparam LOW = 13;
  localparam HIGH = 12;
  always begin
    #LOW; Clk = ~Clk;
    #HIGH; Clk = ~Clk;
  end
endmodule
