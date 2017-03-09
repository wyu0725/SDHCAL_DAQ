`timescale 1ns/1ns
module SCurve_Single_Channel_tb;
reg clk;
reg reset_n;
reg CLK_EXT;
reg out_trigger0b;
reg out_trigger1b;
reg out_trigger2b;
reg SCurve_Test_Start;
reg [15:0] CPT_MAX;

wire [15:0] SCurve_Data;
wire SCurve_Data_wr_en;
wire One_Channel_Done;

//------//
SCurve_Single_Channel uut(
  .Clk(clk),
  .reset_n(reset_n),
  .CLK_EXT(CLK_EXT),
  .out_trigger0b(out_trigger0b),
  .out_trigger1b(out_trigger1b),
  .out_trigger2b(out_trigger2b),
  .SCurve_Test_Start(SCurve_Test_Start),
  .CPT_MAX(CPT_MAX),
  .SCurve_Data(SCurve_Data),
  .SCurve_Data_wr_en(SCurve_Data_wr_en),
  .One_Channel_Done(One_Channel_Done)
);
//------//
initial begin
  clk = 1'b0;
  reset_n <= 1'b0;
  out_trigger0b <= 1'b1;
  out_trigger1b <= 1'b1;
  out_trigger2b <= 1'b1;
  SCurve_Test_Start <= 1'b0;
  CPT_MAX <= 100;
  #100;
  reset_n <= 1'b1;
  #100;
  SCurve_Test_Start <= 1'b1;
  #25;
  SCurve_Test_Start <= 1'b0;
end
//Generate the 40M clk
parameter High_T = 12;
parameter Low_T = 13;
always begin
  #(High_T) clk = ~clk;
  # (Low_T) clk = ~clk;
end
//Generate CLK_EXT, assume it's 1M.
//In fact this clock is 100k
reg [4:0] Clk_Cnt;
wire clk_n = ~clk;
always @(posedge clk_n or negedge reset_n)begin
  if(~reset_n)begin
    Clk_Cnt <= 5'b0;
    CLK_EXT <= 1'b0;
  end
  else if(Clk_Cnt == 5'd19)begin
    Clk_Cnt <= 5'd0;
    CLK_EXT <= ~CLK_EXT;
  end
  else begin
    Clk_Cnt <= Clk_Cnt + 1'b1;
    CLK_EXT <= CLK_EXT;
  end
end
//Generate out_trigger0b, assume it's 500k, 
//just a half of CLK_EXT
reg [6:0]Trigger0_Cnt;
always @(posedge clk_n or negedge reset_n)begin
  if(~reset_n)begin
    Trigger0_Cnt <= 7'b0;
    out_trigger0b <= 1'b1;
  end
  else if(Trigger0_Cnt == 7'd79)begin
    out_trigger0b <= 1'b0;
    Trigger0_Cnt <= 7'd0;
  end
  else begin
    out_trigger0b <= 1'b1;
    Trigger0_Cnt <= Trigger0_Cnt + 1'b1;
  end
end
//Generate out_trigger1b, assume it's 250k,
//just a quarter of CLK_EXT
reg [7:0]Trigger1_Cnt;
always @(posedge clk_n or negedge reset_n)begin
  if(~reset_n)begin
    Trigger1_Cnt <= 8'b0;
    out_trigger1b <= 1'b1;
  end
  else if(Trigger1_Cnt == 8'd159)begin
    out_trigger1b <= 1'b0;
    Trigger1_Cnt <= 8'd0;
  end
  else begin
    out_trigger1b <= 1'b1;
    Trigger1_Cnt <= Trigger1_Cnt + 1'b1;
  end
end
//Generate out_trigger2b, assume it's 125k,
//just one eighth of CLK_EXT
reg [8:0]Trigger2_Cnt;
always @(posedge clk_n or negedge reset_n)begin
  if(~reset_n)begin
    Trigger2_Cnt <= 9'b0;
    out_trigger2b <= 1'b1;
  end
  else if(Trigger2_Cnt == 9'd319)begin
    out_trigger2b <= 1'b0;
    Trigger2_Cnt <= 9'd0;
  end
  else begin
    out_trigger2b <= 1'b1;
    Trigger2_Cnt <= Trigger2_Cnt + 1'b1;
  end
end
endmodule
