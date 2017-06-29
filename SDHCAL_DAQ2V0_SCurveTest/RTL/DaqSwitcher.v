`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/06/28 22:03:34
// Design Name: 
// Module Name: DaqSwitcher
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


module DaqSwitcher(
    input DaqSelect,
    // Power pulsing control
    input AutoDaq_PWR_ON_A,
    input AutoDaq_PWR_ON_D,
    input AutoDaq_PWR_ON_ADC,
    input AutoDaq_PWR_ON_DAC,
    input SlaveDaq_PWR_ON_A,
    input SlaveDaq_PWR_ON_D,
    input SlaveDaq_PWR_ON_ADC,
    input SlaveDaq_PWR_ON_DAC,
    output PWR_ON_D,
    output PWR_ON_A,
    output PWR_ON_ADC,
    output PWR_ON_DAC,
    // Pin
    input AutoDaq_RESET_B,
    input SlaveDaq_RESET_B,
    output RESET_B,
    input AutoDaq_START_ACQ,
    input SlaveDaq_START_ACQ,
    output START_ACQ,
    // StartAcqSignal
    input UsbAcqStart,
    output AutoDaq_Start,
    output SlaveDaq_Start,
    // Read start and read end
    input AutoDaq_StartReadout,
    input SlaveDaq_StartReadout,
    output StartReadout,
    input EndReadout,
    output AutoDaq_EndReadout,
    output SlaveDaq_EndReadout,
    // Done Signal
    input AutoDaq_OnceEnd,
    input SlaveDaq_OnceEnd,
    output OnceEnd,
    input AutoDaq_AllDone,
    input SlaveDaq_AllDone,
    output AllDone,
    input DataTransmitDone,
    output AutoDaq_DataTransmitDone,
    output SlaveDaq_DataTransmitDone,
    // Start Trigger for SlaveDaq control
    input ExternalTrigger,
    output SingleStart,
    //Usb Start Stop
    input AutoDaq_UsbStartStop,
    input SlaveDaq_UsbStartStop,
    output UsbStartStop
    );
    assign PWR_ON_A = DaqSelect ? AutoDaq_PWR_ON_A : SlaveDaq_PWR_ON_A;
    assign PWR_ON_D = DaqSelect ? AutoDaq_PWR_ON_D : SlaveDaq_PWR_ON_D;
    assign PWR_ON_ADC = DaqSelect ? AutoDaq_PWR_ON_ADC : SlaveDaq_PWR_ON_ADC;
    assign PWR_ON_DAC = DaqSelect ? AutoDaq_PWR_ON_DAC : SlaveDaq_PWR_ON_DAC;
    assign RESET_B = DaqSelect ? AutoDaq_RESET_B : SlaveDaq_RESET_B;
    assign START_ACQ = DaqSelect ? AutoDaq_START_ACQ : SlaveDaq_START_ACQ;
    assign AutoDaq_Start = DaqSelect ? UsbAcqStart : 1'b0;
    assign SlaveDaq_Start = DaqSelect ? 1'b0 : UsbAcqStart;
    assign StartReadout = DaqSelect ? AutoDaq_StartReadout : SlaveDaq_StartReadout;
    assign AutoDaq_EndReadout = DaqSelect ? EndReadout : 1'b0;
    assign SlaveDaq_EndReadout = DaqSelect ? 1'b0 : EndReadout;
    assign OnceEnd = DaqSelect ? AutoDaq_OnceEnd : SlaveDaq_OnceEnd;
    assign AllDone = DaqSelect ? AutoDaq_AllDone : SlaveDaq_AllDone;
    assign AutoDaq_DataTransmitDone = DaqSelect ? DataTransmitDone : 1'b0;
    assign AutoDaq_DataTransmitDone = DaqSelect ? 1'b0 : DataTransmitDone;
    assign SingleStart = DaqSelect ? 1'b0 : ExternalTrigger;
    assign UsbStartStop = DaqSelect ? AutoDaq_UsbStartStop : SlaveDaq_UsbStartStop;
endmodule
