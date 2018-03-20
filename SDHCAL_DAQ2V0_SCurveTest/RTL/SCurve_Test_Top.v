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
    input Clk_5M,// Use 5M clock to generate 1k clock
    input reset_n,
    /*--- Select Trigger-efficiency test or Count-efficiency test ---*/
    input TrigEffi_or_CountEffi,
    /*--- Test parameters and control interface--from upper level ---*/
    input Test_Start,
    input [5:0] SingleTest_Chn,
    input Single_or_64Chn,
    input Ctest_or_Input, //Add by wyu 20170307. When single channel test, this parameter can choose the charge inject from Ctest pin or the input pin
    input [15:0] CPT_MAX,
    input [15:0] Counter_MAX,
    input [9:0] StartDac,
    input [9:0] EndDac,
    input [9:0] AdcInterval,
    input [3:0] TriggerDelay,
    input [2:0] AsicNumber,
    input UnmaskAllChannel,
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
    output Force_Ext_RAZ,
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
    /*--- Generate 1k Clock ---*/
    reg [11:0] Clock1K_Cnt; 
    localparam [11:0] Clock1K_Max = 12'd1250;
    reg Clk_1K;
    always @(posedge Clk_5M or negedge reset_n) begin
      if(~reset_n) begin
        Clk_1K <= 1'b0;
        Clock1K_Cnt <= 12'd0;
      end
      else if(TrigEffi_or_CountEffi) begin
        Clk_1K <= 1'b0;
        Clock1K_Cnt = 12'd0;
      end
      else if(Clock1K_Cnt == Clock1K_Max) begin
        Clk_1K <= ~Clk_1K;
        Clock1K_Cnt <= 12'b0;
      end
      else begin
        Clock1K_Cnt <= Clock1K_Cnt + 1'b1;
        Clk_1K <= Clk_1K;
      end
    end
    /*--- Switcher for Trigger-efficiency and Count-efficiency ---*/
    wire CLK_EXT_Gen;
    wire [15:0] CPT_MAX_Gen;
    assign CLK_EXT_Gen = TrigEffi_or_CountEffi ? CLK_EXT : Clk_1K;
    assign CPT_MAX_Gen = TrigEffi_or_CountEffi ? CPT_MAX : Counter_MAX;
    //
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
      .StartDac(StartDac),
      .EndDac(EndDac),
      .AdcInterval(AdcInterval),
      .AsicNumber(AsicNumber),
      .UnmaskAllChannel(UnmaskAllChannel),
      /*--- Microroc SC Parameter Interface ---*/
      .Microroc_CTest_Chn_Out(Microroc_CTest_Chn_Out),
      .Microroc_10bit_DAC_Out(Microroc_10bit_DAC_Out),
      .Microroc_Discriminator_Mask(Microroc_Discriminator_Mask),
      .Force_Ext_RAZ(Force_Ext_RAZ),
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
      .TrigEffi_or_CountEffi(TrigEffi_or_CountEffi),
      .CLK_EXT(CLK_EXT_Gen),
      .out_trigger0b(out_trigger0b),
      .out_trigger1b(out_trigger1b),
      .out_trigger2b(out_trigger2b),
      .SCurve_Test_Start(Single_Test_Start),
      .CPT_MAX(CPT_MAX_Gen),
      .TriggerDelay(TriggerDelay),
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
endmodule
