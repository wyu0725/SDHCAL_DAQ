`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/10/22 16:37:20
// Design Name:
// Module Name: CalibrationSwitcherControl_tb
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


module CalibrationSwitcherControl_tb(

  );
  reg Clk;
  reg reset_n;
  reg SyncClock;
  reg [7:0] SwitcherOnTime;
  reg SwitcherEnable;
  wire SwitcherIn;

  //instance:../../../src/CalibrationSwitcherControl.v
  CalibrationSwitcherControl uut(
    .Clk(Clk),
    .reset_n(reset_n),
    .SyncClock(SyncClock),
    .SwitcherOnTime(SwitcherOnTime),
    .SwitcherEnable(SwitcherEnable),
    .SwitcherIn(SwitcherIn)
    );

  initial begin
    Clk = 1'b0;
    reset_n = 1'b0;
    SyncClock = 1'b0;
    SwitcherOnTime = 8'd120;
    SwitcherEnable = 1'b0;
    #100;
    reset_n = 1'b1;
    #1000;
    SwitcherEnable = 1'b1;
    #5_000_000;
    SwitcherEnable = 1'b0;
  end

  localparam Low = 13;
  localparam High = 12;
  localparam SYNC_CLK_PEROID = 10_000;
  always begin
    #(Low) Clk = ~Clk;
    #(High) Clk = ~Clk;
  end
  always #(SYNC_CLK_PEROID/2) SyncClock = ~SyncClock;
endmodule
