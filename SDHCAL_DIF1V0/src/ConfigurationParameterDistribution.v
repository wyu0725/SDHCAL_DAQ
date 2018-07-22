`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/06/26 16:21:40
// Design Name:
// Module Name: ConfigurationParameterDistribution_input_Input
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created_input_Input
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module ConfigurationParameterDistribution
  #(
    parameter [3:0] ASIC_CHAIN_NUMBER = 4'd4
  )
  (
    input Clk,
    input reset_n,
    input [3:0] AsicChainSelect,
    //*** Microorc Parameter
    // MICROROC slow control parameter
    input MicrorocSlowControlOrReadScopeSelect_Input,
    input MicrorocParameterLoadStart_Input,
    input [ASIC_CHAIN_NUMBER - 1:0]MicrorocParameterLoadDone_Input,
    input [1:0] MicrorocDataoutChannelSelect_Input,
    input [1:0] MicrorocTransmitOnChannelSelect_Input,
    // ChipSatbEnable
    input MicrorocStartReadoutChannelSelect_Input,
    input MicrorocEndReadoutChannelSelect_Input,
    // [1:0] NC
    input [1:0] MicrorocInternalRazSignalLength_Input,
    input MicrorocCkMux_Input,
    input MicrorocLvdsReceiverPPEnable_Input,
    input MicrorocExternalRazSignalEnable_Input,
    input MicrorocInternalRazSignalEnable_Input,
    input MicrorocExternalTriggerEnable_Input,
    input MicrorocTriggerNor64OrDirectSelect_Input,
    input MicrorocTriggerOutputEnable_Input,
    input [2:0] MicrorocTriggerToWriteSelect_Input,
    input [9:0] MicrorocDac2Vth_Input,
    input [9:0] MicrorocDac1Vth_Input,
    input [9:0] MicrorocDac0Vth_Input,
    input MicrorocDacEnable_Input,
    input MicrorocDacPPEnable_Input,
    input MicrorocBandGapEnable_Input,
    input MicrorocBandGapPPEnable_Input,
    input [7:0] MicrorocChipID_Input,
    input [191:0] MicrorocChannelDiscriminatorMask_Input,
    input MicrorocLatchedOrDirectOutput_Input,
    input MicrorocDiscriminator2PPEnable_Input,
    input MicrorocDiscriminator1PPEnable_Input,
    input MicrorocDiscriminator0PPEnable_Input,
    input MicrorocOTAqPPEnable_Input,
    input MicrorocOTAqEnable_Input,
    input MicrorocDac4bitPPEnable_Input,
    input [255:0] ChannelAdjust_Input,
    input [1:0] MicrorocHighGainShaperFeedbackSelect_Input,
    input MicrorocShaperOutLowGainOrHighGain_Input,
    input MicrorocWidlarPPEnable_Input,
    input [1:0] MicrorocLowGainShaperFeedbackSelect_Input,
    input MicrorocLowGainShaperPPEnable_Input,
    input MicrorocHighGainShaperPPEnable_Input,
    input MicrorocGainBoostEnable_Input,
    input MicrorocPreAmplifierPPEnable_Input,
    input [63:0] MicrorocCTestChannel_Input,
    input [63:0] MicrorocReadScopeChannel_Input,
    input MicrorocReadRedundancy_Input,// To redundancy module

    //*** Microorc Parameter
    // MICROROC slow control parameter
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocSlowControlOrReadScopeSelect_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocParameterLoadStart_Output,
    output reg MicrorocParameterLoadDone_Output,
    output reg [2*ASIC_CHAIN_NUMBER - 1:0] MicrorocDataoutChannelSelect_Output,
    output reg [2*ASIC_CHAIN_NUMBER - 1:0] MicrorocTransmitOnChannelSelect_Output,
    // ChipSatbEnable
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocStartReadoutChannelSelect_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocEndReadoutChannelSelect_Output,
    // [1:0] NC
    output reg [2*ASIC_CHAIN_NUMBER - 1:0] MicrorocInternalRazSignalLength_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocCkMux_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocLvdsReceiverPPEnable_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocExternalRazSignalEnable_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocInternalRazSignalEnable_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocExternalTriggerEnable_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocTriggerNor64OrDirectSelect_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocTriggerOutputEnable_Output,
    output reg [3*ASIC_CHAIN_NUMBER - 1:0] MicrorocTriggerToWriteSelect_Output,
    output reg [10*ASIC_CHAIN_NUMBER - 1:0] MicrorocDac2Vth_Output,
    output reg [10*ASIC_CHAIN_NUMBER - 1:0] MicrorocDac1Vth_Output,
    output reg [10*ASIC_CHAIN_NUMBER - 1:0] MicrorocDac0Vth_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocDacEnable_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocDacPPEnable_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocBandGapEnable_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocBandGapPPEnable_Output,
    output reg [8*ASIC_CHAIN_NUMBER - 1:0] MicrorocChipID_Output,
    output reg [192*ASIC_CHAIN_NUMBER - 1:0] MicrorocChannelDiscriminatorMask_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocLatchedOrDirectOutput_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocDiscriminator2PPEnable_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocDiscriminator1PPEnable_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocDiscriminator0PPEnable_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocOTAqPPEnable_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocOTAqEnable_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocDac4bitPPEnable_Output,
    output reg [256*ASIC_CHAIN_NUMBER - 1:0] ChannelAdjust_Output,
    output reg [2*ASIC_CHAIN_NUMBER - 1:0] MicrorocHighGainShaperFeedbackSelect_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocShaperOutLowGainOrHighGain_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocWidlarPPEnable_Output,
    output reg [2*ASIC_CHAIN_NUMBER - 1:0] MicrorocLowGainShaperFeedbackSelect_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocLowGainShaperPPEnable_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocHighGainShaperPPEnable_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocGainBoostEnable_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocPreAmplifierPPEnable_Output,
    output reg [64*ASIC_CHAIN_NUMBER - 1:0] MicrorocCTestChannel_Output,
    output reg [64*ASIC_CHAIN_NUMBER - 1:0] MicrorocReadScopeChannel_Output,
    output reg [ASIC_CHAIN_NUMBER - 1:0] MicrorocReadRedundancy_Output// To redundancy module
    );
  wire [1:0] ASIC_CHAIN_SELECT = AsicChainSelect[1:0];
  always @(posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      //*** MicroorcParameter_Output <= 4'b0;
      // MICROROC slow controlparameter_Output <= 4'b0;
      MicrorocSlowControlOrReadScopeSelect_Output <= 4'b0;
      MicrorocParameterLoadStart_Output <= 4'b0;
      MicrorocParameterLoadDone_Output <= 4'b0;
      MicrorocDataoutChannelSelect_Output <= 8'b0;
      MicrorocTransmitOnChannelSelect_Output <= 8'b0;
      //ChipSatbEnable_Output <= 4'b0;
      MicrorocStartReadoutChannelSelect_Output <= 4'b0;
      MicrorocEndReadoutChannelSelect_Output <= 4'b0;
      // [1:0]NC_Output <= 4'b0;
      MicrorocInternalRazSignalLength_Output <= 8'b0;
      MicrorocCkMux_Output <= 4'b0;
      MicrorocLvdsReceiverPPEnable_Output <= 4'b0;
      MicrorocExternalRazSignalEnable_Output <= 4'b0;
      MicrorocInternalRazSignalEnable_Output <= 4'b0;
      MicrorocExternalTriggerEnable_Output <= 4'b0;
      MicrorocTriggerNor64OrDirectSelect_Output <= 4'b0;
      MicrorocTriggerOutputEnable_Output <= 4'b0;
      MicrorocTriggerToWriteSelect_Output <= 12'b0;
      MicrorocDac2Vth_Output <= 40'b0;
      MicrorocDac1Vth_Output <= 40'b0;
      MicrorocDac0Vth_Output <= 40'b0;
      MicrorocDacEnable_Output <= 4'b0;
      MicrorocDacPPEnable_Output <= 4'b0;
      MicrorocBandGapEnable_Output <= 4'b0;
      MicrorocBandGapPPEnable_Output <= 4'b0;
      MicrorocChipID_Output <= 32'b0;
      MicrorocChannelDiscriminatorMask_Output <= 768'b0;
      MicrorocLatchedOrDirectOutput_Output <= 4'b0;
      MicrorocDiscriminator2PPEnable_Output <= 4'b0;
      MicrorocDiscriminator1PPEnable_Output <= 4'b0;
      MicrorocDiscriminator0PPEnable_Output <= 4'b0;
      MicrorocOTAqPPEnable_Output <= 4'b0;
      MicrorocOTAqEnable_Output <= 4'b0;
      MicrorocDac4bitPPEnable_Output <= 4'b0;
      ChannelAdjust_Output <= 1024'b0;
      MicrorocHighGainShaperFeedbackSelect_Output <= 8'b0;
      MicrorocShaperOutLowGainOrHighGain_Output <= 4'b0;
      MicrorocWidlarPPEnable_Output <= 4'b0;
      MicrorocLowGainShaperFeedbackSelect_Output <= 8'b0;
      MicrorocLowGainShaperPPEnable_Output <= 4'b0;
      MicrorocHighGainShaperPPEnable_Output <= 4'b0;
      MicrorocGainBoostEnable_Output <= 4'b0;
      MicrorocPreAmplifierPPEnable_Output <= 4'b0;
      MicrorocCTestChannel_Output <= 256'b0;
      MicrorocReadScopeChannel_Output <= 256'b0;
      MicrorocReadRedundancy_Output <= 4'b0;// To redundancymodule_Output <= 4'b0;
      // MicrorocControl_Output <= 4'b0;
    end
    else begin
      //*** Microorc Parameter
      // MICROROC slow control parameter
      MicrorocSlowControlOrReadScopeSelect_Output[ASIC_CHAIN_SELECT] <= MicrorocSlowControlOrReadScopeSelect_Input;
      MicrorocParameterLoadStart_Output[ASIC_CHAIN_SELECT] <= MicrorocParameterLoadStart_Input;
      MicrorocParameterLoadDone_Output <= MicrorocParameterLoadDone_Input[ASIC_CHAIN_SELECT];
      MicrorocDataoutChannelSelect_Output[2*(ASIC_CHAIN_SELECT + 1) - 1 -: 2] <= MicrorocDataoutChannelSelect_Input;
      MicrorocTransmitOnChannelSelect_Output[2*(ASIC_CHAIN_SELECT + 1)-1 -: 2] <= MicrorocTransmitOnChannelSelect_Input;
      // ChipSatbEnable
      MicrorocStartReadoutChannelSelect_Output[ASIC_CHAIN_SELECT] <= MicrorocStartReadoutChannelSelect_Input;
      MicrorocEndReadoutChannelSelect_Output[ASIC_CHAIN_SELECT] <= MicrorocEndReadoutChannelSelect_Input;
      // [1:0] NC
      MicrorocInternalRazSignalLength_Output[2*(ASIC_CHAIN_SELECT + 1)-1 -: 2] <= MicrorocInternalRazSignalLength_Input;
      MicrorocCkMux_Output[ASIC_CHAIN_SELECT] <= MicrorocCkMux_Input;
      MicrorocLvdsReceiverPPEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocLvdsReceiverPPEnable_Input;
      MicrorocExternalRazSignalEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocExternalRazSignalEnable_Input;
      MicrorocInternalRazSignalEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocInternalRazSignalEnable_Input;
      MicrorocExternalTriggerEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocExternalTriggerEnable_Input;
      MicrorocTriggerNor64OrDirectSelect_Output[ASIC_CHAIN_SELECT] <= MicrorocTriggerNor64OrDirectSelect_Input;
      MicrorocTriggerOutputEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocTriggerOutputEnable_Input;
      MicrorocTriggerToWriteSelect_Output[3*(ASIC_CHAIN_SELECT + 1)-1 -: 3] <= MicrorocTriggerToWriteSelect_Input;
      MicrorocDac2Vth_Output[10*(ASIC_CHAIN_SELECT + 1)-1 -: 10] <= MicrorocDac2Vth_Input;
      MicrorocDac1Vth_Output[10*(ASIC_CHAIN_SELECT + 1)-1 -: 10] <= MicrorocDac1Vth_Input;
      MicrorocDac0Vth_Output[10*(ASIC_CHAIN_SELECT + 1)-1 -: 10] <= MicrorocDac0Vth_Input;
      MicrorocDacEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocDacEnable_Input;
      MicrorocDacPPEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocDacPPEnable_Input;
      MicrorocBandGapEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocBandGapEnable_Input;
      MicrorocBandGapPPEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocBandGapPPEnable_Input;
      MicrorocChipID_Output[8*(ASIC_CHAIN_SELECT + 1)-1 -: 8] <= MicrorocChipID_Input;
      MicrorocChannelDiscriminatorMask_Output[192*(ASIC_CHAIN_SELECT + 1)-1 -: 192] <= MicrorocChannelDiscriminatorMask_Input;
      MicrorocLatchedOrDirectOutput_Output[ASIC_CHAIN_SELECT] <= MicrorocLatchedOrDirectOutput_Input;
      MicrorocDiscriminator2PPEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocDiscriminator2PPEnable_Input;
      MicrorocDiscriminator1PPEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocDiscriminator1PPEnable_Input;
      MicrorocDiscriminator0PPEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocDiscriminator0PPEnable_Input;
      MicrorocOTAqPPEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocOTAqPPEnable_Input;
      MicrorocOTAqEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocOTAqEnable_Input;
      MicrorocDac4bitPPEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocDac4bitPPEnable_Input;
      ChannelAdjust_Output[256*(ASIC_CHAIN_SELECT + 1)-1 -: 256] <= ChannelAdjust_Input;
      MicrorocHighGainShaperFeedbackSelect_Output[2*(ASIC_CHAIN_SELECT + 1)-1 -: 2] <= MicrorocHighGainShaperFeedbackSelect_Input;
      MicrorocShaperOutLowGainOrHighGain_Output[ASIC_CHAIN_SELECT] <= MicrorocShaperOutLowGainOrHighGain_Input;
      MicrorocWidlarPPEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocWidlarPPEnable_Input;
      MicrorocLowGainShaperFeedbackSelect_Output[2*(ASIC_CHAIN_SELECT + 1)-1 -: 2] <= MicrorocLowGainShaperFeedbackSelect_Input;
      MicrorocLowGainShaperPPEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocLowGainShaperPPEnable_Input;
      MicrorocHighGainShaperPPEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocHighGainShaperPPEnable_Input;
      MicrorocGainBoostEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocGainBoostEnable_Input;
      MicrorocPreAmplifierPPEnable_Output[ASIC_CHAIN_SELECT] <= MicrorocPreAmplifierPPEnable_Input;
      MicrorocCTestChannel_Output[64*(ASIC_CHAIN_SELECT + 1)-1 -: 64] <= MicrorocCTestChannel_Input;
      MicrorocReadScopeChannel_Output[64*(ASIC_CHAIN_SELECT + 1)-1 -: 64] <= MicrorocReadScopeChannel_Input;
      MicrorocReadRedundancy_Output[ASIC_CHAIN_SELECT] <= MicrorocReadRedundancy_Input;// To redundancy module
    end
  end
endmodule
