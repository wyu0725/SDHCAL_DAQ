`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Yu Wang
//
// Create Date: 2018/10/22 16:01:37
// Design Name: SDHCAL DIF 1V0
// Module Name: CalibrationSwitcherControl
// Project Name: SDHCAL DIF 1V0
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


module CalibrationSwitcherControl(
  input Clk,
  input reset_n,
  input SyncClock,
  input [15:0] SwitcherOnTime,
  input SwitcherEnable,
  output reg SwitcherIn
  );

  reg [1:0] SyncClock_r;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n)
      SyncClock_r <= 2'b0;
    else
      SyncClock_r <= {SyncClock_r[0], SyncClock};
  end
  wire SyncClockRising = (SyncClock_r == 2'b01);

  reg [15:0] SwitcherCounter;
  reg [1:0] State;
  localparam [1:0]
  IDLE = 2'b00,
  WAIT_START = 2'b01,
  SWITCHER_ON = 2'b10;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      SwitcherIn <= 1'b0;
      SwitcherCounter <= 16'b0;
      State <= IDLE;
    end
    else begin
      case(State)
        IDLE:begin
          if(SwitcherEnable)
            State <= WAIT_START;
          else
            State <= IDLE;
        end
        WAIT_START:begin
          if(SyncClockRising) begin
            SwitcherIn <= 1'b1;
            State <= SWITCHER_ON;
          end
          else begin
            State <= WAIT_START;
          end
        end
        SWITCHER_ON:begin
          if(SwitcherCounter <= SwitcherOnTime) begin
            SwitcherCounter <= SwitcherCounter + 1'b1;
            State <= SWITCHER_ON;
          end
          else begin
            SwitcherIn <= 1'b0;
            SwitcherCounter <= 16'b0;
            State <= IDLE;
          end
        end
        default: State <= IDLE;
      endcase
    end
  end
endmodule
