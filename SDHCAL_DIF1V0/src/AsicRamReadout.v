`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Yu Wang
//
// Create Date: 2018/05/25 11:40:32
// Design Name: SDHCAL DIF 1V0
// Module Name: AsicRamReadout
// Project Name: SDHCAL DIF 1V0
// Target Devices: XC7A100TFGG484
// Tool Versions: Vivado 2018.1
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module AsicRamReadout(
	input ReadClk,
	input reset_n,
	input AsicDin,
	input TransmitOn,

	output reg [15:0] ExternalFifoData,
	output reg ExternalFifoWriteEn,
	output reg ReadDone
	);

	//--- Synchronise the data and TransmitOn to negedge of the clock
	reg AsicDatain_r1;
	reg TransmitOn_r1;
	reg AsicDatain_r2;
	reg TransmitOn_r;
	reg AsicDatain_r;
	reg TransmitOn_rd;
	always @(negedge ReadClk) begin
		AsicDatain_r1 <= AsicDin;
		TransmitOn_r1 <= TransmitOn;
	end
	always @(negedge ReadClk) begin
		AsicDatain_r2 <= AsicDatain_r1;
		TransmitOn_r <= TransmitOn_r1;
	end
	always @ (negedge ReadClk) begin
		AsicDatain_r <= AsicDatain_r2;
		TransmitOn_rd <= TransmitOn_r;
	end

	reg [1:0] CurrentState;
	reg [1:0] NextState;
	localparam [1:0] Idle = 2'b00,
	READ  = 2'b01,
	DONE  = 2'b10;
	localparam DATA_WIDTH = 4'd15;
	always @ (posedge ReadClk or negedge reset_n) begin
		if(~reset_n)
			CurrentState <= Idle;
		else
			CurrentState <= NextState;
	end

	always @ (*) begin
		NextState = Idle;
		case(CurrentState)
			Idle: begin
				if(~TransmitOn_r)
					NextState = READ;
			end
			READ:begin
				if(TransmitOn_rd)
					NextState = DONE;
				else
					NextState = READ;
			end
			DONE: NextState = Idle;
		endcase
	end
	reg [3:0] DataCount;
	always @ (posedge ReadClk) begin
		case(CurrentState)
			Idle:begin
				DataCount <= 4'b0;
				ExternalFifoData <= 16'b0;
				ReadDone <= 1'b0;
			end
			READ:begin
				ExternalFifoData[DATA_WIDTH - DataCount] <= ~AsicDatain_r;
				DataCount <= DataCount + 1'b1;
			end
			DONE:begin
				ReadDone <= 1'b1;
			end
		endcase
	end
	wire DataFull;
	assign DataFull = & DataCount;
	always @ (posedge ReadClk or negedge reset_n) begin
		if(~reset_n)
			ExternalFifoWriteEn <= 1'b0;
		else if(DataFull)
			ExternalFifoWriteEn <= 1'b1;
		else
			ExternalFifoWriteEn <= 1'b0;
	end
  (* MARK_DEBUG="true" *)wire AsicDataIn_Debug;
  (* MARK_DEBUG="true" *)wire Transmiton_Debug;
  assign AsicDataIn_Debug = AsicDatain_r;
  assign TransmitOn_Debug = TransmitOn_rd;
  (* MARK_DEBUG="true" *)wire SlowClock_Debug;
  assign SlowClock_Debug = ReadClk;
endmodule
