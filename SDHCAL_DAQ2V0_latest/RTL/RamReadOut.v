`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Science and Technology of China
// Engineer: Junbin Zhang
// 
// Create Date: 11/14/2016 02:27:41 PM
// Design Name: SDHCAL_DAQ2V0
// Module Name: RamReadout
// Project Name: SDHCAL_DAQ2V0
// Target Devices: XC7A100TFGG484
// Tool Versions: Vivado 2016.3
// Description: Top level of the Microroc ASIC, including slow control Data Acquisition and so on.
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
/*----------Old version----------*/
/*
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

//Data serial to parallel convert convert to 16-bit wide,LSB first
reg [15:0] parallel_data_temp;
reg [4:0]counter;
reg [2:0] SlowCounter;
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n) begin
    parallel_data_temp <= 16'b0;
    //counter <= 5'd0;
    SlowCounter = 3'b0;
  end
  else if (!TransmitOn_reg) begin
    if(SlowCounter == 3'b011) begin
      //counter <= counter + 1'b1;
      SlowCounter <= SlowCounter + 1'b1;
      case(counter[3:0])
        4'd0:parallel_data_temp[0] <= ~Dout_reg;
        4'd1:parallel_data_temp[1] <= ~Dout_reg;
        4'd2:parallel_data_temp[2] <= ~Dout_reg;
        4'd3:parallel_data_temp[3] <= ~Dout_reg;
        4'd4:parallel_data_temp[4] <= ~Dout_reg;
        4'd5:parallel_data_temp[5] <= ~Dout_reg;
        4'd6:parallel_data_temp[6] <= ~Dout_reg;
        4'd7:parallel_data_temp[7] <= ~Dout_reg;
        4'd8:parallel_data_temp[8] <= ~Dout_reg;
        4'd9:parallel_data_temp[9] <= ~Dout_reg;
        4'd10:parallel_data_temp[10] <= ~Dout_reg;
        4'd11:parallel_data_temp[11] <= ~Dout_reg;
        4'd12:parallel_data_temp[12] <= ~Dout_reg;
        4'd13:parallel_data_temp[13] <= ~Dout_reg;
        4'd14:parallel_data_temp[14] <= ~Dout_reg;
        4'd15:parallel_data_temp[15] <= ~Dout_reg;
        default: ;
      endcase
    end
    else
      SlowCounter <= SlowCounter + 1'b1;
  end
  else
    SlowCounter <= 3'b0;
end
//reg [15:0] parallel_data;
//reg parallel_data_en;
//write data into a fifo
reg data_ready;
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n) begin
    parallel_data <= 16'b0;
    data_ready <= 1'b0;
  end
  else if(counter == 5'd16 & !ext_fifo_full) begin                                                                                                                                                                        
    data_ready <= 1'b1;
    parallel_data <= parallel_data_temp;
  end
  else
    data_ready <= 1'b0;
end
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n)
    parallel_data_en <= 1'b0;
  else if(data_ready)
    parallel_data_en <= 1'b1;
  else
    parallel_data_en <= 1'b0;
end
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n)
    counter <= 5'b0;
  else if(SlowCounter == 3'b011) 
    counter <= counter + 1'b1;
  else if(counter == 5'd16)
    counter[4] = 1'b0;
end*/
/*
(*mark_debug = "true"*)wire Dout_debug;
(*mark_debug = "true"*)wire TransmitOn_debug;
(*mark_debug = "true"*)wire Dout_reg_debug;
(*mark_debug = "true"*)wire TransmitOn_reg_debug;
(*mark_debug = "true"*)wire [3:0] counter_debug;
(*mark_debug = "true"*)wire [2:0] SlowCounter_debug;
assign Dout_debug = Dout;
assign TransmitOn_debug = TransmitOn;
assign Dout_reg_debug = Dout_reg;
assign TransmitOn_reg_debug =TransmitOn_reg;
assign Counter_debug = counter;
assign SlowerCounter_debug = SlowCounter;*/

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
