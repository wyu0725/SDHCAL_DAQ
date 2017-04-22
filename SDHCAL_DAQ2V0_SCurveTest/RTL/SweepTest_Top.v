`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/04/21 16:57:59
// Design Name: 
// Module Name: SweepTest_Top
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


module SweepTest_Top(
    input Clk,
    input reset_n,
    // Mode Select
    input [1:0] ModeSelect,
    // Microroc SC Parameter
    input [9:0] USBMicroroc10bitDAC0,
    input [9:0] USBMicroroc10bitDAC1,
    input [9:0] USBMicroroc10bitDAC2,
    output [9:0] OutMicroroc10bitDAC0,
    output [9:0] OutMicroroc10bitDAC1,
    output [9:0] OutMicroroc10bitDAC2,
    input [6:0] USBMicrorocChannelMask,
    input [1:0] USBMicrorocDiscriMask,
    output [6:0] OutMicrorocChannelMask,
    output [1:0] OutMicrorocDiscriMask,
    input [6:0] USBMicrorocCTestChannel,
    output [6:0] OutMicrorocCTestChannel,
    input USBMicrorocSCParameterLoad,
    output OutMicrorocSCParameterLoad,
    input USB_SC_or_Readreg,
    output Microroc_SC_or_Readreg,
    input MicrorocConfigDone,
    // Microroc ACQ Control and Data
    output MicrorocAcqStartStop,
    input [15:0] MicrorocACQData,
    input MicrorocACQData_en,
    // USB Interface
    input nPKTEND,
    input USBDataFifoFull,
    output [15:0] OutUsbExtFifoData,
    output OutUsbExtFifoData_en,
    output UsbStartStop,
    // The following ports is set for SweepACQ and SCurve Test
    input SweepStart,
    input StartDAC,
    input EndDAC,
    output SweepTestDone,
    input DataTransmitDone,
    // Sweep ACQ
    input [15:0] MaxPakageNumber,
    //SCurve Test
    input TrigEffi_or_CountEffi,
    input [5:0] SingleTestChannel,
    input Single_or_64Chn,
    input CTest_or_Input,
    input [15:0] CPT_MAX,
    input [15:0] CounterMAX,
    output ForceExtRaz,
      // Pin
    input CLK_EXT,
    input out_trigger0b,
    input out_trigger1b,
    input out_trigger2b
    );
    // Switcher for ACQ, SweepACQ or SCurve Test
    TestSwitcher Switcher();
    SweepACQ_Top SweepACQ(
      .Clk(),
      .reset_n(),
      // ACQ Control
      .SweepStart(),
      .SingleACQStart(),
      .ACQDone(),
      // Sweep ACQ Parameters
      .StartDAC0(),
      .EndDAC0(),
      .MaxPackageNumber(),
      // ACQ Data
      .ParallelData(),
      .ParallelData_en(),
      // SC Parameters
      .OutDAC0(),
      .LoadSCParameters(),
      .MicrorocConfigDone(),
      // Data Out
      .SweepACQData(),
      .SweepACQData_en()
    );
    SCurve_Test_Top Microroc_SCurveTest(
      .Clk(Clk),
      .Clk_5M(Clk_5M),
      .reset_n(reset_n),
      // Select Trig Efficiency or Counter Efficiency test
      .TrigEffi_or_CountEffi(TrigEffi_or_CountEffi),
      //--- Test parameters and control interface--from upper level ---
      .Test_Start(SCTest_Start_Stop),
      .SingleTest_Chn(SingleTest_Chn),
      .Single_or_64Chn(Single_or_64Chn),
      .Ctest_or_Input(CTest_or_Input),
      .CPT_MAX(CPT_MAX),
      .Counter_MAX(Counter_MAX),
      //--- USB Data FIFO Interface ---
      //.usb_data_fifo_full(),
      .usb_data_fifo_wr_en(SCTest_usb_data_fifo_wr_en),
      .usb_data_fifo_wr_din(SCTest_usb_data_fifo_wr_din),
      .usb_data_fifo_full(usb_data_fifo_wr_full),
      //--- Microroc Config Interface ---
      .Microroc_Config_Done(Config_Done),
      .Microroc_CTest_Chn_Out(SCTest_Microroc_CTest_Chn_Out),
      .Microroc_10bit_DAC_Out(SCTest_Microroc_10bit_DAC_Out),
      .Microroc_Discriminator_Mask(SCTest_Channel_Discri_Mask),
      .SC_Param_Load(SCTest_SC_Param_Load),
      .Force_Ext_RAZ(Force_Ext_RAZ),
      //--- PIN ---
      .CLK_EXT(CLK_EXT),
      .out_trigger0b(OUT_TRIG0B),
      .out_trigger1b(OUT_TRIG1B),
      .out_trigger2b(OUT_TRIG2B),
      //--- Done Indicator ---
      .SCurve_Test_Done(SCurve_Test_Done),
      .Data_Transmit_Done(USB_Data_Transmit_Done)
    );
endmodule
