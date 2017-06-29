`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC 
// Engineer: Yu Wang
// 
// Create Date: 2017/06/16 15:33:55
// Design Name: 
// Module Name: TrigCoincid
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


module TrigCoincid(
    input Clk,
    input reset_n,
    input OUT_TRIG0B,
    input OUT_TRIG1B,
    input OUT_TRIG2B,
    input EXT_TRIGB,
    input [1:0] TrigCoincid,
    output reg TrigOut,
    output TrigAnd,
    output TrigOr,
    output ExternalTriggerSyncOut
    );
    reg InternalTrigger0;
    reg InternalTrigger1;
    reg InternalTrigger2;
    reg TriggerExternal;
    always @(posedge Clk or negedge reset_n) begin
      if(~reset_n) begin
        InternalTrigger0 <= 1'b0;
        InternalTrigger1 <= 1'b0;
        InternalTrigger2 <= 1'b0;
        TriggerExternal <= 1'b0;
      end
      else begin
        InternalTrigger0 <= ~OUT_TRIG0B;
        InternalTrigger1 <= ~OUT_TRIG1B;
        InternalTrigger2 <= ~OUT_TRIG2B;
        TriggerExternal <= EXT_TRIGB;
      end
    end
    always @(*) begin
      case(TrigCoincid)
        2'b00: TrigOut = InternalTrigger0;
        2'b01: TrigOut = InternalTrigger1;
        2'b10: TrigOut = InternalTrigger2;
        2'b11: TrigOut = TriggerExternal;
      endcase
    end
    assign TrigAnd = InternalTrigger0 && InternalTrigger1 && InternalTrigger2;
    assign TrigOr = InternalTrigger0 || InternalTrigger1 || InternalTrigger2;
    assign ExternalTriggerSyncOut = TriggerExternal;
endmodule
