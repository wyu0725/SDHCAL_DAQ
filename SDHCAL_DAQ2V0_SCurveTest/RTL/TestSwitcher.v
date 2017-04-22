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


module TestSwitcher(
    // ModeSelect
    input [1:0] ModeSelect,
    // --- SC Parameters--- //
    // 10-bits DAC
    input [9:0] USBMicroroc10bitDAC0,
    input [9:0] USBMicroroc10bitDAC1,
    input [9:0] USBMicroroc10bitDAC2,
    input [9:0] SCurveTest10bitDAC0,
    input [9:0] SCurveTest10bitDAC1,
    input [9:0] SCurveTest10bitDAC2,
    input [9:0] SweepACQ10bitDAC0,
    input [9:0] SweepACQ10bitDAC1,
    input [9:0] SweepACQ10bitDAC2,
    output [9:0] OutMicroroc10bitDAC0,
    output [9:0] OutMicroroc10bitDAC1,
    output [9:0] OutMicroroc10bitDAC2,
    // Channel Discriminator Mask
    input [6:0] USBMicrorocChannelMask,
    input [1:0] USBMicrorocDiscriMask,
    input [6:0] SCurveTestChannelMask,
    input [1:0] SCurveTestDiscriMask,
    output [6:0] OutMicrorocChannelMask,
    output [1:0] OutMicrorocDiscriMask,
    // CTest Channel
    input [6:0] USBMicrorocCTestChannel,
    input [6:0] SCurveTestCTestChannel,
    output [6:0] OutMicrorocCTestChannel,
    // SC Parameters Load
    input USBMicrorocSCParameterLoad,
    input SCTestSCParameterLoad,
    output OutMicrorocSCParameterLoad,
    // SC or Read Register Select
    input USB_SC_or_Readreg,
    input SCTest_SC_or_Readreg,
    output Microroc_SC_or_Readreg,
    // USB Data
    input [15:0] MicrorocACQData,
    input MicrorocACQData_en,
    input [15:0] SweepACQData,
    input SweepACQData_en,
    input [15:0] SCTestData,
    input SCTestData_en,
    output [15:0] USBFifoData,
    output USBFifoData_en
    output [15:0] ParallelData,
    output ParallelData_en
    );
    // Mux4
    localparam [1:0] ACQMode = 2'b00,
                     SCurveMode = 2'b01,
                     SweepACQMode = 2'b10,
                     None = 2'b11;
    always @(*) begin
      case(ModeSelect)
        ACQMode:begin
          OutMicroroc10bitDAC0 = USBMicroroc10bitDAC0;
          OutMicroroc10bitDAC1 = USBMicroroc10bitDAC1;
          OutMicroroc10bitDAC2 = USBMicroroc10bitDAC2;
          OutMicrorocChannelMask = USBMicrorocChannelMask;
          OutMicrorocDiscriMask = USBMicrorocDiscriMask;
          OutMicrorocCTestChannel = USBMicrorocCTestChannel;
          Out
        end
        SCurveMode:begin
        end
        SweepACQMode:begin
        end
        Mono:begin
        end
      endcase
    end
endmodule
