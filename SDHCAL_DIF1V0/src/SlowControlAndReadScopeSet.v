`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/23 15:50:13
// Design Name: 
// Module Name: SlowControlAndReadScopeSet
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


module SlowControlAndReadScopeSet(
    input Clk,
    input reset_n,
    input SlowClock,// Slow clock for MICROROC, typically 5M. It is worth to try 10M clock
    input MicrorocReset,
    input SlowControlOrReadScopeSelect,
    input ParameterLoadStart,
	output PartameterLoadDone,
	//*** Slow Contro Parameter, from MSB to LSB. These parameter is out from
		//the same secquence, pulsed by the SlowClock.
	input [1:0] DataoutChannelSelect,// Default: 11 Valid
	input [1:0] TransmitOnChannelSelect,// Default: 11 Valid
	input ChipSatbEnable,// Default: 1 Valid
	input StartReadoutchannelSelect, // Default: 1 StartReadout1
	input EndReadoutChannelSelect, // Default: 1 EndReadout1
	input [1:0] NC,
    input [1:0] InternalRazSignalLength,// 00: 75ns, 01: 250ns, 10: 500ns, 11: 1us Default: 11 
    input CkMux,// Bypass Synchronous PowerOnDigital for SRo, CK5, CK40 Default: 1 bypass POD 
    input LvdsReceiverPPEnable,// Default:0 Disable
	input ExternalRazSignalEnable,// Default: 0 Disable 
	input InternalRazSignalEnable, // Default: 1 Enable 
    input ExternalTriggerEnable, // Default: 1 Enable 
    input TriggerNor64OrDirectSelect, // Default: 1 Nor64
    input TriggerOutputEnable, // Default: 1 Enable 
    input [2:0] TriggerToWriteSelect, // Default: 111 all 
    input [9:0] Dac2Vth, // MSB->LSB
    input [9:0] Dac1Vth,
    input [9:0] Dac0Vth,
    input DacEnable,
    input DacPPEnable,
    input BandGapEnable,
    input BandGapPPEnable,
    input [7:0] ChipID,
    input [191:0] ChannelDiscriminatorMask,// MSB correspones to Channel 63 
    input LatchedOrDirectOutput, // Default: 1 Latched 
    input Discriminator1PPEnable,
    input Discriminator2PPEnable,
    input Discriminator0PPEnable,
    input OTAqPPEnable,
    input OTAqEnable,
    input Dac4bitPPEnable,
    input [255:0] ChannelAdjust,// MSB to LSB from channel0 to channel 63
    input [1:0] HighGainShaperFeedbackSelect, // Default: 10
    input ShaperOutLowGainOrHighGain, // Default: 0 High gain 
    input WidlarPPEnable, // Default: 0 Disable 
    input [1:0] LowGainShaperFeedbackSelect, // Default: 101
    input LowGainShaperPPEnable, // Default: 0
    input HighGainShaperPPEnable, // Default: 0
    input GainBoostEnable, // Default: 1
    input PreAmplifierPPEnable, //Default: 0
    input [63:0] CTestChannel,
	input [63:0] ReadScopeChannel,
	//*** Pins
	output SELECT, //select = 1,slowcontrol register; select = 0,read register
    output SR_RSTB,//Selected Register Reset
    output SR_CK,  //Selected Register Clock
    output SR_IN  //Selected Register Input
    );

	ConfigParameterFIFO your_instance_name (
		.clk(clk),      // input wire clk
  		.srst(srst),    // input wire srst
  		.din(din),      // input wire [15 : 0] din
  		.wr_en(wr_en),  // input wire wr_en
  		.rd_en(rd_en),  // input wire rd_en
  		.dout(dout),    // output wire [15 : 0] dout
		.full(full),    // output wire full
		.empty(empty)  // output wire empty
	)
endmodule
