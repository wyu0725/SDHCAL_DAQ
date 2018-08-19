`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Yu Wang
//
// Create Date: 2018/08/14 11:20:10
// Design Name: SDHCAL DIF 1V0
// Module Name: DacControlTlv5618
// Project Name: SDHCAL DIF 1V0
// Target Devices: XC7A100TFGG484-2l
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


module DacControlTlv5618(
  input Clk,
  input reset_n,
  input PowerDown,// 1 -> power down, 0 -> normal mode
  input Speed,  // 1 -> fast mode, 0 -> slow mode
  input [11:0] Dac1Data,
  input [11:0] Dac2Data,
  input [1:0] LoadDacSelect,
  input DacLoadStart,
  output nCS,
  output SCLK,
  output DIN
  );
  
  reg [15:0] SerialData;
  wire DataoutStart;
  wire DataoutDone;
  SpiMaster DacSpiOut(
    .Clk(Clk),
    .reset_n(reset_n),
    .SerialData(SerialData),
    .DataoutStart(DataoutStart),
    .DataoutDone(DataoutDone),
    .SCLK(SCLK),
    .SDI(DIN),
    .nCS(nCS)
    );

  reg R1;
  reg R0;
  wire SPD;
  wire PWR;
  assign SPD = Speed;
  assign PWR = PowerDown;

  localparam [1:0] 
  DAC1 = 2'b01,
  DAC2 = 2'b10,
  DAC12 = 2'b11;
  
  reg [2:0] State;
  localparam [2:0]
  IDLE = 2'd0,
  DATA_GEN = 2'd1,
  OUT_DATA = 2'd2,
  WAIT_OUT_DONE = 2'd3,
  DATA_GEN_DAC12 = 2'd4,
  DONE = 2'd5;
  
  reg DataLoadCount;

  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      R1 <= 1'b0;
      R0 <= 1'b0;
      SerialData <= 16'b0;
      DataLoadCount <= 1'b0;
      State <= IDLE;
    end
    else begin
      case(State)
        IDLE:begin
          if(DacLoadStart && LoadDacSelect == DAC1) begin
            State <= DATA_GEN;
            R1 = 1'b1;
            R0 = 1'b0;
            DataLoadCount = 1'b1;
          end
          else if(DacLoadStart && LoadDacSelect == DAC2) begin
            State <= DATA_GEN;
            R1 = 1'b0;
            R2 = 1'b0;
            DataLoadCount = 1'b1;
          end
          else if(DacLoadStart && LoadDacSelect == DAC12) begin
            State <= DATA_GEN;
            R1 = 1'b0;
            R0 = 1'b1;
            DataLoadCount = 1'b0;
          end
          else
            State <= IDLE;
        end
        DATA_GEN:begin
          SerialData  <= {R1, SPD, PWR, R2, Dac1Data};
          State <= DATA_OUT;
        end
        DATA_OUT:
      endcase
    end
  end
endmodule
