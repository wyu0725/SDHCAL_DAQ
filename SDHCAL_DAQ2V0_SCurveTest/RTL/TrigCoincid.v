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
    input OUT_TRIG0B,
    input OUT_TRIG1B,
    input OUT_TRIG2B,
    input EXT_TRIGB,
    input [1:0] TrigCoincid,
    output reg TrigOut
    );
    always @(*) begin
      case(TrigCoincid)
        2'b00: TrigOut = ~OUT_TRIG0B;
        2'b01: TrigOut = ~OUT_TRIG1B;
        2'b10: TrigOut = ~OUT_TRIG2B;
        2'b11: TrigOut = EXT_TRIGB;
      endcase
    end
endmodule
