`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC 
// Engineer: Yu Wang
// 
// Create Date: 2018/05/24 14:29:55
// Design Name: SDHCAL DIF 1V0
// Module Name: BitShiftOut
// Project Name: SDHCAL DIF 1V0
// Target Devices: XC7A100TFGG484-2L
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


module BitShiftOut(
	input Clk5M,
	input reset_n,
	input BitShiftOutStart,
	output reg ExternalFifoReadEn,
	input ExternalFifoEmpty,
	input [15:0] ExternalFifoDataIn,
	//*** Pins
	output SerialClock,
	output SerialReset,
	output reg SerialDataout,
	output reg BitShiftDone
    );
	//--- Convert the start pulse to a level signal ---//
	reg ShiftStart_i;
	always @ (posedge Clk5M or negedge reset_n) begin
		if(~reset_n)
			ShiftStart_i <= 1'b0;
		else if(BitShiftOutStart)
			ShiftStart_i <= 1'b1;
		else if(BitShiftDone)
			ShiftStart_i <= 1'b0;
	end
	//--- Generate the sr_ck, a quarter of Clk5M, i.e 1.25M ---//
	reg [1:0] SerialClockCount;
	always @ (posedge Clk5M or negedge reset_n) begin
		if(~reset_n)
			SerialClockCount <= 2'b01;
		else if(ShiftStart_i) 
			SerialClockCount <= SerialClockCount + 1'b1;
		else
			SerialClockCount <= 2'b01;
	end
	//--- Serialization out ---//
	reg SerialClockEnable;
	assign SerialClock = SerialClockEnable & SerialClockCount[1];
	reg [2:0] DelayCount;
	reg [3:0] ShiftDataCount;
	reg [15:0] ShiftData;
	reg [2:0] CurrentState;
	reg [2:0] NextState;
	reg SerialReset_r;
	localparam [2:0] Idle = 3'd0,
					RESET_REGISTER = 3'd1,
					READ_FIFO = 3'd2,
					GET_DATA = 3'd3,
					DATA_OUT = 3'd4,
					END_ONCE = 3'd5,
					DONE = 3'd6;
	always @ (posedge Clk5M or negedge reset_n) begin
		if(~reset_n)
			CurrentState <= Idle;
		else
			CurrentState <= NextState;
	end
	always @ (*) begin
		NextState = Idle;
		case(CurrentState)
			Idle:begin
				if(BitShiftOutStart)
					NextState = RESET_REGISTER;
				else
					NextState = Idle;
			end
			RESET_REGISTER:begin
				if(DelayCount < 3'd4)
					NextState = RESET_REGISTER;
				else
					NextState = READ_FIFO;
			end
			READ_FIFO:begin
				if(~ExternalFifoEmpty)
					NextState = GET_DATA;
				else
					NextState = DONE;
			end
			GET_DATA: NextState = DATA_OUT;
			DATA_OUT: begin
				if(ShiftDataCount < 4'd15)
					NextState = DATA_OUT;
				else
					NextState = END_ONCE;
			end
			END_ONCE: NextState = READ_FIFO;
			DONE: NextState = Idle;
			default: NextState = Idle;
		endcase
	end
	always @ (posedge Clk5M or negedge reset_n) begin
		if(~reset_n) begin
			ShiftDataCount <= 4'd0;
			DelayCount <= 3'd0;
			ExternalFifoReadEn <= 1'b0;
			ShiftData <= 16'b0;
			BitShiftDone <= 1'b0;
			SerialClockEnable <= 1'b0;
			SerialDataout <= 1'b0;
			SerialReset_r <= 1'b1;

		end
		else begin
			case(CurrentState)
				Idle: begin
					ShiftDataCount <= 4'd0;
					DelayCount <= 3'd0;
					ExternalFifoReadEn <= 1'b0;
					ShiftData <= 16'b0;
					BitShiftDone <= 1'b0;
					SerialClockEnable <= 1'b0;
					SerialDataout <= 1'b0;
				end
				RESET_REGISTER:begin
					SerialReset_r <= 1'b0;
					DelayCount <= DelayCount + 1'b1;
				end
				READ_FIFO:begin
					DelayCount <= 3'b0;
					ExternalFifoReadEn <= 1'b1;
				end
				GET_DATA: begin
					ShiftData <= ExternalFifoDataIn;
				end
				DATA_OUT: begin
					SerialClockEnable <= 1'b1;
					SerialDataout <= ShiftData[15];
					if(DelayCount < 3'd3) begin
						DelayCount <= DelayCount + 1'b1;
					end
					else begin
						DelayCount <= 3'd0;
						if(ShiftDataCount < 4'd15) begin
							ShiftDataCount <= ShiftDataCount + 1'b1;
							ShiftData <= ShiftData << 1'b1;
						end
					end
				end
				END_ONCE:begin
					ShiftDataCount <= 4'b0;
					SerialClockEnable <= 1'b0;
				end
				DONE: begin
					BitShiftDone <= 1'b1;
				end
			endcase
		end
	end
	assign SerialReset = 1;
endmodule
