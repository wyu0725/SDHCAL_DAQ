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

/*
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
endmodule*/
module AsicRamReadout(
  input Clk,
  input reset_n,
  input Dout, //pin Active L
  input TransmitOn,//pin  Active L
  //------fifo access-----------//
  input ext_fifo_full,
  output reg [15:0] parallel_data,
  output reg parallel_data_en
  );
  /*----------Rewrite this module in 2016 12 14 by wyu----------*/
  //synchronize to the clock
  reg Dout_reg;
  reg TransmitOn_reg;
  always @ (posedge Clk , negedge reset_n) begin
    if(~reset_n) begin
      Dout_reg <= 1'b1;
      TransmitOn_reg <= 1'b1;
    end
    else begin
      Dout_reg <= Dout;
      TransmitOn_reg <= TransmitOn;
    end
  end
  //Convert serial data to parallel data, 16-bits, LSB first
  //reg [15:0] parallel_data_temp;
  parameter DATA_WIDTH = 4'd15;
  reg [3:0] counter;
  reg [2:0] SlowCounter;
  //reg CHIP_ID_FLAG;//Chip ID is read from the LSB to the MSB, but the BCID is readout from MSB to LSB. This signal is use to indicate the Chip ID is readout an should be read from
  always @ (posedge Clk, negedge reset_n) begin
    if(~reset_n) begin
      //parallel_data_temp <= 16'b0;
      parallel_data <= 16'b0;
      counter <= 4'd0;
    end
    else if(TransmitOn_reg) begin
      //parallel_data_temp <= 16'b0;
      parallel_data <= 16'b0;
      counter <= 4'd0;
    end
    else if(SlowCounter == 3'b011) begin
      //parallel_data_temp[counter] <= ~Dout_reg;
      parallel_data[DATA_WIDTH - counter] <= ~Dout_reg;
      counter <= counter + 1'b1;
    end
    else begin
      counter <= counter;
      parallel_data <= parallel_data;
      //parallel_data_temp <= parallel_data_temp;
    end
  end
  //Generate Slowcounter
  //Divide the Clk(40M) by 8,so that the clock for counter is 5M, the at the
  //middle of the 5M peroid, acquire data from Dout
  always @ (posedge Clk, negedge reset_n) begin
    if(~reset_n)
      SlowCounter <= 3'b0;
    else if(TransmitOn_reg)
      SlowCounter <= 3'b0;
    else
      SlowCounter <= SlowCounter + 1'b1;
  end
  //Generate the carry signal for parallel data ready
  wire counter_carry;
  assign counter_carry = &counter;
  reg counter_carry1;
  always @ (posedge Clk, negedge reset_n) begin
    if(~reset_n)
      counter_carry1 <= 1'b0;
    else
      counter_carry1 <= counter_carry;
  end
  wire data_ready;
  assign data_ready = (~counter_carry) && counter_carry1;
  //Parallel data out
  always @ (posedge Clk, negedge reset_n) begin
    if(~reset_n) begin
      parallel_data_en <= 0;
      //parallel_data <= 16'd0;
    end
    else if(data_ready && (~ext_fifo_full)) begin
      parallel_data_en <= 1'b1;
      //parallel_data <= parallel_data_temp;
    end
    else begin
      parallel_data_en <= 1'b0;
      //parallel_data <= 16'b0;
    end
  end
endmodule
