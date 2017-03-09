`timescale 1ns/1ns
module SCurve_Single_Input_tb;
reg clk;
reg reset_n;
reg Trigger;
reg CLK_EXT;
reg Test_Start;
reg [15:0] CPT_MAX;
wire [15:0] CPT_PULSE;
wire [15:0] CPT_TRIGGER;
wire CPT_DONE;
//instantiation uut
SCurve_Single_Input uut(
  .Clk(clk),
  .reset_n(reset_n),
  .Trigger(Trigger),
  .CLK_EXT(CLK_EXT),
  .Test_Start(Test_Start),
  .CPT_MAX(CPT_MAX),
  .CPT_PULSE(CPT_PULSE),
  .CPT_TRIGGER(TRIGGER),
  .CPT_DONE(CPT_DONE)
);
//initial the tb
initial begin
  clk = 1'b0;
  reset_n = 1'b0;
  Trigger = 1'b1;
  Test_Start = 1'b0;
  CPT_MAX = 16'd1000;
  #100;
  reset_n = 1'b1;
  #100;
  reset_n = 1'b0;
  #25;
  reset_n = 1'b1;
  #25;
  Test_Start = 1'b1;
end
//Generate the 40M clk
parameter High_T = 12;
parameter Low_T = 13;
always begin
  #(High_T) clk = ~clk;
  # (Low_T) clk = ~clk;
end

//Generate the end signal
reg [15:0] CPT_PULSE_temp;
reg [15:0] CPT_TRIGGER_temp;
always @(posedge clk or negedge reset_n)begin
  if(~reset_n)begin
    CPT_PULSE_temp <= 1'b0;
    CPT_TRIGGER_temp <= 1'b0;
    Test_Start <= 1'b0;
  end
  else if(CPT_DONE)begin
    Test_Start <= 1'b0;
    reset_n <= 1'b0; 
  end
  else begin
    Test_Start <= Test_Start;
    reset_n <= 1'b1;
  end
end
//Generate CLK_EXT, assume it's 1M.In fact this clock is 100k
reg [4:0] Clk_Cnt;
wire clk_n = ~clk;
always @(posedge clk_n or negedge reset_n)begin
  if(~reset_n)begin
    Clk_Cnt <= 5'b0;
    CLK_EXT <= 1'b0;
  end
  else if(Clk_Cnt == 5'd20)begin
    Clk_Cnt <= 5'd0;
    CLK_EXT <= ~CLK_EXT;
  end
  else begin
    Clk_Cnt <= Clk_Cnt + 1'b1;
    CLK_EXT <= CLK_EXT;
  end
end
//Generate Trigger, assume it's 500kHz,just a half of CLK_EXT
reg [6:0] Trigger_Cnt;
always @(posedge clk_n or negedge reset_n)begin
  if(~reset_n)begin
    Trigger_Cnt <= 7'b0;
    Trigger <= 1'b1;
  end
  else if(Trigger_Cnt == 7'd80)begin
    Trigger <= 1'b0;
    Trigger_Cnt <= 7'd0;
  end
  else begin
    Trigger_Cnt <= Trigger_Cnt +1'b1;
    Trigger <= 1'b1;
  end
end

endmodule
