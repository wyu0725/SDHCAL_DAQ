`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:USTC 
// Engineer: Yu Wang
// 
// Create Date: 2017/04/20 14:42:31
// Design Name: SDHCAL DAQ
// Module Name: SweepACQ
// Project Name: 
// Target Devices: xc7a100tfgg484-2
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


module SweepACQ(
    input Clk,
    input reset_n,
    // ACQ Control
    input SweepStart,
    output SingleACQStart,
    output ACQDone,
    // Sweep ACQ parameters
    input [9:0] StartDAC0,
    input [9:0] StopDAC0,
    input [15:0] MaxPackageNumber,
    // ACQ Data in
    input [15:0] ParallelData,
    input ParallelData_en,
    // Microroc SC Parameters
    output [9:0] OutDAC0,
    //output [9:0] OutDAC1, //Only need to sweep DAC0
    //output [9:0] OutDAC2,
    output [5:0] MaskChannel,
    output LoadSCParameter,
    // Data Output
    output [15:0] SweepACQData,
    output SweepACQData_en
    );
    reg [3:0] State;
    localparam [3:0] IDLE = 4'd0,             //0000
                     HeaderOut = 4'd1,        //0001
                     SCParamOut = 4'd3,       //0011
                     LoadSCParam = 4'd2,      //0010
                     WaitLoadDone = 4'd6,     //0110
                     StartACQ = 4'd7,         //0111
                     WaitOnceData = 4'd5,     //0101
                     GetOnceData = 4'd4,      //0100
                     OutOnceData = 4'd12,     //1100
                     CheckOneDACDone = 4'd13, //1101
                     CheckAllDone = 4'd15,    //1111
                     OutTail = 4'd14,         //1110
                     AllDone = 4'd10;         //1010
    always @(posedge Clk or negedge reset_n) begin
      if(~reset_n) begin
        SingleACQStart <= 1'b0;
        ACQDone <= 1'b0;
        OutDAC0 <= DACInvert(StartDAC0);
      end
    end

    // Swap the LSB and MSB for SC parameter
    function [9:0] DACInvert(input [9:0] num);
      begin
        DACInvert = {num[0], num[1], num[2], num[3], num[4], num[5], num[6], num[7], num[8], num[9]};
      end
    endfunction
endmodule
