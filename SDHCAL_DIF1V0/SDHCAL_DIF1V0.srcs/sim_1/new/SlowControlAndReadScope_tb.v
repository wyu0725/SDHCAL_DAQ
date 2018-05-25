`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/05/24 16:14:52
// Design Name:
// Module Name: SlowControlAndReadScope_tb
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


module SlowControlAndReadScope_tb();

	reg Clk;
	reg reset_n;
	wire SlowClock;
	reg MicrorocReset;
	reg SlowControlOrReadScopeSelect;
	reg ParameterLoadStart;
	wire PartameterLoadDone;
	reg [1:0] DataoutChannelSelect;
	reg [1:0] TransmitOnChannelSelect;
	reg ChipSatbEnable;
	reg StartReadoutchannelSelect;
	reg EndReadoutChannelSelect;
	reg [1:0] NC;
	reg [1:0] InternalRazSignalLength;
	reg CkMux;
	reg LvdsReceiverPPEnable;
	reg ExternalRazSignalEnable;
	reg InternalRazSignalEnable;
	reg ExternalTriggerEnable;
	reg TriggerNor64OrDirectSelect;
	reg TriggerOutputEnable;
	reg [2:0] TriggerToWriteSelect;
	reg [9:0] Dac2Vth;
	reg [9:0] Dac1Vth;
	reg [9:0] Dac0Vth;
	reg DacEnable;
	reg DacPPEnable;
	reg BandGapEnable;
	reg BandGapPPEnable;
	reg [7:0] ChipID;
	reg [191:0] ChannelDiscriminatorMask;
	reg LatchedOrDirectOutput;
	reg Discriminator2PPEnable;
	reg Discriminator1PPEnable;
	reg Discriminator0PPEnable;
	reg OTAqPPEnable;
	reg OTAqEnable;
	reg Dac4bitPPEnable;
	reg [255:0] ChannelAdjust;
	reg [1:0] HighGainShaperFeedbackSelect;
	reg ShaperOutLowGainOrHighGain;
	reg WidlarPPEnable;
	reg [1:0] LowGainShaperFeedbackSelect;
	reg LowGainShaperPPEnable;
	reg HighGainShaperPPEnable;
	reg GainBoostEnable;
	reg PreAmplifierPPEnable;
	reg [63:0] CTestChannel;
	reg [63:0] ReadScopeChannel;

	wire SELECT;
	wire SR_RSTB;
	wire SR_CK;
	wire SR_IN;

	SlowControlAndReadScopeSet uut (
		.Clk                         (Clk),
		.reset_n                     (reset_n),
		.SlowClock                   (SlowClock),                    // Slow clock for MICROROC, typically 5M. It is worth to try 10M clock
		.MicrorocReset(), //Not Use
		.SlowControlOrReadScopeSelect(SlowControlOrReadScopeSelect),
		.ParameterLoadStart          (ParameterLoadStart),
		.PartameterLoadDone          (PartameterLoadDone),
		// *** Slow Contro Parameter, from MSB to LSB. These parameter is out from
		// the same secquence, pulsed by the SlowClock.
		.DataoutChannelSelect        (DataoutChannelSelect),         // Default: 11 Valid
		.TransmitOnChannelSelect     (TransmitOnChannelSelect),      // Default: 11 Valid
		.ChipSatbEnable              (ChipSatbEnable),               // Default: 1 Valid
		.StartReadoutchannelSelect   (StartReadoutchannelSelect),    // Default: 1 StartReadout1
		.EndReadoutChannelSelect     (EndReadoutChannelSelect),      // Default: 1 EndReadout1
		.NC                          (NC),
		.InternalRazSignalLength     (InternalRazSignalLength),      // 00: 75ns, 01: 250ns, 10: 500ns, 11: 1us Default: 11
		.CkMux                       (CkMux),                        // Bypass Synchronous PowerOnDigital for SRo, CK5, CK40 Default: 1 bypass POD
		.LvdsReceiverPPEnable        (LvdsReceiverPPEnable),         // Default:0 Disable
		.ExternalRazSignalEnable     (ExternalRazSignalEnable),      // Default: 0 Disable
		.InternalRazSignalEnable     (InternalRazSignalEnable),      // Default: 1 Enable
		.ExternalTriggerEnable       (ExternalTriggerEnable),        // Default: 1 Enable
		.TriggerNor64OrDirectSelect  (TriggerNor64OrDirectSelect),   // Default: 1 Nor64
		.TriggerOutputEnable         (TriggerOutputEnable),          // Default: 1 Enable
		.TriggerToWriteSelect        (TriggerToWriteSelect),         // Default: 111 all
		.Dac2Vth                     (Dac2Vth),                      // MSB->LSB
		.Dac1Vth                     (Dac1Vth),
		.Dac0Vth                     (Dac0Vth),
		.DacEnable                   (DacEnable),
		.DacPPEnable                 (DacPPEnable),
		.BandGapEnable               (BandGapEnable),
		.BandGapPPEnable             (BandGapPPEnable),
		.ChipID                      (ChipID),
		.ChannelDiscriminatorMask    (ChannelDiscriminatorMask),     // MSB correspones to Channel 63
		.LatchedOrDirectOutput       (LatchedOrDirectOutput),        // Default: 1 Latched
		.Discriminator1PPEnable      (Discriminator1PPEnable),
		.Discriminator2PPEnable      (Discriminator2PPEnable),
		.Discriminator0PPEnable      (Discriminator0PPEnable),
		.OTAqPPEnable                (OTAqPPEnable),
		.OTAqEnable                  (OTAqEnable),
		.Dac4bitPPEnable             (Dac4bitPPEnable),
		.ChannelAdjust               (ChannelAdjust),                // MSB to LSB from channel0 to channel 63
		.HighGainShaperFeedbackSelect(HighGainShaperFeedbackSelect), // Default: 10
		.ShaperOutLowGainOrHighGain  (ShaperOutLowGainOrHighGain),   // Default: 0 High gain
		.WidlarPPEnable              (WidlarPPEnable),               // Default: 0 Disable
		.LowGainShaperFeedbackSelect (LowGainShaperFeedbackSelect),  // Default: 101
		.LowGainShaperPPEnable       (LowGainShaperPPEnable),        // Default: 0
		.HighGainShaperPPEnable      (HighGainShaperPPEnable),       // Default: 0
		.GainBoostEnable             (GainBoostEnable),              // Default: 1
		.PreAmplifierPPEnable        (PreAmplifierPPEnable),         // Default: 0
		.CTestChannel                (CTestChannel),
		.ReadScopeChannel            (ReadScopeChannel),
		// *** Pins
		.SELECT(SELECT),                       // select = 1,slowcontrol register select = 0,read register
		.SR_RSTB(SR_RSTB),                      // Selected Register Reset
		.SR_CK(SR_CK),                        // Selected Register Clock
		.SR_IN(SR_IN)                         // Selected Register Input
		);

	//--- Initial ---//
	initial begin
		Clk = 1'b0;
		reset_n = 1'b0;
		MicrorocReset = 1'b0;
		SlowControlOrReadScopeSelect = 1'b0;
		ParameterLoadStart = 1'b0;
		DataoutChannelSelect = 2'b01;
		TransmitOnChannelSelect = 2'b01;
		ChipSatbEnable = 1'b1;
		StartReadoutchannelSelect = 1'b0;
		EndReadoutChannelSelect = 1'b0;
		NC = 2'b11;
		InternalRazSignalLength = 2'b01;
		CkMux = 1'b1;
		LvdsReceiverPPEnable = 1'b0;
		ExternalRazSignalEnable = 1'b1;
		InternalRazSignalEnable = 1'b0;
		ExternalTriggerEnable = 1'b1;
		TriggerNor64OrDirectSelect = 1'b1;
		TriggerOutputEnable = 1'b1;
		TriggerToWriteSelect = 3'b111;
		Dac2Vth = 9'b0_1010_0101;
		Dac1Vth = 9'b0_0101_1010;
		Dac0Vth = 9'b1_1010_1100;
		DacEnable = 1'b1;;
		DacPPEnable = 1'b0;
		BandGapEnable = 1'b0;
		BandGapPPEnable = 1'b1;
		ChipID = 8'b0110_1010;
		ChannelDiscriminatorMask = {192{1'b1}};
		LatchedOrDirectOutput = 1'b0;
		Discriminator2PPEnable = 1'b1;
		Discriminator1PPEnable = 1'b0;
		Discriminator0PPEnable = 1'b1;
		OTAqPPEnable = 1'b0;
		OTAqEnable = 1'b1;
		Dac4bitPPEnable = 1'b1;
		ChannelAdjust = {128{2'b10}};
		HighGainShaperFeedbackSelect = 2'b11;
		ShaperOutLowGainOrHighGain = 2'b0;
		WidlarPPEnable = 1'b1;
		LowGainShaperFeedbackSelect = 2'b01;
		LowGainShaperPPEnable = 1'b0;
		HighGainShaperPPEnable = 1'b1;
		GainBoostEnable = 1'b1;
		PreAmplifierPPEnable = 1'b0;
		CTestChannel = {32{2'b10}};
		ReadScopeChannel = {32{2'b01}};
		#100;
		reset_n = 1'b1;
		#10000;
		ParameterLoadStart = 1'b1;
		#25;
		ParameterLoadStart = 1'b0;
		#600_000;
		SlowControlOrReadScopeSelect = 1'b1;
		#100;
		ParameterLoadStart = 1'b1;
		#25;
		ParameterLoadStart = 1'b0;
	end

	//--- Generate the Clk ---//
	localparam LowPeroid = 12;
	localparam HighPeroid = 13;
	always begin
		#(LowPeroid) Clk = ~Clk;
		#(HighPeroid) Clk = ~Clk;
	end
	reg [2:0] SlowClockCount;
	always @(posedge Clk or negedge reset_n) begin
		if(~reset_n)
			SlowClockCount <= 3'b0;
		else
			SlowClockCount <= SlowClockCount + 1'b1;
	end
	assign SlowClock = SlowClockCount[2];
endmodule
