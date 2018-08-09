`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/05/25 14:50:01
// Design Name:
// Module Name: AsicRamReadout_tb
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


module AsicRamReadout_tb();
  /*  reg ReadClk;
  reg reset_n;
  reg AsicDin;
  reg TransmitOn;
  wire [15:0] ExternalFifoData;
  wire ExternalFifoWriteEn;
  wire ReadDone;

  AsicRamReadout uut (
  .ReadClk(ReadClk),
  .reset_n(reset_n),
  .AsicDin(AsicDin),
  .TransmitOn(TransmitOn),
  .ExternalFifoData(ExternalFifoData),
  .ExternalFifoWriteEn(ExternalFifoWriteEn),
  .ReadDone(ReadDone)
 );
  localparam PEROID = 200;
  initial begin
  ReadClk = 1'b0;
  reset_n = 1'b0;
  AsicDin = 1'b0;
  TransmitOn = 1'b1;
  #150;
  reset_n = 1'b1;
  #950;
  TransmitOn = 1'b0;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;//16
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;//16
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;
  #PEROID;
  AsicDin = 1'b0;
  #PEROID;
  AsicDin = 1'b1;//16
  TransmitOn = 1'b1;
  #PEROID;
  AsicDin = 1'bz;


  end

  always #(PEROID/2) ReadClk = ~ReadClk;*/
  reg clk;
  reg reset_n;
  reg Dout;
  reg TransmitOn;
  reg ext_fifo_full;
  wire [15:0] parallel_data;
  wire parallel_data_en;
  //instantiation
  //instance:../../../src/AsicRamReadout.v
  AsicRamReadout uut(
    .ReadClk(ReadClk),
    .reset_n(reset_n),
    .AsicDin(AsicDin),
    .TransmitOn(TransmitOn),

    .ExternalFifoData(ExternalFifoData),
    .ExternalFifoWriteEn(ExternalFifoWriteEn),
    .ReadDone(ReadDone)
    );
  parameter PERIOD = 200;
  //initial
  initial begin
    clk = 1'b0;
    reset_n = 1'b0;
    Dout = 1'b1;
    TransmitOn = 1'b1;
    ext_fifo_full = 1'b0;
    #100;
    reset_n = 1'b1;
    #(200)
    TransmitOn = 1'b0;
    //Generate Dout
    Dout = 1'b0;//15
    #(PERIOD)
    Dout = 1'b1;//14
    #(PERIOD)
    Dout = 1'b0;//13
    #(PERIOD)
    Dout = 1'b1;//12
    #(PERIOD)
    Dout = 1'b1;//11
    #(PERIOD)
    Dout = 1'b0;//10
    #(PERIOD)
    Dout = 1'b1;//9
    #(PERIOD)
    Dout = 1'b0;//8
    #(PERIOD)
    Dout = 1'b1;//7
    #(PERIOD)
    Dout = 1'b1;//6
    #(PERIOD)
    Dout = 1'b0;//5
    #(PERIOD)
    Dout = 1'b0;//4
    #(PERIOD)
    Dout = 1'b1;//3
    #(PERIOD)
    Dout = 1'b0;//2
    #(PERIOD)
    Dout = 1'b0;//1
    #(PERIOD)
    Dout = 1'b1;//0
    #(PERIOD)
    Dout = 1'b1;//15
    #(PERIOD)
    Dout = 1'b0;//14
    #(PERIOD)
    Dout = 1'b1;//13
    #(PERIOD)
    Dout = 1'b0;//12
    #(PERIOD)
    Dout = 1'b1;//11
    #(PERIOD)
    Dout = 1'b1;//10
    #(PERIOD)
    Dout = 1'b1;//9
    #(PERIOD)
    Dout = 1'b0;//8
    #(PERIOD)
    Dout = 1'b0;//7
    #(PERIOD)
    Dout = 1'b0;//6
    #(PERIOD)
    Dout = 1'b1;//5
    #(PERIOD)
    Dout = 1'b1;//4
    #(PERIOD)
    Dout = 1'b0;//3
    #(PERIOD)
    Dout = 1'b1;//2
    #(PERIOD)
    Dout = 1'b1;//1
    #(PERIOD)
    Dout = 1'b0;//0
    #(PERIOD)
    Dout = 1'b1;
    TransmitOn = 1'b1;
  end
  //Generate clk
  parameter T_low = 12;
  parameter T_high = 13;
  always begin
    #(T_low) clk = ~clk;
    #(T_high) clk = ~clk;
  end
endmodule
