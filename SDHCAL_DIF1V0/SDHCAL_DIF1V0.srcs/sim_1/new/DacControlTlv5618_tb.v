`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/10/20 11:49:07
// Design Name:
// Module Name: DacControlTlv5618_tb
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


module DacControlTlv5618_tb(

  );

  reg Clk;
  reg reset_n;
  reg PowerDown;
  reg Speed;
  reg [11:0] Dac1Data;
  reg [11:0] Dac2Data;
  reg [1:0] LoadDacSelect;
  reg DacLoadStart;
  wire DacLoadDone;
  wire nCS;
  wire SCLK;
  wire DIN;

  //instance:../../../src/DacControlTlv5618.v
  DacControlTlv5618 uut(
    .Clk(Clk),
    .reset_n(reset_n),
    .PowerDown(PowerDown),// 1 -> power down, 0 -> normal mode
    .Speed(Speed),  // 1 -> fast mode, 0 -> slow mode
    .Dac1Data(Dac1Data),
    .Dac2Data(Dac2Data),
    .LoadDacSelect(LoadDacSelect),
    .DacLoadStart(DacLoadStart),
    .DacLoadDone(DacLoadDone),
    .nCS(nCS),
    .SCLK(SCLK),
    .DIN(DIN)
    );

  initial begin
    Clk = 1'b0;
    reset_n = 1'b0;
    PowerDown = 1'b0;
    Speed = 1'b1;
    Dac1Data = 12'h5ad;
    Dac2Data = 12'h3d9;
    LoadDacSelect = 2'b0;
    DacLoadStart = 1'b0;
    #100;
    reset_n = 1'b1;
    #13;
    #1000;
    LoadDacSelect = 2'b01;
    #100;
    DacLoadStart = 1'b1;
    #25;
    DacLoadStart = 1'b0;
    #5000;
    LoadDacSelect = 2'b10;
    #100;
    DacLoadStart = 1'b1;
    #25;
    DacLoadStart = 1'b0;
    #5000;
    LoadDacSelect = 2'b11;
    #100;
    DacLoadStart = 1'b1;
    #25;
    DacLoadStart = 1'b0;
    
  end

  localparam Low = 13;
  localparam High = 12;
  always begin
    #Low Clk = ~Clk;
    #High Clk = ~Clk;
  end
endmodule
