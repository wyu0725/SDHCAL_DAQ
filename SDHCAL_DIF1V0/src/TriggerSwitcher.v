`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/12 17:16:50
// Design Name: 
// Module Name: TriggerSwitcher
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


module TriggerSwitcher(
  input [4:0] TriggerSelect,
  input OutTrigger0b,
  input OutTrigger1b,
  input OutTrigger2b,
  input TriggerExt,
  output Trigger
    );
  always @(*) begin
    case(TriggerSwitcher)
      4'b0000:Trigger = OutTrigger0b;
      4'b0001:Trigger = OutTrigger1b;
      4'b0010:Trigger = OutTrigger2b;
      4'b1000:Trigger = TriggerExt;
    endcase
  end
endmodule
