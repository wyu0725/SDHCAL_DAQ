`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/07/15 09:23:59
// Design Name:
// Module Name: ClockManagement_tb
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


module ClockManagement_tb();
  reg Clk40M;
  reg UsbClockout;
  reg rst_n;
  wire Clk;
  wire Clk5M;
  wire SyncClk;
  wire IFCLK;
  wire UsbIfclk;
  wire reset_n;
  wire ClockGood;

  //instance: ../../../src/ClockManagement.v
  ClockManagement uut(
    .Clk40M(Clk40M),
    .UsbClockout(UsbClockout),
    .rst_n(rst_n),
    .Clk(Clk),
    .Clk5M(Clk5M),
    .SyncClk(SyncClk),
    .IFCLK(IFCLK),
    .UsbIfclk(UsbIfclk),
    .reset_n(reset_n),
    .ClockGood(ClockGood)
    );

  initial begin
    Clk40M = 1'b0;
    UsbClockout = 1'b0;
    rst_n = 1'b0;
    #1000_000
    rst_n = 1'b1;
    #10_000_000;
    rst_n = 1'b0;
    #100_000;
    rst_n = 1'b1;
  end
  
  localparam CLOCK_PEROID = 25000;
  localparam USB_CLOCK_PEROID = 20833;
  always #(CLOCK_PEROID/2) Clk40M = ~Clk40M;
  always #(USB_CLOCK_PEROID/2) UsbClockout = ~UsbClockout;

endmodule
