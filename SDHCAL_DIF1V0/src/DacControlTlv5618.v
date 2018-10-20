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
  output reg DacLoadDone,
  output nCS,
  output SCLK,
  output DIN
  );
  
  reg [15:0] SerialData;
  reg DataoutStart;
  wire DataoutDone;
  reg SpiReset_n;
  SpiMaster DacSpiOut(
    .Clk(Clk),
    .reset_n(reset_n & SpiReset_n),
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
  IDLE = 3'd0,
  DATA_GEN = 3'd1,
  OUT_DATA = 3'd2,
  WAIT_DATAOUT_DONE = 3'd3,
  CHECK_DONE = 3'd4,
  DONE = 3'd5;
  
  reg DataLoadCount;
  reg [11:0] DacLoadData;

  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      R1 <= 1'b0;
      R0 <= 1'b0;
      SerialData <= 16'b0;
      DataLoadCount <= 1'b0;
      SpiReset_n <= 1'b0;
      DataoutStart <= 1'b0;
      DacLoadData <= 12'b0;
      DacLoadDone <= 1'b0;
      State <= IDLE;
    end
    else begin
      case(State)
        IDLE:begin
          DacLoadDone <= 1'b0;
          if(DacLoadStart && LoadDacSelect == DAC1) begin
            State <= DATA_GEN;
            R1 = 1'b1;
            R0 = 1'b0;
            DacLoadData <= Dac1Data;
            DataLoadCount = 1'b1;
          end
          else if(DacLoadStart && LoadDacSelect == DAC2) begin
            State <= DATA_GEN;
            R1 = 1'b0;
            R0 = 1'b0;
            DacLoadData <= Dac2Data;
            DataLoadCount = 1'b1;
          end
          else if(DacLoadStart && LoadDacSelect == DAC12) begin
            State <= DATA_GEN;
            R1 = 1'b0;
            R0 = 1'b1;
            DacLoadData <= Dac2Data;
            DataLoadCount = 1'b0;
          end
          else
            State <= IDLE;
        end
        DATA_GEN:begin
          SerialData  <= {R1, SPD, PWR, R0, DacLoadData};
          SpiReset_n <= 1'b1;
          State <= OUT_DATA;
        end
        OUT_DATA:begin
          DataoutStart <= 1'b1;
          State <= WAIT_DATAOUT_DONE;
        end
        WAIT_DATAOUT_DONE:begin
          DataoutStart <= 1'b0;
          if(DataoutDone) begin
            State <= CHECK_DONE;
          end
          else begin
            State <= WAIT_DATAOUT_DONE;
          end
        end
        CHECK_DONE:begin
          SpiReset_n <= 1'b0;
          if(DataLoadCount == 1'b1) begin
            State <= DONE;
          end
          else begin
            R1 <= 1;
            R0 <= 0;
            DacLoadData <= Dac1Data;
            DataLoadCount <= 1'b1;
            State <= DATA_GEN;
          end
        end
        DONE:begin
          SpiReset_n <= 1'b1;
          DacLoadDone <= 1'b1;
          State <= IDLE;
        end
      endcase
    end
  end
endmodule
