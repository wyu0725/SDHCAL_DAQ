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
  /*
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
  reg [4:0] ShiftDataCount;
  reg [15:0] ShiftData;
  reg [2:0] CurrentState;
  reg [2:0] NextState;
  reg DataWait;
  reg SerialReset_r;
  localparam [2:0] Idle = 3'd0,
  RESET_REGISTER = 3'd1,
  READ_FIFO = 3'd2,
  GET_DATA = 3'd3,
  DATA_OUT = 3'd4,
  END_ONCE = 3'd5,
  WAIT = 3'd6,
  DONE = 3'd7;
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
  GET_DATA: begin
  if(DataWait) begin
  NextState = DATA_OUT;
        end
  else begin
  NextState = GET_DATA;
        end
      end
  DATA_OUT: begin
  if(ShiftDataCount < 5'd16)
  NextState = WAIT;
  else
    NextState = END_ONCE;
      end
  WAIT: begin
  if(DelayCount < 3'd2)
  NextState = WAIT;
  else
    NextState = DATA_OUT;
      end
  END_ONCE: NextState = READ_FIFO;
  DONE: NextState = Idle;
  default: NextState = Idle;
    endcase
  end
  always @ (posedge Clk5M or negedge reset_n) begin
  if(~reset_n) begin
  ShiftDataCount <= 5'd0;
  DelayCount <= 3'd0;
  ExternalFifoReadEn <= 1'b0;
  ShiftData <= 16'b0;
  BitShiftDone <= 1'b0;
  SerialClockEnable <= 1'b0;
  SerialDataout <= 1'b0;
  SerialReset_r <= 1'b1;
  DataWait <= 1'b0;
    end
  else begin
  case(CurrentState)
  Idle: begin
  ShiftDataCount <= 5'd0;
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
  SerialReset_r <= 1'b1;
  DelayCount <= 3'b0;
  ExternalFifoReadEn <= 1'b1;
        end
  GET_DATA: begin
  DataWait <= 1'b1;
  ExternalFifoReadEn <= 1'b0;
  ShiftData <= ExternalFifoDataIn;
        end
  DATA_OUT: begin
  DataWait <= 1'b0;
  SerialClockEnable <= 1'b1;
  SerialDataout <= ShiftData[15];
  DelayCount <= 3'd0;
  //if(ShiftDataCount < 5'd15) begin
  ShiftDataCount <= ShiftDataCount + 1'b1;
  ShiftData <= ShiftData << 1'b1;
  //end
        end
  WAIT:DelayCount <= DelayCount + 1'b1;

  END_ONCE:begin
  ShiftDataCount <= 5'b0;
  SerialClockEnable <= 1'b0;
        end
  DONE: begin
  BitShiftDone <= 1'b1;
        end
      endcase
    end
  end
  assign SerialReset = 1;*/
  reg start;
  always @(posedge Clk5M or negedge reset_n) begin
    if (~reset_n)
      // reset
      start <= 1'b0;
    else if (BitShiftOutStart)
      start <= 1'b1;
    else if (BitShiftDone)
      start <= 1'b0;
    else
      start <= start;
  end
  //Generate SerialClock frequency a quarter of clk,sr_ck = 1.25M
  reg [1:0] cnt;
  always @ (posedge Clk5M , negedge reset_n) begin
    if(~reset_n)
      cnt <= 2'b01;
    else if(start) begin
      cnt <= cnt + 1'b1;
    end
    else
      cnt <= 2'b01;
  end
  wire sr_ck_temp;
  assign sr_ck_temp = cnt[1];
  //internal register definition
  reg sr_ck_en;   // sr_ck output enble

  reg [15:0] shift_reg16bit;
  //counter
  reg [2:0] delay_cnt;
  reg [3:0] data_cnt;
  reg SerialReset_r;
  //state
  assign SerialClock = sr_ck_en & sr_ck_temp;
  //---------------------fsm------------------------//
  reg [2:0] State;
  localparam [2:0] Idle = 3'b000,
  READ_FIFO = 3'b001,
  DATA_LATENCY = 3'b110,//The data latency of the FIFO is 1 period
  GET_DATA = 3'b010,
  LOOP   = 3'b011,
  END_ONCE = 3'b101,
  END    = 3'b100;
  always @ (posedge Clk5M , negedge reset_n) begin
    if(~reset_n) begin
      sr_ck_en <= 1'b0;
      SerialReset_r <= 1'b1;
      SerialDataout <= 1'b0;
      delay_cnt <= 3'b0;
      data_cnt <= 4'b0;
      ExternalFifoReadEn <= 1'b0;
      BitShiftDone <= 1'b0;
      shift_reg16bit <= 16'b0;
      State <= Idle;
    end
    else begin
      case(State)
        Idle:begin
          if(!start)
            State <= Idle;
          else if(delay_cnt < 3'd4) begin  //SerialReset_r asserted low about 1us
            SerialReset_r <= 1'b0;
            delay_cnt <= delay_cnt + 1'b1;
            State <= Idle;
          end
          else begin
            delay_cnt <= 3'd0;
            SerialReset_r <= 1'b1;
            State <= READ_FIFO;
          end
        end
        READ_FIFO:begin
          if(!ExternalFifoEmpty) begin
            ExternalFifoReadEn <= 1'b1;
            State <= DATA_LATENCY;
          end
          else begin //FIFO is empty,
            State <= END;
            BitShiftDone <= 1'b1;
          end
        end
        DATA_LATENCY:begin
          ExternalFifoReadEn <= 1'b0;
          State <= GET_DATA;
        end
        GET_DATA:begin
          //ExternalFifoReadEn <= 1'b0;
          shift_reg16bit <= ExternalFifoDataIn;//modified
          State <= LOOP;
        end
        LOOP:begin
          sr_ck_en <= 1'b1;
          SerialDataout <= shift_reg16bit[15]; //MSB first
          if(delay_cnt < 3'd3) begin
            delay_cnt <= delay_cnt + 1'b1;
          end
          else begin
            delay_cnt <= 3'd0;
            if(data_cnt < 4'd15) begin
              data_cnt <= data_cnt + 1'b1;
              shift_reg16bit <= shift_reg16bit << 1;
            end
            else begin
              data_cnt <= 4'd0;
              State <= END_ONCE;
              //SerialClock_en <= 1'b0; //disable
            end
          end
        end
        END_ONCE:begin
          sr_ck_en <= 1'b0;//disable,ensure the last cycle output correctly
          /*if(delay_cnt < 3'd2) begin
            delay_cnt <= delay_cnt + 1'b1;
            State <= END_ONCE;
        end
            else begin
            delay_cnt = 3'd0;
            State = READ_FIFO;
        end*/
            State <= READ_FIFO;
        end
        END:begin
          State <= Idle;
          BitShiftDone <= 1'b0;
        end
        default: State <= Idle;
      endcase
    end
  end
  //assign SerialReset = sr_rstb_r;
  assign SerialReset = 1'b1;
endmodule
