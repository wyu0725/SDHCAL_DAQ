`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:USTC 
// Engineer: YuW
// 
// Create Date: 2017/02/27 17:43:10
// Design Name: SCurve Single Input
// Module Name: SCurve_Single_Input
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This module is used to implement S curve test for one trigger. 
// Before the test,the Top level module should give a reset signal to reset
// the logic, then the Teset_start signal is use to start the procedure.
// When started, use the posedge of the CLK_EXT to count the total inject
// number, and use the negedge of the Trigger to count the trig. 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SCurve_Single_Input(
    input Clk,
    input reset_n,
    input Trigger,
    input CLK_EXT,
    input Test_Start,
    input [15:0] CPT_MAX,
    output reg [15:0] CPT_PULSE,
    output reg [15:0] CPT_TRIGGER,
    output reg CPT_DONE
  );
  //sync the CLK_EXT
  reg CLK_EXT_sync;
  always @(posedge Clk or negedge reset_n)begin
    if(~reset_n)
      CLK_EXT_sync <= 1'b0;
    else
      CLK_EXT_sync <= CLK_EXT;
  end
  //Catch the rising edge of CLK_EXT
  reg CLK_EXT_reg1;
  reg CLK_EXT_reg2;
  always @(posedge Clk or negedge reset_n)begin
    if(~reset_n)begin
      CLK_EXT_reg1 <= 1'b0;
      CLK_EXT_reg2 <= 1'b0;
    end
    else begin
      CLK_EXT_reg1 <= CLK_EXT;
      CLK_EXT_reg2 <= CLK_EXT_reg1;
    end
  end
  wire CLK_EXT_rising;
  assign CLK_EXT_rising = CLK_EXT_reg1&(~CLK_EXT_reg2);
  //Catch the falling edge of trigger
  reg trigger_reg1;
  reg trigger_reg2;
  always @(posedge Clk or negedge reset_n)begin
    if(~reset_n)begin
      trigger_reg1 <= 1'b1;
      trigger_reg2 <= 1'b1;
    end
    else begin
      trigger_reg1 <= Trigger;
      trigger_reg2 <= trigger_reg1;
    end
  end
  wire Trigger_Falling;
  assign Trigger_Falling = (~trigger_reg1)&trigger_reg2; 
  //Generate Enable Count signal
  reg Enable_Count_P;
  reg Enable_Count_T;
  always @(posedge Clk or negedge reset_n)begin
    if(~reset_n) begin
      Enable_Count_P <= 1'b0;
      Enable_Count_T <= 1'b0;
    end
    else if(Test_Start)begin
      Enable_Count_P <= 1'b1 & (~CPT_DONE);
      Enable_Count_T <= CLK_EXT_sync & (~CPT_DONE);
    end
    else begin
      Enable_Count_P <= 1'b0;
      Enable_Count_T <= 1'b0;
    end
  end
  //Count PUSLE
  always @(posedge Clk or negedge reset_n)begin
    if(~reset_n)
      CPT_PULSE <= 16'b0;
    else if(~Enable_Count_P)
      CPT_PULSE <= CPT_PULSE;
    else if(CLK_EXT_rising)
      CPT_PULSE <= CPT_PULSE + 1'b1;
    else
      CPT_PULSE <= CPT_PULSE;
  end
  //Count Trigger
  always @(posedge Clk or negedge reset_n)begin
    if(~reset_n)
      CPT_TRIGGER <= 16'b0;
    else if(~Enable_Count_T)
      CPT_TRIGGER <= CPT_TRIGGER;
    else if(Trigger_Falling)
      CPT_TRIGGER <= CPT_TRIGGER + 1'b1;
    else
      CPT_TRIGGER <= CPT_TRIGGER;
  end
  //Generate Count done signal
  //localparam CPT_Total = 16'd60000;
  reg CPT_Full;
  always @(posedge Clk or negedge reset_n)begin
    if(~reset_n)
      CPT_Full <= 1'b0;
    else if(CPT_PULSE >= CPT_MAX)
      CPT_Full <= 1'b1;
    else
      CPT_Full <= 1'b0;
  end
  wire CLK_EXT_sync_n = ~CLK_EXT_sync;
  always @(posedge CLK_EXT_sync_n or negedge reset_n)begin
    if(~reset_n)
      CPT_DONE <= 1'b0;
    else if(CPT_Full)
      CPT_DONE <= 1'b1;
    else
      CPT_DONE <= 1'b0;
  end
endmodule
