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


module Controller_Top(
    input Clk,
    input Clk_5M,
    input reset_n,
    // Mode Select
    input [1:0] ModeSelect,
    input [1:0] DacSelect,
    // Microroc SC Parameter
    input [9:0] UsbMicroroc10BitDac0,
    input [9:0] UsbMicroroc10BitDac1,
    input [9:0] UsbMicroroc10BitDac2,
    output [9:0] OutMicroroc10BitDac0,
    output [9:0] OutMicroroc10BitDac1,
    output [9:0] OutMicroroc10BitDac2,
    input [191:0] UsbMicrorocChannelMask,
    output [191:0] OutMicrorocChannelMask,
    input [63:0] UsbMicrorocCTestChannel,
    output [63:0] OutMicrorocCTestChannel,
    input UsbMicrorocSCParameterLoad,
    output OutMicrorocSCParameterLoad,
    input UsbSCOrReadreg,
    output MicrorocSCOrReadreg,
    input MicrorocConfigDone,
    // Microroc ACQ Control and Data
    output MicrorocAcqStartStop,
    input UsbForceMicrorocAcqReset,
    output MicrorocForceReset, // New add by wyu 20170519
    input [15:0] MicrorocAcqData,
    input MicrorocAcqData_en,
    // USB Interface
    input nPKTEND,
    input UsbDataFifoFull,
    output [15:0] OutUsbExtFifoData,
    output OutUsbExtFifoData_en,
    input MicrorocAcqUsbStartStop,
    output OutUsbStartStop,
    // Sweep Test Start Signal
    input NormalAcqStartStop,
    input SweepTestStartStop,
    // Sweep Test Done Signal
    output SweepTestDone,
    input DataTransmitDone,
    // The following ports is set for SweepACQ and SCurve Test
    //input SweepStart,
    input [9:0] StartDac,
    input [9:0] EndDac,
    // Sweep ACQ
    input [15:0] MaxPackageNumber,
    //SCurve Test
    input TrigEffiOrCountEffi,
    input [5:0] SingleTestChannel,
    input SingleOr64Channel,
    input CTestOrInput,
    input [15:0] CPT_MAX,
    input [15:0] CounterMax,
    output ForceExtRaz,
    // Pin
    input CLK_EXT,
    input out_trigger0b,
    input out_trigger1b,
    input out_trigger2b,
    // *** ADC
    input UsbStartAdc,
    input Hold,
    input [3:0] AdcStartDelay,
    input [7:0] AdcDataNumber,
    input [11:0] ADC_DATA,
    input ADC_OTR,
    output ADC_CLK
    );
    // ***Switcher for ACQ, SweepACQ or SCurve Test
    wire [9:0] SCTest10BitDac;
    wire [9:0] SweepAcq10BitDac;
    // Channel Mask
    wire [191:0] SCTestChannelMask;
    // CTest Channel
    wire [63:0] SCTestMicrorocCTestChannel;
    // SC Parameter Load
    wire SCTestMicrorocSCParameterLoad;
    wire SweepAcqMicrorocSCParameterLoad;
    // Start and done signal
    wire SweepAcqStartStop;
    wire SCTestStartStop;
    wire SCTestDone;
    wire SweepAcqDone;
    // Usb Start Stop
    // Microroc ACQ Start Stop
    wire SweepAcqMicrorocAcqStartStop;
    // Data
    wire [15:0] ParallelData;
    wire ParallelData_en;
    wire [15:0] SweepAcqData;
    wire SweepAcqData_en;
    wire [15:0] SCTestData;
    wire SCTestData_en;
    //wire SweepAcqSingleDacDone;
    wire SweepAcqForceMicrorocAcqReset;
    // ADC Port
    wire [15:0] AdcData;
    wire AdcData_en;
    wire AdcStart;
    wire ForceAdcReset;
    Switcher Switcher(
      // Mode Select
      .ModeSelect(ModeSelect),
      // 10-bit DAC
      .UsbMicroroc10BitDac0(UsbMicroroc10BitDac0),
      .UsbMicroroc10BitDac1(UsbMicroroc10BitDac1),
      .UsbMicroroc10BitDac2(UsbMicroroc10BitDac2),
      .SCTest10BitDac(SCTest10BitDac),
      .SweepAcq10BitDac(SweepAcq10BitDac),
      .SweepAcqDacSelect(DacSelect),
      .OutMicroroc10BitDac0(OutMicroroc10BitDac0),
      .OutMicroroc10BitDac1(OutMicroroc10BitDac1),
      .OutMicroroc10BitDac2(OutMicroroc10BitDac2),
      // Channel and Discriminator Mask
      .UsbMicrorocChannelMask(UsbMicrorocChannelMask),
      .SCTestMicrorocChannelMask(SCTestChannelMask),
      .OutMicrorocChannelMask(OutMicrorocChannelMask),
      // CTest Channel
      .UsbMicrorocCTestChannel(UsbMicrorocCTestChannel),
      .SCTestMicrorocCTestChannel(SCTestMicrorocCTestChannel),
      .OutMicrorocCTestChannel(OutMicrorocCTestChannel),
      // SC Parameters Load
      .UsbMicrorocSCParameterLoad(UsbMicrorocSCParameterLoad),
      .SCTestMicrorocSCParameterLoad(SCTestMicrorocSCParameterLoad),
      .SweepAcqMicrorocSCParameterLoad(SweepAcqMicrorocSCParameterLoad),
      .OutMicrorocSCParameterLoad(OutMicrorocSCParameterLoad),
      // SC or readreg
      .UsbSCOrReadreg(UsbSCOrReadreg),
      .OutMicrorocSCOrReadreg(MicrorocSCOrReadreg),
      // Start Signal
      .UsbMicrorocAcqStartStop(NormalAcqStartStop),
      .UsbSweepTestStartStop(SweepTestStartStop),
      .OutSCTestStartStop(SCTestStartStop),
      .OutSweepAcqStartStop(SweepAcqStartStop),
      // Done Signal
      .SCTestDone(SCTestDone),
      .SweepAcqDone(SweepAcqDone),
      .SweepTestDone(SweepTestDone),
      // USB Start
      .MicrorocAcqUsbStartStop(MicrorocAcqUsbStartStop),
      .SweepTestUsbStartStop(SweepTestStartStop),
      .OutUsbStartStop(OutUsbStartStop),
      // Microroc ACQ Start
      .SweepAcqMicrorocAcqStartStop(SweepAcqMicrorocAcqStartStop),
      .MicrorocAcqStartStop(MicrorocAcqStartStop),
      //.SweepAcqSingleDacDone(SweepAcqSingleDacDone),//New add by wyu 20170519
      .UsbForceMicrorocAcqReset(UsbForceMicrorocAcqReset),
      .SweepAcqForceMicrorocAcqReset(SweepAcqForceMicrorocAcqReset),
      .OutMicrorocForceReset(MicrorocForceReset),//New add by wyu 20170519
      // USB Data
      .MicrorocAcqData(MicrorocAcqData),
      .MicrorocAcqData_en(MicrorocAcqData_en),
      .SweepAcqData(SweepAcqData),
      .SweepAcqData_en(SweepAcqData_en),
      .SCTestData(SCTestData),
      .SCTestData_en(SCTestData_en),
      .UsbFifoData(OutUsbExtFifoData),
      .UsbFifoData_en(OutUsbExtFifoData_en),
      .ParallelData(ParallelData),
      .ParallelData_en(ParallelData_en),
      // ***ADC Control Port
      .AdcData(AdcData),
      .AdcData_en(AdcData_en),
      .UsbStartAdc(UsbStartAdc),
      .AdcStart(AdcStart),
      .ForceAdcReset(ForceAdcReset)
    );
    //--- SweepAcq Module ---//
    SweepACQ_Top SweepACQ(
      .Clk(Clk),
      .reset_n(reset_n),
      // ACQ Control
      .SweepStart(SweepAcqStartStop),
      .SingleACQStart(SweepAcqMicrorocAcqStartStop),
      .ForceMicrorocAcqReset(SweepAcqForceMicrorocAcqReset),
      //.SingleDacDone(SweepAcqSingleDacDone), //New add by wyu 20170519
      .ACQDone(SweepAcqDone),
      .DataTransmitDone(DataTransmitDone),
      // Sweep ACQ Parameters
      .StartDAC0(StartDac),
      .EndDAC0(EndDac),
      .MaxPackageNumber(MaxPackageNumber),
      // ACQ Data
      .ParallelData(ParallelData),
      .ParallelData_en(ParallelData_en),
      // SC Parameters
      .OutDAC0(SweepAcq10BitDac),
      .LoadSCParameter(SweepAcqMicrorocSCParameterLoad),
      .MicrorocConfigDone(MicrorocConfigDone),
      // Data Out
      .SweepACQData(SweepAcqData),
      .SweepACQData_en(SweepAcqData_en),
      .UsbDataFifoFull(UsbDataFifoFull)
    );
    //--- S Curve Test ---//
    SCurve_Test_Top Microroc_SCurveTest(
      .Clk(Clk),
      .Clk_5M(Clk_5M),
      .reset_n(reset_n),
      // Select Trig Efficiency or Counter Efficiency test
      .TrigEffi_or_CountEffi(TrigEffiOrCountEffi),
      //--- Test parameters and control interface--from upper level ---
      .Test_Start(SCTestStartStop),
      .SingleTest_Chn(SingleTestChannel),
      .Single_or_64Chn(SingleOr64Channel),
      .Ctest_or_Input(CTestOrInput),
      .CPT_MAX(CPT_MAX),
      .Counter_MAX(CounterMax),
      .StartDac(StartDac),
      .EndDac(EndDac),
      //--- USB Data FIFO Interface ---
      //.usb_data_fifo_full(),
      .usb_data_fifo_wr_en(SCTestData_en),
      .usb_data_fifo_wr_din(SCTestData),
      .usb_data_fifo_full(UsbDataFifoFull),
      //--- Microroc Config Interface ---
      .Microroc_Config_Done(MicrorocConfigDone),
      .Microroc_CTest_Chn_Out(SCTestMicrorocCTestChannel),
      .Microroc_10bit_DAC_Out(SCTest10BitDac),
      .Microroc_Discriminator_Mask(SCTestChannelMask),
      .SC_Param_Load(SCTestMicrorocSCParameterLoad),
      .Force_Ext_RAZ(ForceExtRaz),
      //--- PIN ---
      .CLK_EXT(CLK_EXT),
      .out_trigger0b(out_trigger0b),
      .out_trigger1b(out_trigger1b),
      .out_trigger2b(out_trigger2b),
      //--- Done Indicator ---
      .SCurve_Test_Done(SCTestDone),
      .Data_Transmit_Done(DataTransmitDone)
    );
    //--- Adc Control ---//
    wire AdcReset_n;
    assign AdcReset_n = reset_n & (~ForceAdcReset);
    AdcControl AD9220(
      .Clk(Clk),
      .reset_n(AdcReset_n),
      .Hold(Hold),
      .StartAcq(AdcStart),
      .AdcStartDelay(AdcStartDelay),
      .AdcDataNumber(AdcDataNumber),
      .ADC_DATA(ADC_DATA),
      .ADC_OTR(ADC_OTR),
      .ADC_CLK(ADC_CLK),
      .Data(AdcData),
      .Data_en(AdcData_en)
    );
endmodule
