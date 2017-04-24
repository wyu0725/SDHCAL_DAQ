`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/04/24 08:46:41
// Design Name: 
// Module Name: ChnMaskCTestReadregGen
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


module ChnMaskCTestReadregGen(
    input reset_n,
    input [5:0] ChannelMask,
    input [2:0] DiscriMask,
    input Mask_or_Unmask,
    output [191:0] OutMicrorocChnDiscriMask,
    input [6:0] CTestChannel,
    output [63:0] OutMicrorocCTestChannel,
    input [6:0] ReadRegister,
    output [63:0] OutMicrorocReadRegister
    );
    localparam MASK = 1'b0;
    localparam UNMASK = 1'b1;
    wire [191:0] MaskParam;
    assign MaskParam = {189'b0,DiscriMask};
    wire [191:0] UnMaskParam;
    assign UnMaskParam = {189'b1,DiscriMask};
    wire [63:0] CTest;
    assign CTest = {63'b0,1'b1};
    wire [63:0] ReadReg;
    assign ReadReg = {63'b0,1'b1};
    always @(*) begin
      if(~reset_n)
        OutMicrorocChnDiscriMask = 192'b0;
      else begin
        case(Mask_or_Unask):
          MASK:begin
            OutMicrorocChnDiscriMask = OutMicrorocChnDiscriMask | (MaskParam << (ChannelMask*3));
          end
        endcase
      end
    end
endmodule
