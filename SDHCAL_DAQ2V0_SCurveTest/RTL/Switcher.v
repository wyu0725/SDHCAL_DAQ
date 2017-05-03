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
    input [1:0] DacSelect,
    // --- SC Parameters--- //
    // 10-bits DAC
    input [9:0] UsbMicroroc10BitDac0,
    input [9:0] UsbMicroroc10BitDac1,
    input [9:0] UsbMicroroc10BitDac2,
    input [9:0] SCTest10BitDac,
    input [9:0] SweepAcq10BitDac,
    input [1:0] SweepAcqDacSelect,
    output [9:0] OutMicroroc10BitDac0,
    output [9:0] OutMicroroc10BitDac1,
    output [9:0] OutMicroroc10BitDac2,
    // Channel Discriminator Mask
    input [191:0] UsbMicrorocChannelMask,
    //input [1:0] USBMicrorocDiscriMask,
    input [191:0] SCTestMicrorocChannelMask,
    //input [1:0] SCTestDiscriMask,
    output [191:0] OutMicrorocChannelMask,
    //output [1:0] OutMicrorocDiscriMask,
    // CTest Channel
    input [63:0] UsbMicrorocCTestChannel,
    input [63:0] SCTestMicrorocCTestChannel,
    output [63:0] OutMicrorocCTestChannel,
    // SC Parameters Load
    input UsbMicrorocSCParameterLoad,
    input SCTestMicrorocSCParameterLoad,
    input SweepAcqMicrorocSCParameterLoad,
    output OutMicrorocSCParameterLoad,
    // SC or Read Register Select
    input UsbSCOrReadreg,
    output OutMicrorocSCOrReadreg,
    // Start Signel
    input UsbMicrorocAcqStartStop,
    input UsbSweepTestStartStop,
    output OutSCTestStartStop,
    output OutSweepAcqStartStop,
    // Done Signal
    input SCTestDone,
    input SweepAcqDone,
    output SweepTestDone,
    //input DataTransmitDone,
    //output OutNormalAcqStartStop,
    // USB Start
    //input UsbMicrorocUsbStartStop,
    input SweepTestUsbStartStop,
    output OutUsbStartStop,
    // Microroc ACQ Start
    input SweepAcqMicrorocAcqStartStop,
    output MicrorocAcqStartStop,
    // USB Data
    input [15:0] MicrorocAcqData,
    input MicrorocAcqData_en,
    input [15:0] SweepAcqData,
    input SweepAcqData_en,
    input [15:0] SCTestData,
    input SCTestData_en,
    output [15:0] UsbFifoData,
    output UsbFifoData_en,
    output [15:0] ParallelData,
    output ParallelData_en
    );
    // Mux4
    localparam [1:0] ACQ_MODE = 2'b00,
                     SCURVE_MODE = 2'b01,
                     SWEEP_ACQ_MODE = 2'b10;
                     //None = 2'b11;
    localparam [1:0] NONE_DAC = 2'b00,
                     DAC0_SELECTED = 2'b01,
                     DAC1_SELECTED = 2'b10,
                     DAC2_SELECTED = 2'b11;
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
          UsbFifoData = SCTestData;
          UsbFifoData_en = SCTestData_en;
          ParallelData = 16'b0;
          ParallelData_en = 1'b0;
        end
        SWEEP_ACQ_MODE:begin
          OutMicroroc10BitDac0 = (DacSelect == DAC0_SELECTED) ? SweepAcq10BitDac : UsbMicroroc10BitDac0;
          OutMicroroc10BitDac1 = (DacSelect == DAC1_SELECTED) ? SweepAcq10BitDac : UsbMicroroc10BitDac1;
          OutMicroroc10BitDac2 = (DacSelect == DAC2_SELECTED) ? SweepAcq10BitDac : UsbMicroroc10BitDac2;
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
          UsbFifoData = MicrorocAcqData;
          UsbFifoData_en = MicrorocAcqData_en;
          ParallelData = 16'b0;
          ParallelData_en = 1'b0;
        end
      endcase
    end
endmodule
