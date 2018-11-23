`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Yu Wang
//
// Create Date: 2018/07/05 17:15:45
// Design Name: SDHCAL DIF 1V0
// Module Name: AcquisitionSwitcher
// Project Name: SDHCAL DIF 1V0
// Target Devices: XC7A100TFGG484-2l
// Tool Versions: Vivado 2018.4
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module AcquisitionSwitcher(
  input [3:0] ModeSelect,
  // Data interface
  input [15:0] MicrorocAcquisitionData,
  input [15:0] SCurveTestData,
  input [15:0] AdcData,
  output reg [15:0] OutTestData,
  input MicrorocAcquisitionDataEnable,
  input SCurveTestDataEnable,
  input AdcDataEnable,
  output reg OutTestDataEnable,
  input ExternalFifoFull,
  output reg ExternalFifoFullToMicrorocAcquisition,
  output reg ExternalFifoFullToSCurveTest,
  output reg ExternalFifoFullToAdc,
  // ConfigInterface
  input CommandMicrorocConfigurationParameterLoad,
  input SCurveTestMicrorocConfigurationParameterLoad,
  output OutMicrorocConfigurationParameterLoad,
  // Configuration Done
  input MicrorocConfigurationDone,
  output reg MicrorocConfigurationDoneToAcquisition,
  output reg OutMicrorocConfigurationDoneToSCurveTest,
  // CTest Channel
  input [63:0] CommandMicrorocCTestChannel,
  input [63:0] SCurveTestMicrorocCTestChannel,
  output reg [63:0] OutMicrorocCTestChannel,
  // Discriminator Mask
  input [191:0] CommandMicrorocChannelDiscriminatorMask,
  input [191:0] SCurveTestMicrorocChannelDiscriminatorMask,
  output reg [191:0] OutMicrorocChannelDiscriminatorMask,
  // Vth DAC
  input [9:0] CommandMicrorocVth0Dac,
  input [9:0] CommandMicrorocVth1Dac,
  input [9:0] CommandMicrorocVth2Dac,
  input [9:0] SCurveTestMicrorocVth0Dac,
  input [9:0] SCurveTestMicrorocVth1Dac,
  input [9:0] SCurveTestMicrorocVth2Dac,
  output reg [9:0] OutMicrorocVth0Dac,
  output reg [9:0] OutMicrorocVth1Dac,
  output reg [9:0] OutMicrorocVth2Dac,
  // Slow Control or Read Scope select
  input CommandMicrorocSlowControlOrReadScopeSelect,
  output reg OutMicrorocSlowControlOrReadScopeSelect,
  // Force External RAZ
  input SCurveTestForceExternalRaz,
  output reg OutForceExternalRaz,
  // StartStop
  input CommandMicrorocAcquisitionStartStop,
  input CommandSCurveTestStartStop,
  input CommandAdcStartStop,
  output reg OutUsbStartStop
  );
  localparam [3:0] ACQUISITION_MODE = 4'b0000,
                   SCURVE_TEST_MODE = 4'b0001,
                   ADC_CONTROL_MODE = 4'b0010;
  always @ (*) begin
    case(ModeSelect)
      ACQUISITION_MODE:begin
        OutTestData                              <= MicrorocAcquisitionData;
        OutTestDataEnable                        <= MicrorocAcquisitionDataEnable;
        ExternalFifoFullToMicrorocAcquisition    <= ExternalFifoFull;
        ExternalFifoFullToSCurveTest             <= 1'b0;
        ExternalFifoFullToAdc                    <= 1'b0;
        //OutMicrorocConfigurationParameterLoad    <= CommandMicrorocConfigurationParameterLoad;
        MicrorocConfigurationDoneToAcquisition   <= MicrorocConfigurationDone;
        OutMicrorocConfigurationDoneToSCurveTest <= 1'b0;
        OutMicrorocCTestChannel                  <= CommandMicrorocCTestChannel;
        OutMicrorocChannelDiscriminatorMask      <= CommandMicrorocChannelDiscriminatorMask;
        OutMicrorocVth0Dac                       <= CommandMicrorocVth0Dac;
        OutMicrorocVth1Dac                       <= CommandMicrorocVth1Dac;
        OutMicrorocVth2Dac                       <= CommandMicrorocVth2Dac;
        OutMicrorocSlowControlOrReadScopeSelect  <= CommandMicrorocSlowControlOrReadScopeSelect;
        OutForceExternalRaz                      <= 1'b0;
        OutUsbStartStop                          <= CommandMicrorocAcquisitionStartStop;
      end
      SCURVE_TEST_MODE:begin
        OutTestData                              <= SCurveTestData;
        OutTestDataEnable                        <= SCurveTestDataEnable;
        ExternalFifoFullToMicrorocAcquisition    <= 1'b0;
        ExternalFifoFullToSCurveTest             <= ExternalFifoFull;
        ExternalFifoFullToAdc                    <= 1'b0;
        //OutMicrorocConfigurationParameterLoad    <= SCurveTestMicrorocConfigurationParameterLoad;
        MicrorocConfigurationDoneToAcquisition   <= 1'b0;
        OutMicrorocConfigurationDoneToSCurveTest <= MicrorocConfigurationDone;
        OutMicrorocCTestChannel                  <= SCurveTestMicrorocCTestChannel;
        OutMicrorocChannelDiscriminatorMask      <= SCurveTestMicrorocChannelDiscriminatorMask;
        OutMicrorocVth0Dac                       <= SCurveTestMicrorocVth0Dac;
        OutMicrorocVth1Dac                       <= SCurveTestMicrorocVth1Dac;
        OutMicrorocVth2Dac                       <= SCurveTestMicrorocVth2Dac;
        OutMicrorocSlowControlOrReadScopeSelect  <= 1'b0;
        OutForceExternalRaz                      <= SCurveTestForceExternalRaz;
        OutUsbStartStop                          <= CommandSCurveTestStartStop;
      end
      ADC_CONTROL_MODE:begin
        OutTestData                              <= AdcData;
        OutTestDataEnable                        <= AdcDataEnable;
        ExternalFifoFullToMicrorocAcquisition    <= 1'b0;
        ExternalFifoFullToSCurveTest             <= 1'b0;
        ExternalFifoFullToAdc                    <= ExternalFifoFull;
        //OutMicrorocConfigurationParameterLoad    <= CommandMicrorocConfigurationParameterLoad;
        MicrorocConfigurationDoneToAcquisition   <= MicrorocConfigurationDone;
        OutMicrorocConfigurationDoneToSCurveTest <= 1'b0;
        OutMicrorocCTestChannel                  <= CommandMicrorocCTestChannel;
        OutMicrorocChannelDiscriminatorMask      <= CommandMicrorocChannelDiscriminatorMask;
        OutMicrorocVth0Dac                       <= CommandMicrorocVth0Dac;
        OutMicrorocVth1Dac                       <= CommandMicrorocVth1Dac;
        OutMicrorocVth2Dac                       <= CommandMicrorocVth2Dac;
        OutMicrorocSlowControlOrReadScopeSelect  <= CommandMicrorocSlowControlOrReadScopeSelect;
        OutForceExternalRaz                      <= 1'b0;
        OutUsbStartStop                          <= CommandAdcStartStop;
      end
      default:begin
        OutTestData                              <= MicrorocAcquisitionData;
        OutTestDataEnable                        <= MicrorocAcquisitionDataEnable;
        ExternalFifoFullToMicrorocAcquisition    <= ExternalFifoFull;
        ExternalFifoFullToSCurveTest             <= 1'b0;
        ExternalFifoFullToAdc                    <= 1'b0;
       //OutMicrorocConfigurationParameterLoad    <= CommandMicrorocConfigurationParameterLoad;
        MicrorocConfigurationDoneToAcquisition   <= MicrorocConfigurationDone;
        OutMicrorocConfigurationDoneToSCurveTest <= 1'b0;
        OutMicrorocCTestChannel                  <= CommandMicrorocCTestChannel;
        OutMicrorocChannelDiscriminatorMask      <= CommandMicrorocChannelDiscriminatorMask;
        OutMicrorocVth0Dac                       <= CommandMicrorocVth0Dac;
        OutMicrorocVth1Dac                       <= CommandMicrorocVth1Dac;
        OutMicrorocVth2Dac                       <= CommandMicrorocVth2Dac;
        OutMicrorocSlowControlOrReadScopeSelect  <= CommandMicrorocSlowControlOrReadScopeSelect;
        OutForceExternalRaz                      <= 1'b0;
        OutUsbStartStop                          <= CommandMicrorocAcquisitionStartStop;
      end
    endcase
  end
  assign OutMicrorocConfigurationParameterLoad = CommandMicrorocConfigurationParameterLoad || SCurveTestMicrorocConfigurationParameterLoad;
endmodule
