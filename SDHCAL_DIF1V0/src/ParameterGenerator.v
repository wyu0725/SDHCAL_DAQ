`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/05/23 15:59:37
// Design Name:
// Module Name: ParameterGenerator
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


module ParameterGenerator(
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
	//*** FIFO interface
	output ExternalFifoWriteEn,
	output [15:0] ExternalFifoData,
	//*** Parameter generate done. Indicate the bitshift start 
	output ParameterDone
	);
	wire [591:0] SlowControlParameters;
	assign SlowControlParameters[592:591] = DataoutChannelSelect;               //enable dout1b and dout2b
	assign SlowControlParameters[590:589] = TransmitOnChannelSelect;         //enable transmiton1b and transmiton2b
	assign SlowControlParameters[588]     = ChipSatbEnable;           //enable chipsatb
	assign SlowControlParameters[587]     = StartReadoutchannelSelect;      //select startreadout 1 or 2
	assign SlowControlParameters[586]     = EndReadoutChannelSelect;        //select endreadout 1 or 2
	assign SlowControlParameters[585:584] = NC;                 //NC
	assign SlowControlParameters[583:582] = InternalRazSignalLength;               //select raz_chn_width and mux raz_chn width
	assign SlowControlParameters[581]     = CkMux;                //bypass Synchronous PoweronDigital
	assign SlowControlParameters[580]     = LvdsReceiverPPEnable;                 //enable clocks LVDS Receriver power pulsing
	//---------Trigger cell--------------//
	assign SlowControlParameters[579]     = ExternalRazSignalEnable;//Enable external Raz_Channel signal
	assign SlowControlParameters[578]     = InternalRazSignalEnable;//Enable internal Raz_Channel signal
	assign SlowControlParameters[577]     = ExternalTriggerEnable;   //Enable external trigger signal
	assign SlowControlParameters[576]     = TriggerNor64OrDirectSelect;            //Select Channel Trigger selected by Read Register(0) or NOR64 output(1)
	assign SlowControlParameters[575]     = TriggerOutputEnable;           //Enable trigger out
	assign SlowControlParameters[574:572] = TriggerToWriteSelect;                 //select Trigger to write to memory
	//Reverse high bit and low
	//bit,the top level should
	//also reverse.
	//--------Triple DAC-----------------//
	assign SlowControlParameters[571:562] = Dac2Vth;              //10-bit Triple DAC voltage threshold
	assign SlowControlParameters[561:552] = Dac1Vth;
	assign SlowControlParameters[551:542] = Dac0Vth;
	assign SlowControlParameters[541]     = DacEnable;                //Enable dac
	assign SlowControlParameters[540]     = DacPPEnable;             //Enable dac for power pulsing
	assign SlowControlParameters[539]     = BandGapEnable;                 //Enable bandgap
	assign SlowControlParameters[538]     = BandGapPPEnable;              //Enable banggap power pulsing
	//--------Chip ID--------------------//
	assign SlowControlParameters[537:530] = ChipID;                //chip id, revise the chip id
	//----Channel discriminators mask----//
	assign SlowControlParameters[529:338] = ChannelDiscriminatorMask;       //channel discriminators mask
	//---------------BIAS---------------//
	assign SlowControlParameters[337]     = LatchedOrDirectOutput;          //select latched or direct output --default: 1 => latched
	assign SlowControlParameters[336]     = Discriminator1PPEnable;         //enable discri1 power pulsing if discri0 enabled --default: 0 => off
	assign SlowControlParameters[335]     = Discriminator2PPEnable;         //enable discri2 power pulsing if discri0 enabled --default: 0 => off
	assign SlowControlParameters[334]     = Discriminator0PPEnable;         //enable discri0 for power pulsing   --default: 0 => off
	assign SlowControlParameters[333]     = OTAqPPEnable;            //enable otaq for power pulsing      --default: 0 => off
	assign SlowControlParameters[332]     = OTAqEnable;               //enable selected Charge outputs     --default: 0 => off
	assign SlowControlParameters[331]     = Dac4bitPPEnable;         //enable 4-bit DAC for power pulsing --default: 0 => off
	//----Channel 4-bit DAC adjustment---//
	assign SlowControlParameters[330:75]  = ChannelAdjust;            //channel 4-bit DAC adjustment
	//-------------BIAS-----------------//
	assign SlowControlParameters[74:73]   = HighGainShaperFeedbackSelect;                 //switch high gain shaper
	//Reverse high bit and low
	//bit,the top level should
	//also reverse.
	assign SlowControlParameters[72]      = ShaperOutLowGainOrHighGain;          //valid low gain shaper for read  --default: 1 => on
	assign SlowControlParameters[71]      = WidlarPPEnable;          //enable widlar for power pulsing --default: 0 => off
	assign SlowControlParameters[70:69]   = LowGainShaperFeedbackSelect;                 //switch low gain shaper
	//Reverse high bit and low
	//bit,the top level should
	//also reverse.
	assign SlowControlParameters[68]      = LowGainShaperPPEnable;            //enable shaper low gain power pulsing --default: 0 => off
	assign SlowControlParameters[67]      = HighGainShaperPPEnable;            //enable shaper high gain power pulsing --default:0 => off
	assign SlowControlParameters[66]      = GainBoostEnable;               //enable gain boost----default:1 => on
	assign SlowControlParameters[65]      = PreAmplifierPPEnable;          //enable preamplifier power pulsing -- default:0 => off
	//--Enable test capacitor from chn0 ~ chn63---//
	assign SlowControlParameters[64:1]    = CTestChannel;
	
	reg [591:0] SlowControlParameter_Shift;
	reg [63:0] ReadScopeParameter_Shift;
	reg [5:0] ShiftCount;
	reg ParameterOutDone;
	reg [2:0] State;

	localparam SlocControlParameterNumber = 37 - 1; // 592/16=37
	localparam ReadScopeParameterNumber = 4 - 1; // 64/16=4
	localparam [2:0] Idle = 3'd0,
					READ_PROCESS = 3'd1,
					READ_PROCESS_LOOP = 3'd2,
					SC_PROCESS = 3'd3,
					SC_PROCESS_LOOP = 3'd4,
					END_PROCESS = 3'd5;
	always @ (posedge Clk) begin
		case (State)
			Idle: begin
				
			end
		endcase
	end

endmodule
