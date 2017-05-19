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
    input [9:0] UsbMicroroc10BitDac0,
    input [9:0] UsbMicroroc10BitDac1,
    input [9:0] UsbMicroroc10BitDac2,
    input [9:0] SCTest10BitDac,
    input [9:0] SweepAcq10BitDac,
    input [1:0] SweepAcqDacSelect,
    output reg [9:0] OutMicroroc10BitDac0,
    output reg [9:0] OutMicroroc10BitDac1,
    output reg [9:0] OutMicroroc10BitDac2,
    // Channel Discriminator Mask
    input [191:0] UsbMicrorocChannelMask,
    //input [1:0] USBMicrorocDiscriMask,
    input [191:0] SCTestMicrorocChannelMask,
    //input [1:0] SCTestDiscriMask,
    output reg [191:0] OutMicrorocChannelMask,
    //output [1:0] OutMicrorocDiscriMask,
    // CTest Channel
    input [63:0] UsbMicrorocCTestChannel,
    input [63:0] SCTestMicrorocCTestChannel,
    output reg [63:0] OutMicrorocCTestChannel,
    // SC Parameters Load
    input UsbMicrorocSCParameterLoad,
    input SCTestMicrorocSCParameterLoad,
    input SweepAcqMicrorocSCParameterLoad,
    output reg OutMicrorocSCParameterLoad,
    // SC or Read Register Select
    input UsbSCOrReadreg,
    output reg OutMicrorocSCOrReadreg,
    // Start Signel
    input UsbMicrorocAcqStartStop,
    input UsbSweepTestStartStop,
    output reg OutSCTestStartStop,
    output reg OutSweepAcqStartStop,
    // Done Signal
    input SCTestDone,
    input SweepAcqDone,
    output reg SweepTestDone,
    //input DataTransmitDone,
    //output OutNormalAcqStartStop,
    // USB Start
    //input UsbMicrorocUsbStartStop,
    input SweepTestUsbStartStop,
    output reg OutUsbStartStop,
    // Microroc ACQ Start
    input SweepAcqMicrorocAcqStartStop,
    output reg MicrorocAcqStartStop,
    input SweepAcqSingleDacDone, // New add by wyu for Test
    output reg OutMicrorocForceReset, // New add by wyu
    // USB Data
    input [15:0] MicrorocAcqData,
    input MicrorocAcqData_en,
    input [15:0] SweepAcqData,
    input SweepAcqData_en,
    input [15:0] SCTestData,
    input SCTestData_en,
    output reg [15:0] UsbFifoData,
    output reg UsbFifoData_en,
    output reg [15:0] ParallelData,
    output reg ParallelData_en
    );
    // Mux4
    localparam [1:0] ACQ_MODE = 2'b00,
                     SCURVE_MODE = 2'b01,
                     SWEEP_ACQ_MODE = 2'b10;
                     //None = 2'b11;
    localparam [1:0] DAC0_SELECTED = 2'b00,
                     DAC1_SELECTED = 2'b01,
                     DAC2_SELECTED = 2'b10;
    always @(*) begin
      case(ModeSelect)
        ACQ_MODE:begin
          OutMicroroc10BitDac0 = UsbMicroroc10BitDac0;
          OutMicroroc10BitDac1 = UsbMicroroc10BitDac1;
          OutMicroroc10BitDac2 = UsbMicroroc10BitDac2;
          OutMicrorocChannelMask = UsbMicrorocChannelMask;
          OutMicrorocCTestChannel = UsbMicrorocCTestChannel;
          OutMicrorocSCParameterLoad = UsbMicrorocSCParameterLoad;
          OutMicrorocSCOrReadreg = UsbSCOrReadreg;
          OutSCTestStartStop = 1'b0;
          OutSweepAcqStartStop = 1'b0;
          SweepTestDone = 1'b0;
          //OutNormalAcqStartStop = UsbMicrorocAcqStartStop;
          OutUsbStartStop = UsbMicrorocAcqStartStop;
          MicrorocAcqStartStop = UsbMicrorocAcqStartStop;
          OutMicrorocForceReset = 1'b0;
          UsbFifoData = MicrorocAcqData;
          UsbFifoData_en = MicrorocAcqData_en;
          ParallelData = 16'b0;
          ParallelData_en = 1'b0;
        end
        SCURVE_MODE:begin
          OutMicroroc10BitDac0 = SCTest10BitDac;
          OutMicroroc10BitDac1 = SCTest10BitDac;
          OutMicroroc10BitDac2 = SCTest10BitDac;
          OutMicrorocChannelMask = SCTestMicrorocChannelMask;
          //OutMicrorocDiscriMask = SCTestMicrorocDiscriMask;
          OutMicrorocCTestChannel = SCTestMicrorocCTestChannel;
          OutMicrorocSCParameterLoad = SCTestMicrorocSCParameterLoad;
          OutMicrorocSCOrReadreg = 1'b0; //SC
          OutSCTestStartStop = UsbSweepTestStartStop;
          OutSweepAcqStartStop = 1'b0;
          SweepTestDone = SCTestDone;
          OutUsbStartStop = SweepTestUsbStartStop;
          MicrorocAcqStartStop = 1'b0;
          OutMicrorocForceReset = 1'b0;
          UsbFifoData = SCTestData;
          UsbFifoData_en = SCTestData_en;
          ParallelData = 16'b0;
          ParallelData_en = 1'b0;
        end
        SWEEP_ACQ_MODE:begin
          OutMicroroc10BitDac0 = (SweepAcqDacSelect == DAC0_SELECTED) ? SweepAcq10BitDac : UsbMicroroc10BitDac0;
          OutMicroroc10BitDac1 = (SweepAcqDacSelect == DAC1_SELECTED) ? SweepAcq10BitDac : UsbMicroroc10BitDac1;
          OutMicroroc10BitDac2 = (SweepAcqDacSelect == DAC2_SELECTED) ? SweepAcq10BitDac : UsbMicroroc10BitDac2;
          OutMicrorocChannelMask = UsbMicrorocChannelMask;
          //OutMicrorocDiscriMask = USBMicrorocDiscriMask;
          OutMicrorocCTestChannel = UsbMicrorocCTestChannel;
          OutMicrorocSCParameterLoad = SweepAcqMicrorocSCParameterLoad;
          OutMicrorocSCOrReadreg = 1'b0; // SC
          OutSCTestStartStop = 1'b0;
          OutSweepAcqStartStop = UsbSweepTestStartStop;
          SweepTestDone = SweepAcqDone;
          OutUsbStartStop = SweepTestUsbStartStop;
          MicrorocAcqStartStop = SweepAcqMicrorocAcqStartStop;
          OutMicrorocForceReset = SweepAcqSingleDacDone;
          UsbFifoData = SweepAcqData;
          UsbFifoData_en = SweepAcqData_en;
          ParallelData = MicrorocAcqData;
          ParallelData_en = MicrorocAcqData_en;
        end
        default:begin
          OutMicroroc10BitDac0 = UsbMicroroc10BitDac0;
          OutMicroroc10BitDac1 = UsbMicroroc10BitDac1;
          OutMicroroc10BitDac2 = UsbMicroroc10BitDac2;
          OutMicrorocChannelMask = UsbMicrorocChannelMask;
          //OutMicrorocDiscriMask = USBMicrorocDiscriMask;
          OutMicrorocCTestChannel = UsbMicrorocCTestChannel;
          OutMicrorocSCParameterLoad = UsbMicrorocSCParameterLoad;
          OutMicrorocSCOrReadreg = UsbSCOrReadreg;
          OutSCTestStartStop = 1'b0;
          OutSweepAcqStartStop = 1'b0;
          SweepTestDone = 1'b0;
          OutUsbStartStop = UsbMicrorocAcqStartStop;
          MicrorocAcqStartStop = UsbMicrorocAcqStartStop;
          OutMicrorocForceReset = 1'b0;
          UsbFifoData = MicrorocAcqData;
          UsbFifoData_en = MicrorocAcqData_en;
          ParallelData = 16'b0;
          ParallelData_en = 1'b0;
        end
      endcase
    end
endmodule
