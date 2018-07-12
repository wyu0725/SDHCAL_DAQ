`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer:  Yu Wang
//
// Create Date: 2018/07/05 17:14:44
// Design Name: SDHCAL DIF 1V0
// Module Name: AcquisitionControl
// Project Name: SDHCAL DIF 1V0
// Target Devices: XC7A100TFGG484-2L
// Tool Versions: Vivado 2018.1
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module AcquisitionControl(
  input Clk,
  input Clk5M,
  input reset_n,
  input [3:0] ModeSelect,
  // Data interface
  input [15:0] MicrorocAcquisitionData,
  input MicrorocAcquisitionDataEnable,
  input ExternalFifoFull,
  output [15:0] OutTestData,
  output OutTestDataEnable,
  // Configuration interface
  input CommandMicrorocConfigurationParameterLoad,
  output MicrorocConfigurationParameterLoad,
  input MicrorocConfigurationDone,
  // CTest channel
  input [63:0] CommandMicrorocCTestChannel,
  output [63:0] MicrorocCTestChannel,
  // Channel discriminator mask
  input [191:0] CommandMicrorocChannelDiscriminatorMask,
  output [191:0] MicrorocChannelDiscriminatorMask,
  // Vth DAC
  input [9:0] CommandMicrorocVth0Dac,
  input [9:0] CommandMicrorocVth1Dac,
  input [9:0] CommandMicrorocVth2Dac,
  output [9:0] OutMicrorocVth0Dac,
  output [9:0] OutMicrorocVth1Dac,
  output [9:0] OutMicrorocVth2Dac,
  // SlowControl or ReadScope Select
  input CommandMicrorocSlowControlOrReadScopeSelect,
  output MicrorocSlowControlOrReadScopeSelect,
  // Force External RAZ
  output ForceExternalRaz,
  // StartStop
  input CommandMicrorocAcquisitionStartStop,
  input CommandSCurveTestStartStop,
  input CommandAdcStartStop,
  output OutUsbStartStop,
  // Data Transmit signal
  input nPKTEND,
  output TestDone,

  //*** SCurve ports
  input TriggerEfficiencyOrCountEfficiency,
  input [5:0] SingleTestChannel,
  input SingleOr64Channel,
  input CTestOrInput,
  input [15:0] TriggerCountMax,
  input [15:0] CounterMax,
  input [9:0] StartDac,
  input [9:0] EndDac,
  input [9:0] DacStep,
  input [3:0] TriggerDelay,
  input [2:0] AsicNumber,
  input [2:0] TestAsicNumber,
  input UnmaskAllChannel,
  // Pins
  input SynchronousSignalIn,
  input OutTrigger0b,
  input OutTrigger1b,
  input OutTrigger2b,

  //*** External ADC
  input HoldSignal,
  input [3:0] AdcStartDelay,
  input [7:0] AdcDataNumber,
  // Pins
  input [11:0] ADC_DATA,
  input ADC_OTR,
  output ADC_CLK
  );
  wire [15:0] SCurveTestData;
  wire [15:0] AdcData;
  wire SCurveTestDataEnable;
  wire AdcDataEnable;
  wire ExternalFifoFullToSCurveTest;
  wire ExternalFifoFullToAdc;
  wire SCurveTestMicrorocConfigurationParameterLoad;
  wire MicrorocConfigurationDoneToSCurveTest;
  wire [63:0] SCurveTestMicrorocCTestChannel;
  wire [191:0] SCurveTestMicrorocChannelDiscriminatorMask;
  wire [9:0] SCurveTestMicrorocVthDac;
  wire SCurveTestForceExternalRaz;
  AcquisitionSwitcher Switcher(
    .ModeSelect(ModeSelect),
    // Data interface
    .MicrorocAcquisitionData(MicrorocAcquisitionData),
    .SCurveTestData(SCurveTestData),
    .AdcData(AdcData),
    .OutTestData(OutTestData),
    .MicrorocAcquisitionDataEnable(MicrorocAcquisitionDataEnable),
    .SCurveTestDataEnable(SCurveTestDataEnable),
    .AdcDataEnable(AdcDataEnable),
    .OutTestDataEnable(OutTestDataEnable),
    .ExternalFifoFull(ExternalFifoFull),
    .ExternalFifoFullToMicrorocAcquisition(),
    .ExternalFifoFullToSCurveTest(ExternalFifoFullToSCurveTest),
    .ExternalFifoFullToAdc(ExternalFifoFullToAdc),
    // ConfigInterface
    .CommandMicrorocConfigurationParameterLoad(CommandMicrorocConfigurationParameterLoad),
    .SCurveTestMicrorocConfigurationParameterLoad(SCurveTestMicrorocConfigurationParameterLoad),
    .OutMicrorocConfigurationParameterLoad(MicrorocConfigurationParameterLoad),
    // Configuration Done
    .MicrorocConfigurationDone(MicrorocConfigurationDone),
    .MicrorocConfigurationDoneToAcquisition(),
    .OutMicrorocConfigurationDoneToSCurveTest(MicrorocConfigurationDoneToSCurveTest),
    // CTest Channel
    .CommandMicrorocCTestChannel(CommandMicrorocCTestChannel),
    .SCurveTestMicrorocCTestChannel(SCurveTestMicrorocCTestChannel),
    .OutMicrorocCTestChannel(MicrorocCTestChannel),
    // Discriminator Mask
    .CommandMicrorocChannelDiscriminatorMask(CommandMicrorocChannelDiscriminatorMask),
    .SCurveTestMicrorocChannelDiscriminatorMask(SCurveTestMicrorocChannelDiscriminatorMask),
    .OutMicrorocChannelDiscriminatorMask(MicrorocChannelDiscriminatorMask),
    // Vth DAC
    .CommandMicrorocVth0Dac(CommandMicrorocVth0Dac),
    .CommandMicrorocVth1Dac(CommandMicrorocVth1Dac),
    .CommandMicrorocVth2Dac(CommandMicrorocVth2Dac),
    .SCurveTestMicrorocVth0Dac(SCurveTestMicrorocVthDac),
    .SCurveTestMicrorocVth1Dac(SCurveTestMicrorocVthDac),
    .SCurveTestMicrorocVth2Dac(SCurveTestMicrorocVthDac),
    .OutMicrorocVth0Dac(OutMicrorocVth0Dac),
    .OutMicrorocVth1Dac(OutMicrorocVth1Dac),
    .OutMicrorocVth2Dac(OutMicrorocVth2Dac),
    // Slow Control or Read Scope select
    .CommandMicrorocSlowControlOrReadScopeSelect(CommandMicrorocSlowControlOrReadScopeSelect),
    .OutMicrorocSlowControlOrReadScopeSelect(MicrorocSlowControlOrReadScopeSelect),
    // Force External RAZ
    .SCurveTestForceExternalRaz(SCurveTestForceExternalRaz),
    .OutForceExternalRaz(ForceExternalRaz),
    // StartStop
    .CommandMicrorocAcquisitionStartStop(CommandMicrorocAcquisitionStartStop),
    .CommandSCurveTestStartStop(CommandSCurveTestStartStop),
    .CommandAdcStartStop(CommandAdcStartStop),
    .OutUsbStartStop(OutUsbStartStop)
    );
  SCurve_Test_Top MicrorocSCurveTest(
    .Clk(Clk),
    .Clk_5M(Clk5M),// Use 5M clock to generate 1k clock
    .reset_n(reset_n),

    .TriggerEfficiencyOrCountEfficiency(TriggerEfficiencyOrCountEfficiency),

    .Test_Start(CommandSCurveTestStartStop),
    .SingleTestChannel(SingleTestChannel),
    .Single_or_64Chn(SingleOr64Channel),
    .Ctest_or_Input(CTestOrInput), //Add by wyu 20170307. When single channel test, this parameter can choose the charge inject from Ctest pin or the input pin
    .CPT_MAX(TriggerCountMax),
    .Counter_MAX(CounterMax),
    .StartDac(StartDac),
    .EndDac(EndDac),
    .DacStep(DacStep),
    .TriggerDelay(TriggerDelay),
    .AsicNumber(AsicNumber),
    .TestAsicNumber(TestAsicNumber),
    .UnmaskAllChannel(UnmaskAllChannel),

    .SCurveTestDataoutEnable(SCurveTestDataEnable),
    .SCurveTestDataout(SCurveTestData),
    .ExternalDataFifoFull(ExternalFifoFullToSCurveTest),

    .MicrorocConfigurationDone(MicrorocConfigurationDoneToSCurveTest),
    .Microroc_CTest_Chn_Out(SCurveTestMicrorocCTestChannel),
    .Microroc_10bit_DAC_Out(SCurveTestMicrorocVthDac),
    .Microroc_Discriminator_Mask(SCurveTestMicrorocChannelDiscriminatorMask),
    .SlowControlParameterLoadStart(SCurveTestMicrorocConfigurationParameterLoad),
    .Force_Ext_RAZ(SCurveTestForceExternalRaz),

    .CLK_EXT(SynchronousSignalIn),
    .out_trigger0b(OutTrigger0b),
    .out_trigger1b(OutTrigger1b),
    .out_trigger2b(OutTrigger2b),

    .SCurve_Test_Done(TestDone),
    .Data_Transmit_Done(~nPKTEND)
    //input Data_Transmit_Done
    );
  AdcControl AD9220Control(
    .Clk(Clk),
    .reset_n(reset_n),
    .Hold(HoldSignal),
    .StartAcq(CommandAdcStartStop),
    .AdcStartDelay(AdcStartDelay),
    .AdcDataNumber(AdcDataNumber),
    .ADC_DATA(ADC_DATA),
    .ADC_OTR(ADC_OTR),
    .ADC_CLK(ADC_CLK),
    .Data(AdcData),
    .Data_en(AdcDataEnable)
    );
endmodule
