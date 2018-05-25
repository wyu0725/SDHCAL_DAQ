`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC 
// Engineer: Yu Wang
// 
// Create Date: 2018/05/21 11:23:22
// Design Name: Microroc ASIC Control
// Module Name: MicrorocControl
// Project Name: SDHCAL DIF 1V0
// Target Devices: XC7A100TFGG484-2(l)
// Tool Versions: Vivado 2018.1
// Description: This module provides a control interface to the MICROROC
// ASIC. Contain SlowControlOrReadScope parameter sent, ASIC RAM readout,
// signal redundancy and power on control
// PP: Short for power pulsing: If enable, it will fellow the PWR_ON_X pin
// 
// Dependencies: 
// 		FPGA_Top.V
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MicrorocControl(
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
    //***64bit read register
    input [63:0] ReadScopeChannel,
	//*** Redundancy
	input PowerPulsingPinEnable,
	input ReadoutChannelSelect,
	//*** Trigger In
	input TriggerIn,
	//*** Pins
	// Slow control and ReadScope 
	output SELECT, //select = 1,slowcontrol register; select = 0,read register
    output SR_RSTB,//Selected Register Reset
    output SR_CK,  //Selected Register Clock
    output SR_IN,  //Selected Register Input
    //input  SR_OUT, //Selected Register Output,Asic's daisy chain slow control output
    // Power pulsingPin
    output PWR_ON_D,
    output PWR_ON_A,
    output PWR_ON_DAC,
    output PWR_ON_ADC,
    // DAQ Control
    output START_ACQ,
    output RESET_B,
    input  CHIPSATB,
    output START_READOUT1,
    output START_READOUT2,
    input END_READOUT1,
    input END_READOUT2,
    // RAM readout 
    input DOUT1B, 
    input DOUT2B,
    input TRANSMITON1B,
    input TRANSMITON2B,     
    // Trig gen 
    output TRIG_EXT,
    output RAZ_CHNP,
    output RAZ_CHNN,
    output VAL_EVTP,
    output VAL_EVTN,
    output RST_COUNTERB,
    // Clk gen 
    output CK_40P,
    output CK_40N,
    output CK_5P,
    output CK_5N
    );
	SlowControlAndReadScopeSet SlowControlAndReadScope(
		
		);
endmodule
