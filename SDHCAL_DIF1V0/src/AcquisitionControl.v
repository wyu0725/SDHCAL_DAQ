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

    );
AcquisitionSwitcher Switcher(

    );
SCurve_Test_Top MicrorocSCurveTest(
  .Clk(Clk),
  .Clk_5M(Clk_5M),// Use 5M clock to generate 1k clock
  .reset_n(reset_n),
  
  .TriggerEfficiencyOrCountEfficiency(TriggerEfficiencyOrCountEfficiency),
  
  .Test_Start(Test_Start),
  .SignleTestChannel(SignleTestChannel),
  .Single_or_64Chn(Single_or_64Chn),
  .Ctest_or_Input(Ctest_or_Input), //Add by wyu 20170307. When single channel test, this parameter can choose the charge inject from Ctest pin or the input pin
  .CPT_MAX(CPT_MAX),
  .Counter_MAX(Counter_MAX),
  .StartDac(StartDac),
  .EndDac(EndDac),
  .DacStep(DacStep),
  .TriggerDelay(TriggerDelay),
  .AsicNumber(AsicNumber),
  .TestAsicNumber(TestAsicNumber),
  .UnmaskAllChannel(UnmaskAllChannel),
  
  .SCurveTestDataoutEnable(SCurveTestDataoutEnable),
  .SCurveTestDataout(SCurveTestDataout),
  .ExternalDataFifoFull(ExternalDataFifoFull),
  
  .MicrorocConfigurationDone(MicrorocConfigurationDone),
  .Microroc_CTest_Chn_Out(Microroc_CTest_Chn_Out),
  .Microroc_10bit_DAC_Out(Microroc_10bit_DAC_Out),
  .Microroc_Discriminator_Mask(Microroc_Discriminator_Mask),
  .SlowControlParameterLoadStart(SlowControlParameterLoadStart),
  .Force_Ext_RAZ(Force_Ext_RAZ),
  
  .CLK_EXT(CLK_EXT),
  .out_trigger0b(out_trigger0b),
  .out_trigger1b(out_trigger1b),
  .out_trigger2b(out_trigger2b),
  
  .SCurve_Test_Done(SCurve_Test_Done),
  .Data_Transmit_Done(Data_Transmit_Done)
  //input Data_Transmit_Done
  );
AdcControl AD9220Control(
    .Clk(Clk),
    .reset_n(reset_n),
    .Hold(Hold),
    .StartAcq(StartAcq),
    .AdcStartDelay(AdcStartDelay),
    .AdcDataNumber(AdcDataNumber),
    .ADC_DATA(ADC_DATA),
    .ADC_OTR(ADC_OTR),
    .ADC_CLK(ADC_CLK),
    .Data(Data),
    .Data_en(Data_en)
    );
endmodule
