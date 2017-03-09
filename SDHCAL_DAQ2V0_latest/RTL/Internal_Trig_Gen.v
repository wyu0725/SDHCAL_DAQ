`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/12 20:46:30
// Design Name: 
// Module Name: Internal_Trig_Gen
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


module Internal_Trig_Gen(
  input Clk,
  input reset_n,
  input start_acq,
  input Trig_en,
  output reg trig_en_i
);
always @ (posedge Clk, negedge reset_n)begin
  if(~reset_n)
    trig_en_i <= 1'b0;
  else if(Trig_en && start_acq == 1'b1 && trig_en_i == 1'b0)
    trig_en_i <= 1'b1;
  else 
    trig_en_i <= 1'b0;
end
endmodule
