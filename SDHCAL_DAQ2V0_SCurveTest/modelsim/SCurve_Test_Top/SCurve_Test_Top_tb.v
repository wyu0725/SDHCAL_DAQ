`timescale 1ns/1ns
module SCurve_Test_Top_tb;
reg clk;
reg reset_n;
/*--- Test parameters and control interface--from upper level ---*/
reg Test_Start;
reg [5:0] SingleTest_Chn;
reg Single_or_64Chn;
reg [15:0] CPT_MAX;
/*--- USB Data FIFO Interface ---*/
wire usb_data_fifo_wr_en;
wire [15:0] usb_data_fifo_wr_din;
/*---Microroc Config Interface ---*/
reg Microroc_Config_Done;
wire [63:0] Microroc_CTest_Chn_Out;
wire [9:0] Microroc_10bit_DAC_Out;
wire SC_Param_Load;
/*--- Pin ---*/
reg CLK_EXT;
reg out_trigger0b;
reg out_trigger1b;
reg out_trigger2b;
/*--- Done Indicator ---*/
wire SCurve_Test_Done;
//instantiation TOP
SCurve_Test_Top uut(
  .Clk(clk),
  .reset_n(reset_n),
  .Test_Start(Test_Start),
  .SingleTest_Chn(SingleTest_Chn),
  .Single_or_64Chn(Single_or_64Chn),
  .CPT_MAX(CPT_MAX),
  .usb_data_fifo_wr_en(usb_data_fifo_wr_en),
  .usb_data_fifo_wr_din(usb_data_fifo_wr_din),
  .Microroc_Config_Done(Microroc_Config_Done),
  .Microroc_CTest_Chn_Out(Microroc_CTest_Chn_Out),
  .Microroc_10bit_DAC_Out(Microroc_10bit_DAC_Out),
  .SC_Param_Load(SC_Param_Load),
  .CLK_EXT(CLK_EXT),
  .out_trigger0b(out_trigger0b),
  .out_trigger1b(out_trigger1b),
  .out_trigger2b(out_trigger2b),
  .SCurve_Test_Done(SCurve_Test_Done)
);
//initial the register
initial begin
  clk = 1'b0;
  reset_n = 1'b0;
  Test_Start = 1'b0;
  SingleTest_Chn = 6'b0;
  Single_or_64Chn = 1'b0;
  CPT_MAX = 16'd100;
  Microroc_Config_Done = 1'b0;
  CLK_EXT = 1'b0;
  out_trigger0b = 1'b1;
  out_trigger1b = 1'b1;
  out_trigger2b = 1'b1;
  #100;
  reset_n = 1'b1;
  SingleTest_Chn = 6'd16;
  #25;
  Test_Start = 1'b1;
  #25;
  Test_Start = 1'b0;

end
//Generate 40M 
localparam High = 12;
localparam Low = 13;
always begin
  #(Low) clk = ~clk;
  #(High) clk = ~clk;
end
//Generate SC parameter load done signal
reg [2:0] SC_Load_Cnt;
always @(posedge clk or negedge reset_n)begin
  if(~reset_n)begin
    SC_Load_Cnt <= 3'b0;
    Microroc_Config_Done <= 1'b0;
  end
  else if(SC_Param_Load ||(SC_Load_Cnt != 3'd0 && SC_Load_Cnt <= 3'd7))begin
    SC_Load_Cnt <= SC_Load_Cnt + 1'b1;
    Microroc_Config_Done <= (SC_Load_Cnt == 3'd7);
  end
  else begin
    SC_Load_Cnt <= 3'd0;
    Microroc_Config_Done <= 1'b0;
  end
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
