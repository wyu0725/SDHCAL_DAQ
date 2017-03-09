`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Science and Technology of China
// Engineer: Junbin Zhang
// 
// Create Date: 11/14/2016 02:27:41 PM
// Design Name: SDHCAL_DAQ2V0
// Module Name: Param_Bitshift
// Project Name: SDHCAL_DAQ2V0
// Target Devices: XC7A100TFGG484
// Tool Versions: Vivado 2016.3
// Description: this module contains all the sc parameters and read register of Microroc
//If the chip contains N parameters, you have to send N clock ticks @sr_ck and
//put your parameter @sr_in. The chip capture the data on rising edge so the
//data should be present on the falling edge of sr_ck. sr_ck frequency often
//use is about 1MHz. The sr_out output is the end of the shift
//register(clocked on the falling edge) if you push new parameters @sr_in,
//sr_out outputs the previously load parameters. This is often used when
//chips were daisy chained
//This module reads data from Micro_paramters and shifts bits at dedicated pins.
//MSB first
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Param_Bitshift
(
  input Clk_5M,            //clock 5MHz
  input reset_n,      
  input start_pulse,          //bit shift start
  //-------fifo access-------//
  input [15:0] ext_fifo_data,
  input ext_fifo_empty,
  output reg ext_fifo_rden,
  //-------asic pins--------//
  output sr_ck,         //serial clock
  output sr_rstb,       //reset register
  output sr_in,         //data shifted in
  //-------------------------//
  output RunEnd         //configuration ended
);
//Generate start_level
reg start;
always @(posedge Clk_5M or negedge reset_n) begin
  if (~reset_n)
    // reset
    start <= 1'b0;
  else if (start_pulse)
    start <= 1'b1;
  else if (RunEnd)
    start <= 1'b0;
  else
    start <= start;
end
//Generate sr_ck frequency a quarter of clk,sr_ck = 1.25M 
reg [1:0] cnt;
always @ (posedge Clk_5M , negedge reset_n) begin
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
reg sr_rstb_r;    // register of sr_rstb
reg sr_in_r;      // register of sr_in

reg [15:0] shift_reg16bit;
//counter
reg [2:0] delay_cnt;
reg [3:0] data_cnt;
//state
reg RunEnd_r;
assign sr_ck = sr_ck_en & sr_ck_temp;
//---------------------fsm------------------------//
reg [2:0] State;
localparam [2:0] Idle = 3'b000,
                 READ_FIFO = 3'b001,
                 DATA_LATENCY = 3'b110,//The data latency of the FIFO is 1 period
                 GET_DATA = 3'b010, 
                 LOOP   = 3'b011,
                 END_ONCE = 3'b101,
                 END    = 3'b100;
always @ (posedge Clk_5M , negedge reset_n) begin
  if(~reset_n) begin
    sr_ck_en <= 1'b0;
    sr_rstb_r <= 1'b1;
    sr_in_r <= 1'b0;
    delay_cnt <= 3'b0;
    data_cnt <= 4'b0;
    ext_fifo_rden <= 1'b0;
    RunEnd_r <= 1'b0;
    shift_reg16bit <= 16'b0;
    State <= Idle;
  end
  else begin
    case(State)
      Idle:begin
        if(!start)
          State <= Idle;
        else if(delay_cnt < 3'd4) begin  //sr_rstb_r asserted low about 1us
          sr_rstb_r <= 1'b0;
          delay_cnt <= delay_cnt + 1'b1;
          State <= Idle;
        end
        else begin
          delay_cnt <= 3'd0;
          sr_rstb_r <= 1'b1;
          State <= READ_FIFO;
        end
      end
      READ_FIFO:begin
        if(!ext_fifo_empty) begin
          ext_fifo_rden <= 1'b1;
          State <= DATA_LATENCY;
        end
        else begin //FIFO is empty, 
          State <= END;
          RunEnd_r <= 1'b1;
        end
      end
      DATA_LATENCY:begin
        ext_fifo_rden <= 1'b0;
        State <= GET_DATA;
      end
      GET_DATA:begin
        //ext_fifo_rden <= 1'b0;
        shift_reg16bit <= ext_fifo_data;//modified
        State <= LOOP;
      end
      LOOP:begin
        sr_ck_en <= 1'b1;
        sr_in_r <= shift_reg16bit[15]; //MSB first
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
            //sr_ck_en <= 1'b0; //disable
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
        RunEnd_r <= 1'b0;
      end
      default: State <= Idle;
    endcase
  end
end
//assign sr_rstb = sr_rstb_r;
assign sr_rstb = 1'b1;
assign sr_in = sr_in_r;
assign RunEnd = RunEnd_r;
/*
(*mark_debug = "true"*)wire sr_in_debug1;
(*mark_debug = "true"*)wire sr_ck_debug1;
(*mark_debug = "true"*)wire [15:0]shift_reg16bit_debug;
assign sr_in_debug1 = sr_in;
assign sr_ck_debug1 = sr_ck;
assign shift_reg16bit_debug = shift_reg16bit;*/
endmodule
