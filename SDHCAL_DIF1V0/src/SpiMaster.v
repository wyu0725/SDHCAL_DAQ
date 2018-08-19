`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/14 15:45:17
// Design Name: 
// Module Name: SpiMaster
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


module SpiMaster(
  input Clk,
  input reset_n,
  input [15:0] SerialData,
  input DataoutStart,
  output reg DataoutDone,
  output reg SCLK,
  output reg SDI,
  output reg nCS
    );

  reg [15:0] SerialDataShift;
  reg [1:0] State;
  localparam [1:0]
  IDLE = 2'd0,
  GET_DATA = 2'd1,
  DATA_OUT = 2'd2,
  DONE = 2'd3;

  reg [4:0] DataoutCount;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      State <= IDLE;
      DataoutDone <= 1'b0;
      DataoutCount <= 5'b0;
      nCS <= 1'b1;
      SCLK <= 1'b1;
      SDI <= 1'b0;
      SerialDataShift <= 16'b0;
    end
    else begin
      case(State)
        IDLE:begin
          DataoutDone <= 1'b0;
          if(DataoutStart) begin
            State <= GET_DATA;
            nCS <= 1'b0;
            SerialDataShift <= SerialData;
          end
          else begin
            State <= IDLE;
            SerialDataShift <= 16'b0;
          end
        end
        GET_DATA:begin
          if(DataoutCount < 5'd16) begin
            SCLK <= 1'b1;
            SDI <= SerialDataShift[15];
            State <= DATA_OUT;
          end
          else begin
            SCLK <= 1'b1;
            SDI <= 1'b0;
            State <= DONE;
          end
        end
        DATA_OUT:begin
          SCLK <= 1'b0;
          SerialDataShift <= SerialDataShift << 1;
          State <= GET_DATA;
          DataoutCount <= DataoutCount + 1'b1;
        end
        DONE:begin
          nCS <= 1'b1;
          DataoutDone <= 1'b1;
          State <= IDLE;
        end
      endcase
    end
  end
endmodule
