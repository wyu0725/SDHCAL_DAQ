`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC 
// Engineer: Yu Wang
// 
// Create Date: 2017/06/16 15:44:02
// Design Name: 
// Module Name: HoldGen
// Project Name: SDHCAL DAQ
// Target Devices: XC7A100TFGG484-2
// Tool Versions: Vivado 16.3
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module HoldGen(
    input Clk,
    input Clk_320M,
    input reset_n,
    input TrigIn,
    input Hold_en,
    input [7:0] HoldDelay,
    input [15:0] HoldTime,
    output HoldOut
    );
    //reg [7:0] HoldDelayCount;
    reg [255:0] TrigShift;
    always @(posedge Clk_320M or negedge reset_n) begin
      if(~reset_n) begin
        //HoldDelayCount <= 8'b0;
        TrigShift <= 256'b0;
      end
      else begin
        TrigShift <= {TrigShift[254:0],TrigIn};
      end
    end
    wire TrigDelayed = TrigShift[HoldDelay];
    reg ResetHold;
    reg [15:0] HoldTimeCount;
    always @(posedge Clk or negedge reset_n) begin
      if(~reset_n) begin
        ResetHold <= 1'b1;
        HoldTimeCount <= 16'b0;
      end
      else if(HoldTimeCount == HoldTime) begin
        HoldTimeCount <= 16'b0;
        ResetHold <= 1'b1;
      end
      else if((HoldTimeCount < HoldTime) && (HoldOut || HoldTimeCount != 0)) begin
        ResetHold <= 1'b0;
        HoldTimeCount <= HoldTimeCount + 1'b1;
      end
      else begin
        ResetHold <= 1'b0;
        HoldTimeCount <= 16'b0;
      end
    end
    assign HoldOut = Hold_en && (HoldOut || TrigDelayed) && (~ResetHold);
    /*reg TrigIn1;
    reg TrigIn2;
    always @(posedge Clk_320M or negedge reset_n) begin
      if(~reset_n) begin
        TrigIn1 <= 1'b0;
        TrigIn2 <= 1'b0;
      end
      else begin
        TrigIn1 <= TrigIn & Hold_en;
        TrigIn2 <= TrigIn2 & Hold_en;
      end
    end
    wire TrigInRise;
    assign TrigIn1 & (~TrigIn2);
    // Generate the delayed hold signal
    reg TrigDelayed;
    reg [1:0] State;
    localparam [1:0] IDLE = 2'b00,
                     DELAY = 2'b01,
                     HOLD_GEN=2'b10;
    always @(posedge Clk_320M or negedge reset_n) begin
      if(~reset_n) begin
        HoldDelayCount <= 8'b0;
        TrigDelayed <= 1'b0;
      end
      else begin
        case(State)
          IDLE:begin
            if(TrigInRise)
              State <= DELAY;
            else
              State <= Idle;
          end
          DELAY:begin
            if(TrigDelayCount < TrigDelay) begin
              TrigDelayCount <= TrigDelayCount + 1'b1;
              TrigDelayed <= 1'b0;
              State <= DELAY;
            end
            else begin
              TrigDelayCount <= 8'b0;
              TrigDelayed <= 1'b1;
              State <= HOLD_GEN;
            end
          end
          HOLD_GEN:begin
            TrigDelayed <= 1'b0;
            State <= IDLE;
          end
          default:State <= IDLE;
        endcase
      end
    end*/    
endmodule
