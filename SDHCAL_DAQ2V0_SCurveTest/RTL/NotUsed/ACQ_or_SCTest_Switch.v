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
    /*--- USB Sart Stop Signal select ---*/
    input Microroc_Acq_Start_Stop,
    input SCTest_Start_Stop,
    output out_to_usb_Acq_Start_Stop,
    // When  the USB Data FIFO empty and S Curve Test Done,the USB should be
    // Stopped
    //input SCTest_Done,
    //input USB_Data_FIFO_Empty,    
    // When USB synchronous slavefifo module enable the nPKTEND, all the data
    // are transmitted to PC
    input nPKTEND,
    output Data_Transmit_Done,
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
    // Channel Mask
    input [191:0] SCTest_Channel_Discri_Mask,
    output [191:0] out_to_Microroc_Channel_Discri_Mask,
    // SC parameter load
    input USB_SC_Param_Load,
    input SCTest_SC_Param_Load,
    output out_to_Microroc_SC_Param_Load,
    // Select SC param or Read RAM
    input USB_Microroc_SC_or_Read,
    output Microroc_SC_or_Read
    //Config Done signal
    //input in_Microroc_Config_Done,
    //output SCTest_Microroc_Config_Done,
    /*--- 3 triggers ---*/
    // This function does not need. When S Curve Test processing,
    // the Hold_Gen module must work to generate Raz_en signal to reset the
    // trigger.
    /*
    input Pin_out_trigger0b,
    input Pin_out_trigger1b,
    input Pin_out_trigger2b,
    output SCTest_out_trigger0b,
    output SCTest_out_trigger1b,
    output SCTest_out_trigger2b,
    output HoldGen_out_trigger0b,
    output HoldGen_out_trigger1b,
    output HoldGen_out_trigger2b*/
    );
    /*--- USB Start Stop Signal ---*/
    assign out_to_usb_Acq_Start_Stop = ACQ_or_SCTest ? Microroc_Acq_Start_Stop : SCTest_Start_Stop;
    assign Data_Transmit_Done = ~nPKTEND;
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
    // Microroc Channel Discriminator Msak
    assign out_to_Microroc_Channel_Discri_Mask = ACQ_or_SCTest ? {192{1'b1}} : SCTest_Channel_Discri_Mask;
    // SC Param load
    assign out_to_Microroc_SC_Param_Load = ACQ_or_SCTest ? USB_SC_Param_Load : SCTest_SC_Param_Load;
    // Select SC or Read RAM, When SCurve Test, the select must be in read
    // mode
    assign Microroc_SC_or_Read = ACQ_or_SCTest ? USB_Microroc_SC_or_Read : 1'b0;
    /*--- 3 triggers ---*/
    /*
    // out_trigger0b
    assign SCTest_out_trigger0b = ACQ_or_SCTest ? 1'b1 : Pin_out_trigger0b;
    assign HoldGen_out_trigger0b = ACQ_or_SCTest ? Pin_out_trigger0b : 1'b1;
    // out_trigger1b
    assign SCTest_out_trigger1b = ACQ_or_SCTest ? 1'b1 : Pin_out_trigger1b;
    assign HoldGen_out_trigger1b = ACQ_or_SCTest ? Pin_out_trigger1b : 1'b1;
    // out_trigger2b
    assign SCTest_out_trigger2b = ACQ_or_SCTest ? 1'b1 : Pin_out_trigger2b;
    assign HoldGen_out_trigger2b = ACQ_or_SCTest ? Pin_out_trigger2b : 1'b1;
    */
endmodule
