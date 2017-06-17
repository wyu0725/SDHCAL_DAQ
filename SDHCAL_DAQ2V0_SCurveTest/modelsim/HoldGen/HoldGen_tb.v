`timescale 1ns / 1ns
module HoldGen_tb;
  reg Clk;
  reg Clk_320M;
  reg reset_n;
  reg TrigIn;
  reg Hold_en;
  reg [7:0] HoldDelay;
  reg [15:0] HoldTime;
  wire HoldOut;
  HoldGen uut(
    .Clk(Clk),
    .Clk_320M(Clk_320M),
    .reset_n(reset_n),
    .TrigIn(TrigIn),
    .Hold_en(Hold_en),
    .HoldDelay(HoldDelay),
    .HoldTime(HoldTime),
    .HoldOut(HoldOut)
  );
  //Initial
  initial begin
    Clk = 1'b0;
    Clk_320M = 1'b0;
    reset_n = 1'b0;
    TrigIn = 1'b0;
    Hold_en = 1'b0;
    HoldDelay = 8'b0;
    HoldTime = 16'b0;
    #100;
    reset_n = 1'b1;
    HoldDelay = 8'd30;
    HoldTime = 16'd40;
    #100;
    TrigIn = 1'b1;
    #10;
    TrigIn = 1'b0;
    #100;
    Hold_en = 1'b1;
    #20;
    TrigIn = 1'b1;
    #200;
    TrigIn = 1'b0;
  end
  // Generate the clock
  parameter PERIOD1 = 2;
  parameter PERIOD2 = 16;
  always #(PERIOD1/2) Clk_320M = ~Clk_320M;
  always #(PERIOD2/2) Clk = ~Clk;
endmodule
