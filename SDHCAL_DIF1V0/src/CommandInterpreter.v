`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Wang Yu
//
// Create Date: 2018/06/26 11:01:14
// Design Name: SDHCAL DIF 1V0
// Module Name: CommandInterpreter
// Project Name: SDHCAL DIF 1V0
// Target Devices: XC7A100TFGG484-2l
// Tool Versions: Vivado 2018.1
// Description: The command together with its enable signal (CommandWord and
// CommandWordEn) store in an internal FIFO. When the FIFO is not empty, the
// command is readout and interpreted.
// The command must be 16 bits and organized in following fomat
// 		WXYZ: W, X, Y, Z is the hexadecimal number
// 				WX: Address
// 				Y:  Sub-address
// 				Z:  Data (If necessary, Z can be seperated. But not
// 				recommanded)
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module CommandInterpreter(
	input Clk,
	input IFCLK,
	input reset_n,
	// USB interface
	input CommandWordEn,
	input [15:0] CommandWord,
	//--- Command ---//
	output AcquisitionStartStop,
	output ResetDataFifo,
	output [3:0] AsicChainSelect, // Considering the expand board in the future,
	//	the max ASIC chain is set to 16
	//*** Microorc Parameter
	// MICROROC slow control parameter
	output reg MicrorocSlowControlOrReadScopeSelect,
	output reg MicrorocParameterLoadStart,
	output reg [1:0] MicrorocDataoutChannelSelect,
	output reg [1:0] MicrorocTransmitOnChannelSelect,
	// ChipSatbEnable
	output reg MicrorocStartReadoutChannelSelect,
	output reg MicrorocEndReadoutChannelSelect,
	// [1:0] NC
	output reg [1:0] MicrorocInternalRazSignalLength,
	output reg MicrorocCkMux,
	output reg MicrorocLvdsReceiverPPEnable,
	output reg MicrorocExternalRazSignalEnable,
	output reg MicrorocInternalRazSignalEnable,
	output reg MicrorocExternalTriggerEnable,
	output reg MicrorocTriggerNor64OrDirectSelect,
	output reg MicrorocTriggerOutputEnable,
	output reg [2:0] MicrorocTriggerToWriteSelect,
	output reg [9:0] MicrorocDac2Vth,
	output reg [9:0] MicrorocDac1Vth,
	output reg [9:0] MicrorocDac0Vth,
	output reg MicrorocDacEnable,
	output reg MicrorocDacPPEnable,
	output reg MicrorocBandGapEnable,
	output reg MicrorocBandGapPPEnable,
	output reg [7:0] MicrorocChipID,
	output reg [191:0] MicrorocChannelDiscriminatorMask,
	output reg MicrorocLatchedOrDirectOutput,
	output reg MicrorocDisciminator2PPEnable,
	output reg MicrorocDisciminator1PPEnable,
	output reg MicrorocDisciminator0PPEnable,
	output reg MicrorocOTAqPPEnable,
	output reg MicrorocOTAqEnable,
	output reg MicrorocDac4bitPPEnable,
	output reg [255:0] ChannelAdjust,
	output reg [1:0] MicrorocHighGainShaperFeedbackSelect,
	output reg MicrorocShaperOutLowGainOrHighGain,
	output reg MicrorocWidlarPPEnable,
	output reg [1:0] MicrorocLowGainShaperFeedbackSelect,
	output reg MicrorocLowGainShaperPPEnable,
	output reg MicrorocHighGainShaperPPEnable,
	output reg MicrorocGainBoostEnable,
	output reg MicororcPreAmplifierPPEnable,
	output reg [63:0] MicrorocCTestChannel,
	output reg [63:0] MicrorocReadScopeChannel,
	// Microroc Control 
	output reg MicrorocResetTimeStamp,

	//*** Acquisition Control
	// Mode Select
	output reg [2:0] ModeSelect,
	output reg [1:0] DacSelect,
	// Sweep Dac parameter
	output reg [9:0] StartDac,
	output reg [9:0] EndDac,
	output reg [9:0] AdcStep,
	// SCurve Test Port
	output reg SingleOr64Channel,
	output reg CTestOrInput,
	output reg [5:0] SingleTestChannel,
	output reg [15:0] CPT_MAX,
	output reg [3:0] TriggerDelay,
	output reg SweepTestStartStop,
	output reg UnmaskAlllChannel,
	// Count Efficiency
	output reg TriggerEfficiencyOrCountEfficiency,
	output reg [15:0] CounterMax,
	input SweepTestDone,
	input UsbFifoEmpty,
	// Sweep Acq
	output reg [15:0] MaxPackageNumber,
	// Reset Microroc
	output reg ForceMicrorocAcqReset,
	// ADC Control
	output reg AdcStartStop,
	output reg [3:0] AdcStartDelayTime,
	output reg [7:0] AdcDataNumber,
	// Slave DAQ
	output reg [15:0] EndHoldTime,
	output reg DaqSelect,
	// LED
	output reg [7:0] LED
	);

	// Command FIFO interface
	wire [15:0] COMMAND_WORD;
	reg CommandFifoReadEn;
	wire CommandFifoEmpty;
	wire FifoWriteResetBusy;
	wire FifoReadResetBusy;
	wire FifoReady;
	assign FifoReady = !FifoReadResetBusy & !FifoReadResetBusy;
	CommandFifo CommandFifo32Depth (
		.rst(!reset_n),                  // input wire rst
		.wr_clk(IFClk),            // input wire wr_clk
		.rd_clk(Clk),            // input wire rd_clk
		.din(CommandWord),                  // input wire [15 : 0] din
		.wr_en(CommandWordEn),              // input wire wr_en
		.rd_en(CommandFifoReadEn),              // input wire rd_en
		.dout(COMMAND_WORD),                // output wire [15 : 0] dout
		.full(),                // output wire full
		.empty(CommandFifoEmpty),              // output wire empty
		.wr_rst_busy(FifoWriteResetBusy),  // output wire wr_rst_busy
		.rd_rst_busy(FifoReadResetBusy)  // output wire rd_rst_busy
		);

	//*** Read command
	localparam Idle = 1'b0;
	localparam READ = 1'b1;
	reg State;
	always @ (posedge Clk, negedge reset_n) begin
		if(~reset_n) begin
			CommandFifoReadEn <= 1'b0;
			State <= Idle;
		end
		else begin
			case (State)
				Idle:begin
					if(CommandFifoEmpty)
						State <= Idle;
					else begin
						CommandFifoReadEn <= 1'b1;
						State <= READ;
					end
				end
				READ:begin
					CommandFifoReadEn <= 1'b0;
					State <= Idle;
				end
				default:State <= Idle;
			endcase
		end
	end

	//*** Microroc Control Parameter
	// Slow Control or Read Scope
	always @ (posedge Clk or negedge reset_n) begin
		if(~reset_n)
			MicrorocSlowControlOrReadScopeSelect <= 1'b1; // Default Slow Control
		else if(CommandFifoReadEn && COMMAND_WORD == 16'hA0A0)
			MicrorocSlowControlOrReadScopeSelect <= 1'b1;
		else if(CommandFifoReadEn && COMMAND_WORD == 16'hA0A1)
			MicrorocSlowControlOrReadScopeSelect <= 1'b0;
		else
			MicrorocSlowControlOrReadScopeSelect <= MicrorocSlowControlOrReadScopeSelect;
	end

	// Dataout Channel Select
	always @ (posedge Clk or negedge reset_n) begin
	   if(~reset_n)
		   MicrorocDataoutChannelSelect <= 2'b11;
		else if (CommandFifoReadEn && COMMAND_WORD[15:4] == 12h'A0B)
			MicrorocDataoutChannelSelect <= COMMAND_WORD[1:0];
		else
			MicrorocDataoutChannelSelect <= MicrorocDataoutChannelSelect;
	end

	// TransmitOn channel select
	always @ (posedge Clk or negedge reset_n) begin
		if(~reset_n)
			MicrorocTransmitOnChannelSelect <= 2'b11;
		else if(CommandFifoReadEn && COMMAND_WORD[15:4] == 12'hA0C)
			MicrorocTransmitOnChannelSelect <= COMMAND_WORD[1:0];
		else
			MicrorocTransmitOnChannelSelect <= MicrorocTransmitOnChannelSelect;
	end

	// StartReadout channel select
	always @ (posedge Clk or negedge reset_n) begin
		if(~reset_n)
			MicrorocStartReadoutChannelSelect <= 1'b1;
		else if(CommandFifoReadEn && COMMAND_WORD == 16'hA0D0)
			MicrorocStartReadoutChannelSelect <= 1'b
	end

endmodule
