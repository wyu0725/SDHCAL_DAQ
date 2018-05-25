ParameterGenerator inst_name (
	.Clk                         (),
    .reset_n                     (),
    .SlowClock                   (), // Slow clock for MICROROC, typically 5M. It is worth to try 10M clock
    .SlowControlOrReadScopeSelect(),
    .ParameterLoadStart          (),
    // *** Slow Contro Parameter, from MSB to LSB. These parameter is out from
        // the same secquence, pulsed by the SlowClock.
	.DataoutChannelSelect        (), // Default: 11 Valid
	.TransmitOnChannelSelect     (), // Default: 11 Valid
	.ChipSatbEnable              (), // Default: 1 Valid
	.StartReadoutchannelSelect   (), // Default: 1 StartReadout1
	.EndReadoutChannelSelect     (), // Default: 1 EndReadout1
	.NC                          (),
    .InternalRazSignalLength     (), // 00: 75ns, 01: 250ns, 10: 500ns, 11: 1us Default: 11
    .CkMux                       (), // Bypass Synchronous PowerOnDigital for SRo, CK5, CK40 Default: 1 bypass POD
    .LvdsReceiverPPEnable        (), // Default:0 Disable
	.ExternalRazSignalEnable     (), // Default: 0 Disable
	.InternalRazSignalEnable     (), // Default: 1 Enable
    .ExternalTriggerEnable       (), // Default: 1 Enable
    .TriggerNor64OrDirectSelect  (), // Default: 1 Nor64
    .TriggerOutputEnable         (), // Default: 1 Enable
    .TriggerToWriteSelect        (), // Default: 111 all
    .Dac2Vth                     (), // MSB->LSB
    .Dac1Vth                     (),
    .Dac0Vth                     (),
    .DacEnable                   (),
    .DacPPEnable                 (),
    .BandGapEnable               (),
    .BandGapPPEnable             (),
    .ChipID                      (),
    .ChannelDiscriminatorMask    (), // MSB correspones to Channel 63
    .LatchedOrDirectOutput       (), // Default: 1 Latched
    .Discriminator1PPEnable      (),
    .Discriminator2PPEnable      (),
    .Discriminator0PPEnable      (),
    .OTAqPPEnable                (),
    .OTAqEnable                  (),
    .Dac4bitPPEnable             (),
    .ChannelAdjust               (), // MSB to LSB from channel0 to channel 63
    .HighGainShaperFeedbackSelect(), // Default: 10
    .ShaperOutLowGainOrHighGain  (), // Default: 0 High gain
    .WidlarPPEnable              (), // Default: 0 Disable
    .LowGainShaperFeedbackSelect (), // Default: 101
    .LowGainShaperPPEnable       (), // Default: 0
    .HighGainShaperPPEnable      (), // Default: 0
    .GainBoostEnable             (), // Default: 1
    .PreAmplifierPPEnable        (), // Default: 0
    .CTestChannel                (),
	.ReadScopeChannel            (),
	.ExternalFifoWriteEn         (),
	.ExternalFifoData            (),
	.ParameterDone               ()
	);
