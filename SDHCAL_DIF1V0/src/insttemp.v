CommandDecoder
	#(
		.COMMAND_WIDTH(COMMAND_WIDTH) ,
		.COMMAND_ADDRESS(COMMAND_ADDRESS) 
	)
	uut (
	.Clk(Clk),
	.reset_n(reset_n),
	.CommandEn(CommandEn),
	.CommandWord(CommandWord),
	.DefaultValue(DefaultValue),
	.CommandOut(CommandOut)
	);

CommandInterpreter uut (/*autoinst*/);
