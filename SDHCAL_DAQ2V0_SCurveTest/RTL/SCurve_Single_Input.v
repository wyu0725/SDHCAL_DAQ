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
    input TrigEffi_or_CountEffi,
    input Trigger,
    input CLK_EXT,
    input Test_Start,
    input [15:0] CPT_MAX,
    output reg [15:0] CPT_PULSE,
    output reg [15:0] CPT_TRIGGER,
    output reg CPT_DONE
  );
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
  wire CLK_EXT_falling;
  assign CLK_EXT_falling = (~CLK_EXT_reg1)&CLK_EXT_reg2;
  //Catch the falling edge of trigger
  reg trigger_reg1;
  reg trigger_reg2;
  always @(posedge Clk or negedge reset_n)begin
    if(~reset_n)begin
      trigger_reg1 <= 1'b1;
      trigger_reg2 <= 1'b1;
    end
    else begin
      trigger_reg1 <= TrigEffi_or_CountEffi ? ((Trigger && trigger_reg1) || (~Enable_Count_T)) : Trigger;
      trigger_reg2 <= trigger_reg1;
    end
  end
  wire Trigger_Falling;
  assign Trigger_Falling = (~trigger_reg1)&trigger_reg2; 
  //Generate Enable Count signal
  wire Enable_Count_P;
  wire Enable_Count_T;
  assign Enable_Count_P = Test_Start & (reset_n) & (~CPT_DONE);
  assign Enable_Count_T = TrigEffi_or_CountEffi ? (Enable_Count_P & CLK_EXT) : Enable_Count_P;
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
  // When the CPT_PULSE is full (CPT_Full is enable), the Enable_Count_T
  // signal should not disable. Because at the rising edge, CPT_Full is
  // enbale, at the same time there could come a trigger.
  /*------  这种方式会报一个错误，CLE_EXT不是从专用时钟管脚输入的------*/
  /*wire CLK_EXT_n = ~CLK_EXT;
  always @(posedge CLK_EXT_n or negedge reset_n)begin
    if(~reset_n)
      CPT_DONE <= 1'b0;
    else if(CPT_Full)
      CPT_DONE <= 1'b1;
    else
      CPT_DONE <= 1'b0;
  end*/
 always @(posedge Clk or negedge reset_n) begin
  if(~reset_n) begin
    CPT_DONE <= 1'b0;
  end
  else if(CLK_EXT_falling & CPT_Full)
    CPT_DONE <= 1'b1;
  else
    CPT_DONE <= 1'b0;
 end
endmodule
