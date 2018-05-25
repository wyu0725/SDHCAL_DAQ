Redundancy isnt_name (
	.ReadoutChannelSelect(),
	//*** Readout control
	.StartReadout(),
	.EndReadout(),
	.Dout(),
	.TransmitOn(),
	
	//*** Pins
	.START_READOUT1(),
	.START_READOUT2(),
	.END_READOUT1(),
	.END_READOUT2(),
	
	.DOUT1B(),
	.DOUT2B(),
	.TRANSMIION1B(),
	.TRANSMITON2B()
	);
