`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/03/06 21:09:09
// Design Name: 
// Module Name: ACQ_or_SCTest_Switch
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


module ACQ_or_SCTest_Switch(
    input ACQ_or_SCTest,
    /*--- Start signal ---*/
    input USB_Acq_Start_Stop,
    output Microroc_Acq_Start_Stop,
    output SCTest_Start_Stop,
    /*--- USB Data FIFO Write Interface ---*/
    input [15:0] Microroc_usb_data_fifo_wr_din,
    input Microroc_usb_data_fifo_wr_en,
    input [15:0] SCTest_usb_data_fifo_wr_din,
    input SCTest_usb_data_fifo_wr_en,
    output [15:0] out_to_usb_data_fifo_wr_din,
    output out_to_usb_data_fifo_wr_en,
    /*--- SC Test Param ---*/
    // Ctest channel select
    input [63:0] USB_Microroc_CTest_Chn_Out,
    input [63:0] SCTest_Microroc_CTest_Chn_Out,
    output [63:0] out_to_Microroc_CTest_Chn_Out,
    // 10bit DAC Code
    input [9:0] USB_Microroc_10bit_DAC0_Out,
    input [9:0] USB_Microroc_10bit_DAC1_Out,
    input [9:0] USB_Microroc_10bit_DAC2_Out,
    input [9:0] SCTest_Microroc_10bit_DAC_Out,
    output [9:0] out_to_Microroc_10bit_DAC0_Out,
    output [9:0] out_to_Microroc_10bit_DAC1_Out,
    output [9:0] out_to_Microroc_10bit_DAC2_Out,
    // SC parameter load
    input USB_SC_Param_Load,
    input SCTest_SC_Param_Load,
    output out_to_Microroc_SC_Param_Load,
    //Config Done signal
    //input in_Microroc_Config_Done,
    //output SCTest_Microroc_Config_Done,
    /*--- 3 triggers ---*/
    input Pin_out_trigger0b,
    input Pin_out_trigger1b,
    input Pin_out_trigger2b,
    output SCTest_out_trigger0b,
    output SCTest_out_trigger1b,
    output SCTest_out_trigger2b,
    output HoldGen_out_trigger0b,
    output HoldGen_out_trigger1b,
    output HoldGen_out_trigger2b
    );
    /*--- Start Stop Signal ---*/
    assign Microroc_Acq_Start_Stop = ACQ_or_SCTest ? USB_Acq_Start_Stop : 1'b0;
    assign SCTest_Acq_Start_Stop = ACQ_or_SCTest ? 1'b0 : USB_Acq_Start_Stop;
    /*--- USB FIFO write ---*/
    assign out_to_usb_data_fifo_wr_din = ACQ_or_SCTest ? Microroc_usb_data_fifo_wr_din : SCTest_usb_data_fifo_wr_din;
    assign out_to_usb_data_fifo_wr_en = ACQ_or_SCTest ? Microroc_usb_data_fifo_wr_en : SCTest_usb_data_fifo_wr_en;
    /*--- SC parameter ------*/
    // Ctest channel select
    assign out_to_Microroc_CTest_Chn_Out = ACQ_or_SCTest ? USB_Microroc_CTest_Chn_Out : SCTest_Microroc_CTest_Chn_Out;
    // 10 bit DAC out
    assign out_to_Microroc_10bit_DAC0_Out = ACQ_or_SCTest ? USB_Microroc_10bit_DAC0_Out : SCTest_Microroc_10bit_DAC_Out;
    assign out_to_Microroc_10bit_DAC1_Out = ACQ_or_SCTest ? USB_Microroc_10bit_DAC1_Out : SCTest_Microroc_10bit_DAC_Out;
    assign out_to_Microroc_10bit_DAC2_Out = ACQ_or_SCTest ? USB_Microroc_10bit_DAC2_Out : SCTest_Microroc_10bit_DAC_Out;
    // SC Param load
    assign out_to_Microroc_SC_Param_Load = ACQ_or_SCTest ? USB_SC_Param_Load : SCTest_SC_Param_Load;
    /*--- 3 triggers ---*/
    // out_trigger0b
    assign SCTest_out_trigger0b = ACQ_or_SCTest ? 1'b1 : Pin_out_trigger0b;
    assign HoldGen_out_trigger0b = ACQ_or_SCTest ? Pin_out_trigger0b : 1'b1;
    // out_trigger1b
    assign SCTest_out_trigger1b = ACQ_or_SCTest ? 1'b1 : Pin_out_trigger1b;
    assign HoldGen_out_trigger1b = ACQ_or_SCTest ? Pin_out_trigger1b : 1'b1;
    // out_trigger2b
    assign SCTest_out_trigger2b = ACQ_or_SCTest ? 1'b1 : Pin_out_trigger2b;
    assign HoldGen_out_trigger2b = ACQ_or_SCTest ? Pin_out_trigger2b : 1'b1;
endmodule
