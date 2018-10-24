`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/10/22 17:21:39
// Design Name:
// Module Name: AutoCalibrationSignalGen_tb
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


module AutoCalibrationSignalGen_tb(

  );

  reg Clk;
  reg reset_n;
  reg [15:0] SynchronousClockPeroid;
  reg PowerDown;
  reg Speed;
  reg [11:0] Dac1Data;
  reg [11:0] Dac2Data;
  reg [1:0] LoadDacSelect;
  reg DacLoad;

  reg [7:0] SwitcherOnTime;
  reg [1:0] SwitcherSelect;

  wire SynchronousClock;
  wire nCS;
  wire SCLK;
  wire DIN;
  wire SwitcherOn_A;
  wire SwitcherOn_B;

  //instance:../../../src/AutoCalibrationSignalGen.v
  AutoCalibrationSignalGen uut(
    .Clk(Clk),
    .reset_n(reset_n),
    .SynchronousClockPeroid(SynchronousClockPeroid),
    .SynchronousClock(SynchronousClock),
    // DAC control port
    .PowerDown(PowerDown),
    .Speed(Speed),
    .Dac1Data(Dac1Data),
    .Dac2Data(Dac2Data),
    .LoadDacSelect(LoadDacSelect),
    .DacLoad(DacLoad),
    // DAC PIN
    .nCS(nCS),
    .SCLK(SCLK),
    .DIN(DIN),
    // Switcher Control port
    .SwitcherOnTime(SwitcherOnTime),
    .SwitcherSelect(SwitcherSelect),
    // pin
    .SwitcherOn_A(SwitcherOn_A),
    .SwitcherOn_B(SwitcherOn_B)
    );

  initial begin
    Clk = 1'b0;
    reset_n = 1'b0;
    PowerDown = 1'b0;
    Speed = 1'b1;
    Dac1Data = 12'h5ad;
    Dac2Data = 12'h3d9;
    LoadDacSelect = 2'b0;
    DacLoad = 1'b0;
    SwitcherOnTime = 8'd120;
    SwitcherSelect = 2'b0;
    SynchronousClockPeroid = 16'hff;
    #100;
    reset_n = 1'b1;
    #13;
    #1000;
    SwitcherSelect = 2'b01;
    LoadDacSelect = 2'b01;
    #100;
    DacLoad = 1'b1;
    #25;
    DacLoad = 1'b0;
    #50_000;
    SwitcherSelect = 2'b10;
    #5000;
    LoadDacSelect = 2'b10;
    #100;
    DacLoad = 1'b1;
    #25;
    DacLoad = 1'b0;
    #5000;
    LoadDacSelect = 2'b11;
    #100;
    DacLoad = 1'b1;
    #25;
    DacLoad = 1'b0;
    #50_000;
    SwitcherSelect = 2'b11;
    #5_000_000;
    SwitcherSelect = 2'b00;
  end

  localparam Low = 13;
  localparam High = 12;
  always begin
    #Low Clk = ~Clk;
    #High Clk = ~Clk;
  end

endmodule
