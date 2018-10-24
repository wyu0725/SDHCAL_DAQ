`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/10/20 16:49:43
// Design Name:
// Module Name: AutoCalibrationSignalGen
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


module AutoCalibrationSignalGen(
  input Clk,
  input reset_n,
  input [15:0] SynchronousClockPeroid,
  output SynchronousClock,
  // DAC control port
  input PowerDown,
  input Speed,
  input [11:0] Dac1Data,
  input [11:0] Dac2Data,
  input [1:0] LoadDacSelect,
  input DacLoad,
  // DAC PIN
  output nCS,
  output SCLK,
  output DIN,
  // Switcher Control port
  input [15:0] SwitcherOnTime,
  input [1:0] SwitcherSelect,
  // pin
  output SwitcherOn_A,
  output SwitcherOn_B
  );

  DacControlTlv5618 DacValueSet(
    .Clk(Clk),
    .reset_n(reset_n),
    .PowerDown(PowerDown),// 1 -> power down, 0 -> normal mode
    .Speed(Speed),  // 1 -> fast mode, 0 -> slow mode
    .Dac1Data(Dac1Data),
    .Dac2Data(Dac2Data),
    .LoadDacSelect(LoadDacSelect),
    .DacLoadStart(DacLoad),
    .DacLoadDone(),
    .nCS(nCS),
    .SCLK(SCLK),
    .DIN(DIN)
    );

  reg SyncClock;
  CalibrationSwitcherControl CalibrationWaveGenA(
    .Clk(Clk),
    .reset_n(reset_n),
    .SyncClock(SyncClock),
    .SwitcherOnTime(SwitcherOnTime),
    .SwitcherEnable(SwitcherSelect[0]),
    .SwitcherIn(SwitcherOn_A)
    );
  CalibrationSwitcherControl CalibrationWaveGenB(
    .Clk(Clk),
    .reset_n(reset_n),
    .SyncClock(SyncClock),
    .SwitcherOnTime(SwitcherOnTime),
    .SwitcherEnable(SwitcherSelect[1]),
    .SwitcherIn(SwitcherOn_B)
    );

  // Generate the Sychronise Clock
  reg [15:0] SynchronousCounter;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      SyncClock <= 1'b0;
      SynchronousCounter <= 16'b0;
    end
    else if(SynchronousCounter == SynchronousClockPeroid) begin
      SyncClock <= ~SyncClock;
      SynchronousCounter <= 16'b0;
    end
    else begin
      SyncClock <= SyncClock;
      SynchronousCounter <= SynchronousCounter + 1'b1;
    end
  end
  
  reg [1:0] SyncClockDelay;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      SyncClockDelay <= 2'b0;
    end
    else begin
      SyncClockDelay <= {SyncClockDelay[0], SyncClock};
    end
  end
  BUFG BUFG_SYNCCLOCK (
      .O(SynchronousClock), // 1-bit output: Clock output
      .I(SyncClockDelay[1])  // 1-bit input: Clock input
   );
endmodule
