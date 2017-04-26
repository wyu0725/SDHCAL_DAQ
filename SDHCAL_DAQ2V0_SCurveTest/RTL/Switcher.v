`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/04/21 19:05:00
// Design Name: 
// Module Name: TestSwitcher
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


module Switcher(
    // ModeSelect
    input [1:0] ModeSelect,
    // --- SC Parameters--- //
    // 10-bits DAC
    input [9:0] USBMicroroc10bitDAC0,
    input [9:0] USBMicroroc10bitDAC1,
    input [9:0] USBMicroroc10bitDAC2,
    input [9:0] SCTest10bitDAC,
    input [9:0] SweepACQ10bitDAC,
    input [1:0] SweepACQDacSelect;
    output [9:0] OutMicroroc10bitDAC0,
    output [9:0] OutMicroroc10bitDAC1,
    output [9:0] OutMicroroc10bitDAC2,
    // Channel Discriminator Mask
    input [191:0] USBMicrorocChannelMask,
    //input [1:0] USBMicrorocDiscriMask,
    input [191:0] SCTestChannelMask,
    //input [1:0] SCTestDiscriMask,
    output [191:0] OutMicrorocChannelMask,
    //output [1:0] OutMicrorocDiscriMask,
    // CTest Channel
    input [63:0] USBMicrorocCTestChannel,
    input [63:0] SCTestMicrorocCTestChannel,
    output [63:0] OutMicrorocCTestChannel,
    // SC Parameters Load
    input USBMicrorocSCParameterLoad,
    input SCTestMicrorocSCParameterLoad,
    input SweepACQMicrorocSCParameterLoad,
    output OutMicrorocSCParameterLoad,
    // SC or Read Register Select
    input USB_SC_or_Readreg,
    output OutMicroroc_SC_or_Readreg,
    // USB Start
    input USBMicrorocACQStartStop,
    input SweepTestUSBStartStop,
    output USBStartStop,
    // Microroc ACQ Start
    input SweepACQMicrorocACQStartStop,
    output MicrorocACQStartStop,
    // USB Data
    input [15:0] MicrorocACQData,
    input MicrorocACQData_en,
    input [15:0] SweepACQData,
    input SweepACQData_en,
    input [15:0] SCTestData,
    input SCTestData_en,
    output [15:0] USBFifoData,
    output USBFifoData_en,
    output [15:0] ParallelData,
    output ParallelData_en
    );
    // Mux4
    localparam [1:0] ACQMode = 2'b00,
                     SCurveMode = 2'b01,
                     SweepACQMode = 2'b10;
                     //None = 2'b11;
    always @(*) begin
      case(ModeSelect)
        ACQMode:begin
          OutMicroroc10bitDAC0 = USBMicroroc10bitDAC0;
          OutMicroroc10bitDAC1 = USBMicroroc10bitDAC1;
          OutMicroroc10bitDAC2 = USBMicroroc10bitDAC2;
          OutMicrorocChannelMask = USBMicrorocChannelMask;
          //OutMicrorocDiscriMask = USBMicrorocDiscriMask;
          OutMicrorocCTestChannel = USBMicrorocCTestChannel;
          OutMicrorocSCParameterLoad = USBMicrorocSCParameterLoad;
          OutMicroroc_SC_or_Readreg = USB_SC_or_Readreg;
          USBStartStop = USBMicrorocACQStartStop;
          MicrorocACQStartStop = USBMicrorocACQStartStop;
          USBFifoData = MicrorocACQData;
          USBFifoData_en = MicrorocACQData_en;
          ParallelData = 16'b0;
          ParallelData_en = 1'b0;
        end
        SCurveMode:begin
          OutMicroroc10bitDAC0 = SCTest10bitDAC;
          OutMicroroc10bitDAC1 = SCTest10bitDAC;
          OutMicroroc10bitDAC2 = SCTest10bitDAC;
          OutMicrorocChannelMask = SCTestMicrorocChannelMask;
          //OutMicrorocDiscriMask = SCTestMicrorocDiscriMask;
          OutMicrorocCTestChannel = SCTestMicrorocCTestChannel;
          OutMicrorocSCParameterLoad = SCTestMicrorocSCParameterLoad;
          OutMicroroc_SC_or_Readreg = 1'b0; //SC
          USBStartStop = SweepTestUSBStartStop;
          MicrorocACQStartStop = 1'b0;
          USBFifoData = SCTestData;
          USBFifoData_en = SCTestData_en;
          ParallelData = 16'b0;
          ParallelData_en = 1'b0;
        end
        SweepACQMode:begin
          OutMicroroc10bitDAC0 = SweepACQ10bitDAC0;
          OutMicroroc10bitDAC1 = SweepACQ10bitDAC1;
          OutMicroroc10bitDAC2 = SweepACQ10bitDAC2;
          OutMicrorocChannelMask = USBMicrorocChannelMask;
          //OutMicrorocDiscriMask = USBMicrorocDiscriMask;
          OutMicrorocCTestChannel = USBMicrorocCTestChannel;
          OutMicrorocSCParameterLoad = SweepACQMicrorocSCParameterLoad;
          OutMicroroc_SC_or_Readreg = 1'b0; // SC
          USBStartStop = SweepTestUSBStartStop;
          MicrorocACQStartStop = SweepACQMicrorocACQStartStop;
          USBFifoData = SweepACQData;
          USBFifoData_en = SweepACQData_en;
          ParallelData = MicrorocACQData;
          ParallelData_en = MicrorocACQData_en;
        end
        default:begin
          OutMicroroc10bitDAC0 = USBMicroroc10bitDAC0;
          OutMicroroc10bitDAC1 = USBMicroroc10bitDAC1;
          OutMicroroc10bitDAC2 = USBMicroroc10bitDAC2;
          OutMicrorocChannelMask = USBMicrorocChannelMask;
          //OutMicrorocDiscriMask = USBMicrorocDiscriMask;
          OutMicrorocCTestChannel = USBMicrorocCTestChannel;
          OutMicrorocSCParameterLoad = USBMicrorocSCParameterLoad;
          OutMicroroc_SC_or_Readreg = USB_SC_or_Readreg;
          USBStartStop = USBMicrorocACQStartStop;
          MicrorocACQStartStop = USBMicrorocACQStartStop;
          USBFifoData = MicrorocACQData;
          USBFifoData_en = MicrorocACQData_en;
          ParallelData = 16'b0;
          ParallelData_en = 1'b0;
        end
      endcase
    end
endmodule
