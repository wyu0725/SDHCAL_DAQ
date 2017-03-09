`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Science and Technology of China
// Engineer: Yu W
// 
// Create Date: 12/13/2016 7:20:41 PM
// Design Name: SDHCAL_DAQ2V0
// Module Name: RamReadout
// Project Name: SDHCAL_DAQ2V0
// Target Devices: XC7A100TFGG484
// Tool Versions: Vivado 2016.3
// Description:Rewrite this module 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module RamReadOut
(
  input Clk,
  input reset_n,  
  input Dout, //pin Active L
  input TransmitOn,//pin  Active L
  //------fifo access-----------//
  input ext_fifo_full,
  output reg [15:0] parallel_data,
  output reg parallel_data_en
);
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
reg [15:0] parallel_data_temp
reg [3:0] counter;
reg [2:0] SlowCounter;
always @ (posedge Clk, negedge reset_n) begin
  if(~reset_n) begin
    parallel_data_temp <= 16'b0;
    counter <= 4'd0;
  end
  else if(TransmitOn_reg) begin
    parallel_data_temp <= 16'b0;
    counter <= 4'd0;
  end
  else if(SlowCounter == 3'b011) begin
    parallel_data_temp[counter] <= ~Dout_reg;
    counter <= counter + 1'b1;
  end
  else begin
    counter <= counter;
    parallel_data_temp <= parallel_data_temp;
  end
end
//Generate Slowcounter
//Divide the Clk(40M) by 8,so that the clock for counter is 5M, the at the
//middle of the 5M peroid, acquire data from Dout
always @ (posedge Clk, negedge reset_n) begin
  if(~reset_n) 
    SlowCounter <= 3'b0;
  else if(TransmitOn)
    SlowCounter <= 3'b0;
  else
    SlowCounter <= SlowCounter + 1'b1;
end
//Generate the carry signal for parallel data ready
reg counter_carry;
reg counter_carry_1;
always @ (posedge Clk, negedge reset_n) begin
  counter_carry <= &counter;
  counter_carry_1 <= counter_carry;
end
wire data_ready;
assign data_ready = counter_carry && (~counter_carry1);
//Parallel data out
always @ (posedge Clk, negedge reset_n) begin
  if(~reset_n) begin
    parallel_data_en <= 0;
    parallel_data <= 16'd0;
  end
  else if(data_ready) begin
    parallel_data_en <= 1'b1;
    parallel_data <= parallel_data_reg;
  end
  else begin
    parallel_data_en <= 1'b0;
    parallel_data <= 16'b0;
  end
end
endmodule
