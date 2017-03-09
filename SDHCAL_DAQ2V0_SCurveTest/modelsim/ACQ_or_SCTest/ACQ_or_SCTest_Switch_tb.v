`timescale 1ns/1ns
module ACQ_or_SCTest_Switch_tb;
reg ACQ_or_SCTest;
reg [15:0] Microroc_usb_data_fifo_wr_din;
reg Microroc_usb_data_fifo_wr_en;
reg [15:0] SCTest_usb_data_fifo_wr_din;
reg SCTest_usb_data_fifo_wr_en;
wire [15:0] out_to_usb_data_fifo_wr_din;
wire out_to_usb_data_fifo_wr_en;
reg [63:0] USB_Microroc_CTest_Chn_Out;
reg [63:0] SCTest_Microroc_CTest_Chn_Out;
wire [63:0] out_to_Microroc_CTest_Chn_Out;
reg [9:0] USB_Microroc_10bit_DAC_Out;
reg [9:0] SCTest_Microroc_10bit_DAC_Out;
wire [9:0] out_to_Microroc_10bit_DAC_Out;
reg USB_SC_Param_Load;
reg SCTest_SC_Param_Load;
wire out_to_Microroc_SC_Param_Load;
reg PIN_out_trigger0b;
reg PIN_out_trigger1b;
reg PIN_out_trigger2b;
wire SCTest_out_trigger0b;
wire SCTest_out_trigger1b;
wire SCTest_out_trigger2b;
wire HoldGen_out_trigger0b;
wire HoldGen_out_trigger1b;
wire HoldGen_out_trigger2b;
//instantiation the module
ACQ_or_SCTest_Switch uut (
  .ACQ_or_SCTest(ACQ_or_SCTest),
  /*--- USB Data FIFO write ---*/
  .Microroc_usb_data_fifo_wr_din(Microroc_usb_data_fifo_wr_din),
  .Microroc_usb_data_fifo_wr_en(Microroc_usb_data_fifo_wr_en),
  .SCTest_usb_data_fifo_wr_din(SCTest_usb_data_fifo_wr_din),
  .SCTest_usb_data_fifo_wr_en(SCTest_usb_data_fifo_wr_en),
  .out_to_usb_data_fifo_wr_din(out_to_usb_data_fifo_wr_din),
  .out_to_usb_data_fifo_wr_en(out_to_usb_data_fifo_wr_en),
  /*--- SC param ---*/
  // CTest Channel select
  .USB_Microroc_CTest_Chn_Out(USB_Microroc_CTest_Chn_Out),
  .SCTest_Microroc_CTest_Chn_Out(SCTest_Microroc_CTest_Chn_Out),
  .out_to_Microroc_CTest_Chn_Out(out_to_Microroc_CTest_Chn_Out),
  // 10bit DAC code out
  .USB_Microroc_10bit_DAC_Out(USB_Microroc_10bit_DAC_Out),
  .SCTest_Microroc_10bit_DAC_Out(SCTest_Microroc_10bit_DAC_Out),
  .out_to_Microroc_10bit_DAC_Out(out_to_Microroc_10bit_DAC_Out),
  // SC param load
  .USB_SC_Param_Load(USB_SC_Param_Load),
  .SCTest_SC_Param_Load(SCTest_SC_Param_Load),
  .out_to_Microroc_SC_Param_Load(out_to_Microroc_SC_Param_Load),
  /*--- 3 triggers ---*/
  .Pin_out_trigger0b(PIN_out_trigger0b),
  .Pin_out_trigger1b(PIN_out_trigger1b),
  .Pin_out_trigger2b(PIN_out_trigger2b),
  .SCTest_out_trigger0b(SCTest_out_trigger0b),
  .SCTest_out_trigger1b(SCTest_out_trigger1b),
  .SCTest_out_trigger2b(SCTest_out_trigger2b),
  .HoldGen_out_trigger0b(HoldGen_out_trigger0b),
  .HoldGen_out_trigger1b(HoldGen_out_trigger1b),
  .HoldGen_out_trigger2b(HoldGen_out_trigger2b)
);
initial begin
  ACQ_or_SCTest = 1'b1;
  Microroc_usb_data_fifo_wr_din = 16'hA;
  Microroc_usb_data_fifo_wr_en = 1'b1;
  SCTest_usb_data_fifo_wr_din = 16'h2;
  SCTest_usb_data_fifo_wr_en = 1'b0;
  USB_Microroc_CTest_Chn_Out = 64'h8000_0000_0000_0000;
  SCTest_Microroc_CTest_Chn_Out = 64'h0000_0000_0000_8000;
  USB_Microroc_10bit_DAC_Out = 10'hA;
  SCTest_Microroc_10bit_DAC_Out = 10'h2;
  USB_SC_Param_Load = 1'b1;
  SCTest_SC_Param_Load = 1'b0;
  PIN_out_trigger0b = 1'b0;
  PIN_out_trigger1b = 1'b0;
  PIN_out_trigger2b = 1'b0;
  #100;
  ACQ_or_SCTest = 1'b0;
  #100;
  ACQ_or_SCTest = 1'b1;
end
endmodule
