`timescale 1ns / 1ns
module RazGen_tb;
  reg Clk;
  reg reset_n;
  reg TrigIn;
  reg ExternalRaz_en;
  reg [3:0] ExternalRazDelayTime;
  wire SingleRaz_en;
  RazGen uut(
    .Clk(Clk),
    .reset_n(reset_n),
    .TrigIn(TrigIn),
    .ExternalRaz_en(ExternalRaz_en),
    .ExternalRazDelayTime(ExternalRazDelayTime),
    .SingleRaz_en(SingleRaz_en)
  );
  // initial
  initial begin
    Clk = 1'b0;
    reset_n = 1'b0;
    TrigIn = 1'b0;
    ExternalRaz_en = 1'b0;
    ExternalRazDelayTime = 4'd10;
    #100;
    reset_n = 1'b1;
    #100;
    TrigIn = 1'b1;
    #100;
    TrigIn = 1'b0;
    #100;
    ExternalRaz_en = 1'b1;
    #50;
    TrigIn = 1'b1;
    #100;
    TrigIn = 1'b0;
  end
  parameter PERIOD = 20;
  always #(PERIOD/2) Clk = ~Clk;
endmodule
