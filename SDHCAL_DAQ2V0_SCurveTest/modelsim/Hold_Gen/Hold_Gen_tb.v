`timescale 1ns / 1ns
module Hold_Gen_tb;
  reg Clk;
  reg reset_n;
  reg Hold_en;
  reg [1:0] TrigCoincid;
  reg [8:0] HoldDelay;
  reg OUT_TRIG0B;
  reg OUT_TRIG1B;
  reg OUT_TRIG2B;
  reg Ext_TRIGB;
  wire HOLD;
  reg ExternalRaz_en;
  reg [9:0] ExternalRazDelayTime;
  wire SingleRaz_en;
  Hold_Gen uut(
    .Clk(Clk),
    .reset_n(reset_n),
    .Hold_en(Hold_en),
    .TrigCoincid(TrigCoincid),
    .HoldDelay(HoldDelay),
    .OUT_TRIG0B(OUT_TRIG0B),
    .OUT_TRIG1B(OUT_TRIG1B),
    .OUT_TRIG2B(OUT_TRIG2B),
    .Ext_TRIGB(Ext_TRIGB),
    .HOLD(HOLD),
    .ExternalRaz_en(ExternalRaz_en),
    .ExternalRazDelayTime(ExternalRazDelayTime),
    .SingleRaz_en(SingleRaz_en)
  );
  // initial 
  initial begin
    Clk = 1'b0;
    reset_n = 1'b0;
    Hold_en = 1'b0;
    TrigCoincid = 2'b00;
    HoldDelay = 9'd50;
    OUT_TRIG0B = 1'b1;
    OUT_TRIG1B = 1'b1;
    OUT_TRIG2B = 1'b1;
    Ext_TRIGB = 1'b1;
    ExternalRaz_en = 1'b0;
    ExternalRazDelayTime = 10'd60;
    #100;
    reset_n = 1'b1;
    #100;
    Hold_en = 1'b1;
    ExternalRaz_en = 1'b1;
    #50;
    OUT_TRIG0B = 1'b0;
    #100;
    OUT_TRIG0B = 1'b1;
    TrigCoincid = 2'b01;
    #7000;
    OUT_TRIG1B = 1'b0;
    #100;
    OUT_TRIG1B = 1'b1;
    TrigCoincid = 2'b10;
    #7000;
    OUT_TRIG2B = 1'b0;
    #20;
    OUT_TRIG0B = 1'b0;
    #100;
    OUT_TRIG2B = 1'b1;
    OUT_TRIG0B = 1'b1;
    TrigCoincid = 2'b11;
    #7000;
    Ext_TRIGB = 1'b0;
    #100;
    Ext_TRIGB = 1'b1;
  end
  // Generate 500M clk
  parameter PERIOD = 2;
  always #(PERIOD/2) Clk = ~Clk;
endmodule
