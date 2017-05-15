`timescale 1ns / 1ns
module Switcher_tb;
reg [1:0] ModeSelect;
reg [9:0] UsbMicroroc10BitDac0;
reg [9:0] UsbMicroroc10BitDac1;
reg [9:0] UsbMicroroc10BitDac2;
reg [9:0] SCTest10BitDac;
reg [9:0] SweepAcq10BitDac;
reg [1:0] SweepAcqDacSelect;
wire [9:0] OutMicroroc10BitDac0;
wire [9:0] OutMicroroc10BitDac1;
wire [9:0] OutMicroroc10BitDac2;
reg [191:0] UsbMicrorocChannelMask;
reg [191:0] SCTestMicrorocChannelMask;
wire [191:0] OutMicrorocChannelMask;
reg [63:0] UsbMicrorocCTestChannel;
reg [63:0] SCTestMicrorocCTestChannel;
wire [63:0] OutMicrorocCTestChannel;
reg UsbMicrorocSCParameterLoad;
reg SCTestMicrorocSCParameterLoad;
reg SweepAcqMicrorocSCParameterLoad;
wire OutMicrorocSCParameterLoad;
reg UsbSCOrReadreg;
wire OutMicrorocSCOrReadreg;
reg UsbMicrorocAcqStartStop;
reg UsbSweepTestStartStop;
wire OutSCTestStartStop;
wire OutSweepAcqStartStop;
reg SCTestDone;
reg SweepAcqDone;
wire SweepTestDone;
reg SweepTestUsbStartStop;
wire OutUsbStartStop;
reg SweepAcqMicrorocAcqStartStop;
wire MicrorocAcqStartStop;
reg [15:0] MicrorocAcqData;
reg MicrorocAcqData_en;
reg [15:0] SweepAcqData;
reg SweepAcqData_en;
reg [15:0] SCTestData;
reg SCTestData_en;
wire [15:0] UsbFifoData;
wire UsbFifoData_en;
wire [15:0] ParallelData;
wire ParallelData_en;

Switcher uut(
  .ModeSelect(ModeSelect),
  .UsbMicroroc10BitDac0(UsbMicroroc10BitDac0),
  .UsbMicroroc10BitDac1(UsbMicroroc10BitDac1),
  .UsbMicroroc10BitDac2(UsbMicroroc10BitDac2),
  .SCTest10BitDac(SCTest10BitDac),
  .SweepAcq10BitDac(SweepAcq10BitDac),
  .SweepAcqDacSelect(SweepAcqDacSelect),
  .OutMicroroc10BitDac0(OutMicroroc10BitDac0),
  .OutMicroroc10BitDac1(OutMicroroc10BitDac1),
  .OutMicroroc10BitDac2(OutMicroroc10BitDac2),
  .UsbMicrorocChannelMask(UsbMicrorocChannelMask),
  .SCTestMicrorocChannelMask(SCTestMicrorocChannelMask),
  .OutMicrorocChannelMask(OutMicrorocChannelMask),
  .UsbMicrorocCTestChannel(UsbMicrorocCTestChannel),
  .SCTestMicrorocCTestChannel(SCTestMicrorocCTestChannel),
  .OutMicrorocCTestChannel(OutMicrorocCTestChannel),
  .UsbMicrorocSCParameterLoad(UsbMicrorocSCParameterLoad),
  .SCTestMicrorocSCParameterLoad(SCTestMicrorocSCParameterLoad),
  .SweepAcqMicrorocSCParameterLoad(SweepAcqMicrorocSCParameterLoad),
  .OutMicrorocSCParameterLoad(OutMicrorocSCParameterLoad),
  .UsbSCOrReadreg(UsbSCOrReadreg),
  .OutMicrorocSCOrReadreg(OutMicrorocSCOrReadreg),
  .UsbMicrorocAcqStartStop(UsbMicrorocAcqStartStop),
  .UsbSweepTestStartStop(UsbSweepTestStartStop),
  .OutSCTestStartStop(OutSCTestStartStop),
  .OutSweepAcqStartStop(OutSweepAcqStartStop),
  .SCTestDone(SCTestDone),
  .SweepAcqDone(SweepAcqDone),
  .SweepTestDone(SweepTestDone),
  .SweepTestUsbStartStop(SweepTestUsbStartStop),
  .OutUsbStartStop(OutUsbStartStop),
  .SweepAcqMicrorocAcqStartStop(SweepAcqMicrorocAcqStartStop),
  .MicrorocAcqStartStop(MicrorocAcqStartStop),
  .MicrorocAcqData(MicrorocAcqData),
  .MicrorocAcqData_en(MicrorocAcqData_en),
  .SweepAcqData(SweepAcqData),
  .SweepAcqData_en(SweepAcqData_en),
  .SCTestData(SCTestData),
  .SCTestData_en(SCTestData_en),
  .UsbFifoData(UsbFifoData),
  .UsbFifoData_en(UsbFifoData_en),
  .ParallelData(ParallelData),
  .ParallelData_en(ParallelData_en)
);
initial begin
  ModeSelect = 2'b00;
  UsbMicroroc10BitDac0 = 10'd111;
  UsbMicroroc10BitDac1 = 10'd112;
  UsbMicroroc10BitDac2 = 10'd113;
  SCTest10BitDac = 10'd222;
  SweepAcq10BitDac = 10'd333;
  SweepAcqDacSelect = 2'b00;
  UsbMicrorocChannelMask = 192'd123;
  SCTestMicrorocChannelMask = 192'd233;
  UsbMicrorocCTestChannel = 64'd8;
  SCTestMicrorocCTestChannel = 64'd16;
  UsbMicrorocSCParameterLoad = 1'b1;
  SCTestMicrorocSCParameterLoad = 1'b0;
  SweepAcqMicrorocSCParameterLoad = 1'b1;
  UsbSCOrReadreg = 1'b1;
  UsbMicrorocAcqStartStop = 1'b1;
  UsbSweepTestStartStop = 1'b1;
  SCTestDone = 1'b1;
  SweepAcqDone = 1'b0;
  SweepTestUsbStartStop = 1'b0;
  SweepAcqMicrorocAcqStartStop = 1'b1;
  MicrorocAcqData = 16'h0001;
  MicrorocAcqData_en = 1'b1;
  SweepAcqData = 16'h1010;
  SweepAcqData_en = 1'b1;
  SCTestData = 16'haabb;
  SCTestData_en = 1'b0;
  #(100);
  ModeSelect = 2'b01;
  #(100);
  ModeSelect = 2'b10;
  #(50);
  SweepAcqDacSelect = 2'b01;
  #(50);
  SweepAcqDacSelect = 2'b10;
  #(100);
  ModeSelect = 2'b11;
end
endmodule
