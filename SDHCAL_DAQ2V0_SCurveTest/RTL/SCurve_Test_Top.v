`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/03/02 14:26:06
// Design Name: 
// Module Name: SCurve_Top
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


module SCurve_Test_Top(
    input Clk,
    input reset_n,
    /*--- Test parameters and control interface--from upper level ---*/
    input Test_Start,
    input [5:0] SingleTest_Chn,
    input Single_or_64Chn,
    input Ctest_or_Input, //Add by wyu 20170307. When single channel test, this parameter can choose the charge inject from Ctest pin or the input pin
    input [15:0] CPT_MAX,
    /*--- USB Data FIFO Interface ---*/
    //input usb_data_fifo_full,
    output usb_data_fifo_wr_en,
    output [15:0] usb_data_fifo_wr_din,
    input usb_data_fifo_full,
    /*---Microroc Config Interface ---*/
    input Microroc_Config_Done,
    output [63:0] Microroc_CTest_Chn_Out,
    output [9:0] Microroc_10bit_DAC_Out,
    output [191:0] Microroc_Discriminator_Mask,
    output SC_Param_Load,
    /*--- Pin ---*/
    input CLK_EXT,
    input out_trigger0b,
    input out_trigger1b,
    input out_trigger2b,
    /*--- Done Indicator ---*/
    output SCurve_Test_Done,
    input Data_Transmit_Done
    //input Data_Transmit_Done
    );
    /*--- SCurve_Test_Control ---*/
    // Generate a start pulse 
    reg Test_Start_reg1;
    reg Test_Start_reg2;
    always @(posedge Clk or negedge reset_n) begin
      if(!reset_n) begin
        Test_Start_reg1 <= 1'b0;
        Test_Start_reg2 <= 1'b0;
      end
      else begin
        Test_Start_reg1 <= Test_Start;
        Test_Start_reg2 <= Test_Start_reg1;
      end
    end
    wire Test_Start_Pulse = Test_Start_reg1 & (~Test_Start_reg2);
    wire Single_Test_Start;
    wire Single_Test_Done;
    wire SCurve_Data_fifo_empty;
    wire [15:0] SCurve_Data_fifo_din;
    wire SCurve_Data_fifo_rd_en;
    SCurve_Test_Control SC_test_control(
      .Clk(Clk),
      .reset_n(reset_n),
      .Test_Start(Test_Start_Pulse),
      /*--- Lower-Level module:SCurve Single Test Interface ---*/
      .Single_Test_Start(Single_Test_Start),
      .Single_Test_Done(Single_Test_Done),
      .SCurve_Data_fifo_empty(SCurve_Data_fifo_empty),
      .SCurve_Data_fifo_din(SCurve_Data_fifo_din),
      .SCurve_Data_fifo_rd_en(SCurve_Data_fifo_rd_en),
      /*--- Test Parameter Interface ---*/
      .Single_or_64Chn(Single_or_64Chn),
      .SingleTest_Chn(SingleTest_Chn),
      .Ctest_or_Input(Ctest_or_Input),//Add by wyu 20170307. When single channel test, this parameter can choose the charge inject from Ctest pin or the input pin
      /*--- Microroc SC Parameter Interface ---*/
      .Microroc_CTest_Chn_Out(Microroc_CTest_Chn_Out),
      .Microroc_10bit_DAC_Out(Microroc_10bit_DAC_Out),
      .Microroc_Discriminator_Mask(Microroc_Discriminator_Mask),
      .SC_Param_Load(SC_Param_Load),
      .Microroc_Config_Done(Microroc_Config_Done),
      /*--- USB Data FIFO Interface ---*/
      .usb_data_fifo_wr_din(usb_data_fifo_wr_din),
      .usb_data_fifo_wr_en(usb_data_fifo_wr_en),
      .usb_data_fifo_full(usb_data_fifo_full),
      /*--- Done Indicator ---*/
      .SCurve_Test_Done(SCurve_Test_Done),
      .Data_Transmit_Done(Data_Transmit_Done)
    );
    /*--- SCurve_Single_Channel ---*/
    wire [15:0] SCurve_Data;
    wire SCurve_Data_wr_en;
    SCurve_Single_Test SC_test_single(
      .Clk(Clk),
      .reset_n(reset_n),
      .CLK_EXT(CLK_EXT),
      .out_trigger0b(out_trigger0b),
      .out_trigger1b(out_trigger1b),
      .out_trigger2b(out_trigger2b),
      .SCurve_Test_Start(Single_Test_Start),
      .CPT_MAX(CPT_MAX),
      .SCurve_Data(SCurve_Data),
      .SCurve_Data_wr_en(SCurve_Data_wr_en),
      .One_Channel_Done(Single_Test_Done)
    );
    /*--- SCurve Data FIFO instantiation ---*/
    wire fifo_full;
    SCurve_Data_FIFO scurve_data_fifo_16x16(
      .clk(~Clk),
      .rst(!reset_n || SCurve_Test_Done),
      .din(SCurve_Data),
      .wr_en(SCurve_Data_wr_en),

      .rd_en(SCurve_Data_fifo_rd_en),
      .dout(SCurve_Data_fifo_din),
      .full(fifo_full),
      .empty(SCurve_Data_fifo_empty)
    );
    (*mark_debug = "true"*)wire[15:0] SCurve_Data_debug;
    (*mark_debug = "true"*)wire SCurve_Data_wr_en_debug;
    (*mark_debug = "true"*)wire SCurve_Data_fifo_rd_en_debug;
    (*mark_debug = "true"*)wire[15:0] SCurve_Data_fifo_din_debug;
    assign SCurve_Data_debug = SCurve_Data;
    assign SCurve_Data_wr_en_debug = SCurve_Data_wr_en;
    assign SCurve_Data_fifo_rd_en_debug = SCurve_Data_fifo_rd_en;
    assign SCurve_Data_fifo_din_debug = SCurve_Data_fifo_din;
endmodule
