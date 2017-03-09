`timescale 1ns/1ns
module SCurve_Test_Control_tb;
reg Clk;
reg reset_n;
reg Test_Start;
//
wire Single_Test_Start;
reg Single_Test_Done;
reg SCurve_Data_fifo_empty;
reg [15:0] SCurve_Data_fifo_din;
wire SCurve_Data_fifo_rd_ed;
//
reg Single_or_64Chn;
reg [5:0] SingleTest_Chn;
//
wire [63:0] Microroc_CTest_Chn_Out;
wire [9:0] Microroc_10bit_DAC_Out;
wire SC_Param_Load;
reg Microroc_Config_Done;
//
wire [15:0] usb_data_fifo_wr_din;
wire usb_fifo_wr_en;
//
wire SCurve_Test_Done;
//instantiation uut
SCurve_Test_Control uut(
  .Clk(Clk),
  .reset_n(reset_n),
  .Test_Start(Test_Start),
  .Single_Test_Start(Single_Test_Start),
  .Single_Test_Done(Single_Test_Done),
  .SCurve_Data_fifo_empty(SCurve_Data_fifo_empty),
  .SCurve_Data_fifo_din(SCurve_Data_fifo_din),
  .SCurve_Data_fifo_rd_en(SCurve_Data_fifo_rd_en),
  .Single_or_64Chn(Single_or_64Chn),
  .SingleTest_Chn(SingleTest_Chn),
  .Microroc_CTest_Chn_Out(Microroc_CTest_Chn_Out),
  .Microroc_10bit_DAC_Out(Microroc_10bit_DAC_Out),
  .SC_Param_Load(SC_Param_Load),
  .Microroc_Config_Done(Microroc_Config_Done),
  .usb_data_fifo_wr_din(usb_data_fifo_wr_din),
  .usb_data_fifo_wr_en(usb_data_fifo_wr_en),
  .SCurve_Test_Done(SCurve_Test_Done)
);
//initial
initial begin
  Clk = 1'b0;
  reset_n = 1'b0;
  Test_Start = 1'b0;
  Single_Test_Done = 1'b0;
  SCurve_Data_fifo_empty = 1'b0;
  SCurve_Data_fifo_din = 16'b0;
  Single_or_64Chn = 1'b0;
  SingleTest_Chn = 6'b0;
  Microroc_Config_Done = 1'b0;
  #100;
  reset_n = 1'b1;
  #100;
  Single_or_64Chn = 1'b1;
  SingleTest_Chn = 6'd16;
  Test_Start = 1'b1;
  #25;
  Test_Start = 1'b0;
end
//Generate 40M 
localparam High = 12;
localparam Low = 13;
always begin
  #(Low) Clk = ~Clk;
  #(High) Clk = ~Clk;
end
//Generate SC parameter load done signal
reg [2:0] SC_Load_Cnt;
always @(posedge Clk or negedge reset_n)begin
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
//Generate Single SCurve test done signal
reg [3:0] SCurve_Test_Cnt;
always @(posedge Clk or negedge reset_n)begin
  if(~reset_n)begin
    Single_Test_Done <= 1'b0;
    SCurve_Test_Cnt <= 4'b0;
  end
  else if(Single_Test_Start || (SCurve_Test_Cnt != 4'd0 && SCurve_Test_Cnt <= 4'd15))begin
    SCurve_Test_Cnt <= SCurve_Test_Cnt + 1'b1;
    Single_Test_Done <= (SCurve_Test_Cnt == 4'd15);
  end
  else Single_Test_Done <= 1'b0;
end
//Generate SCurve Data Fifo empty signal
reg [2:0]SCurve_Data_FIFO_Cnt;
wire Clk_n = ~Clk;
always @(posedge Clk_n or negedge reset_n)begin
  if(~reset_n)begin
    SCurve_Data_FIFO_Cnt <= 3'd0;
    SCurve_Data_fifo_empty <= 1'b0;
  end
  else if(SCurve_Data_FIFO_Cnt == 3'd6)begin
    SCurve_Data_fifo_empty <= 1'b1;
    SCurve_Data_FIFO_Cnt <= 3'd0;
  end
  else if(SCurve_Data_fifo_rd_en)begin
    SCurve_Data_fifo_din <= (~SCurve_Data_FIFO_Cnt[0])?{9'h0,4'h1,SCurve_Data_FIFO_Cnt}:{16'h1000};
    SCurve_Data_FIFO_Cnt <= SCurve_Data_FIFO_Cnt + 1'b1;
  end
  else if(Single_Test_Start)
    SCurve_Data_fifo_empty <= 1'b0;
  else
    SCurve_Data_fifo_empty <= SCurve_Data_fifo_empty;
end
endmodule
