`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/10/19 09:42:28
// Design Name:
// Module Name: ChannelMaskSim_tb
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module ChannelMaskSim_tb(

  );
  reg Clk;
  reg IFCLK;
  reg reset_n;
  reg CommandWordEn;
  reg [15:0] CommandWord;
  wire [191:0] MicrorocChannelDiscriminatorMask;

  //instance:../../../src/ChannelMaskSim.v
  ChannelMaskSim uut(
    .Clk(Clk),
    .IFCLK(IFCLK),
    .reset_n(reset_n),
    // USB interface
    .CommandWordEn(CommandWordEn),
    .CommandWord(CommandWord),
    .MicrorocChannelDiscriminatorMask(MicrorocChannelDiscriminatorMask)
    );

  initial begin
    Clk = 1'b0;
    IFCLK = 1'b0;
    reset_n = 1'b0;
    CommandWord <= 16'b0;
    CommandWordEn <= 1'b0;
    #100;
    reset_n = 1'b1;
    #600;
    #12;
    CommandWord = 16'hA2C0;
    #120;
    CommandWordEn = 1'b1;
    #24;
    CommandWordEn = 1'b0;
    // Channel 5
    CommandWord = 16'hA2A5;
    #120;
    CommandWordEn = 1'b1;
    #24;
    CommandWordEn = 1'b0;
    CommandWord = 16'hA2B0;
    #120;
    CommandWordEn = 1'b1;
    #24;
    CommandWordEn = 1'b0;
    CommandWord = 16'hA2D1;
    #120;
    CommandWordEn = 1'b1;
    #24
    CommandWordEn = 1'b0;
    // Channel 21
    CommandWord = 16'hA2A5;
    #120;
    CommandWordEn = 1'b1;
    #24;
    CommandWordEn = 1'b0;
    CommandWord = 16'hA2B1;
    #120;
    CommandWordEn = 1'b1;
    #24;
    CommandWordEn = 1'b0;
    CommandWord = 16'hA2D1;
    #120;
    CommandWordEn = 1'b1;
    #24
    CommandWordEn = 1'b0;
    // Channel 37
    CommandWord = 16'hA2A5;
    #120;
    CommandWordEn = 1'b1;
    #24;
    CommandWordEn = 1'b0;
    CommandWord = 16'hA2B2;
    #120;
    CommandWordEn = 1'b1;
    #24;
    CommandWordEn = 1'b0;
    CommandWord = 16'hA2D1;
    #120;
    CommandWordEn = 1'b1;
    #24
    CommandWordEn = 1'b0;
    // Mask All
    #1200;
    CommandWord = 16'hA2D4;
    #24;
    CommandWordEn = 1'b1;
    #24;
    CommandWordEn = 1'b0;
    #12000;
    // Unmask
    // Channel 5
    CommandWord = 16'hA2A5;
    #120;
    CommandWordEn = 1'b1;
    #24;
    CommandWordEn = 1'b0;
    CommandWord = 16'hA2B0;
    #120;
    CommandWordEn = 1'b1;
    #24;
    CommandWordEn = 1'b0;
    CommandWord = 16'hA2D2;
    #120;
    CommandWordEn = 1'b1;
    #24
    CommandWordEn = 1'b0;
    // Channel 21
    CommandWord = 16'hA2A5;
    #120;
    CommandWordEn = 1'b1;
    #24;
    CommandWordEn = 1'b0;
    CommandWord = 16'hA2B1;
    #120;
    CommandWordEn = 1'b1;
    #24;
    CommandWordEn = 1'b0;
    CommandWord = 16'hA2D2;
    #120;
    CommandWordEn = 1'b1;
    #24
    CommandWordEn = 1'b0;
    // Channel 37
    CommandWord = 16'hA2A5;
    #120;
    CommandWordEn = 1'b1;
    #24;
    CommandWordEn = 1'b0;
    CommandWord = 16'hA2B2;
    #120;
    CommandWordEn = 1'b1;
    #24;
    CommandWordEn = 1'b0;
    CommandWord = 16'hA2D2;
    #120;
    CommandWordEn = 1'b1;
    #24
    CommandWordEn = 1'b0;
    // Mask clear
    #1200;
    CommandWord = 16'hA2D3;
    #24;
    CommandWordEn = 1'b1;
    #24;
    CommandWordEn = 1'b0;

  end

  localparam PEROID_IFCLK = 24;
  always #(PEROID_IFCLK/2) IFCLK = ~IFCLK;
  localparam Low = 13;
  localparam High = 12;
  always begin
    #(Low) Clk = ~Clk;
    #(High) Clk = ~Clk;
  end
endmodule
