`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:USTC 
// Engineer: Yu W
// 
// Create Date: 2017/02/28 17:36:20
// Design Name: 
// Module Name: SCurve_Single_Channel
// Project Name: SDHCAL_DAQ2V0_SCurveTest
// Target Devices: XC7A100TFGG484-2L
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


module SCurve_Single_Channel(
    input Clk,
    input reset_n,
    input CLK_EXT,
    input out_trigger0b,
    input out_trigger1b,
    input out_trigger2b,
    input SCurve_Test_Start,
    input [15:0] CPT_MAX,

    output reg [15:0] SCurve_Data,
    output reg SCurve_Data_wr_en,
    output reg One_Channel_Done
    );
    //instantiation the Single input S Curve test
    reg out_reset_n;
    reg Single_Chn_Test_Start;
    wire [15:0] CPT_PULSE_trigger0;
    wire [15:0] CPT_TRIGGER0;
    wire [15:0] CPT_PULSE_trigger1;
    wire [15:0] CPT_TRIGGER1;
    wire [15:0] CPT_PULSE_trigger2;
    wire [15:0] CPT_TRIGGER2;
    wire CPT_DONE_trigger0;
    wire CPT_DONE_trigger1;
    wire CPT_DONE_trigger2;    
    SCurve_Single_Input Trigger0(
      .Clk(Clk),
      .reset_n(out_reset_n),
      .Trigger(out_trigger0b),
      .CLK_EXT(CLK_EXT),
      .Test_Start(Single_Chn_Test_Start),
      .CPT_MAX(CPT_MAX),
      .CPT_PULSE(CPT_PULSE_trigger0),
      .CPT_TRIGGER(CPT_TRIGGER0),
      .CPT_DONE(CPT_DONE_trigger0)
    );
    SCurve_Single_Input Trigger1(
      .Clk(Clk),
      .reset_n(out_reset_n),
      .Trigger(out_trigger1b),
      .CLK_EXT(CLK_EXT),
      .Test_Start(Single_Chn_Test_Start),
      .CPT_MAX(CPT_MAX),
      .CPT_PULSE(CPT_PULSE_trigger1),
      .CPT_TRIGGER(CPT_TRIGGER1),
      .CPT_DONE(CPT_DONE_trigger1)
    );
    SCurve_Single_Input Trigger2(
      .Clk(Clk),
      .reset_n(out_reset_n),
      .Trigger(out_trigger2b),
      .CLK_EXT(CLK_EXT),
      .Test_Start(Single_Chn_Test_Start),
      .CPT_MAX(CPT_MAX),
      .CPT_PULSE(CPT_PULSE_trigger2),
      .CPT_TRIGGER(CPT_TRIGGER2),
      .CPT_DONE(CPT_DONE_trigger2)
    );
    //State machine of the test
    reg [2:0] TEST_State;
    localparam [2:0] IDLE = 3'd0,
                     TEST_START = 3'd1,
                     TEST_PROCESS = 3'd2,
                     TEST_DONE = 3'd3,
                     DATA_OUT = 3'd4,
                     DATA_OUT_ONCE = 3'd5,
                     ALL_DONE = 3'd6;
    reg [96:0] CPT_DATA;
    reg [2:0] data_out_cnt;
    wire CPT_All_Done;
    assign CPT_All_Done = CPT_DONE_trigger0 & CPT_DONE_trigger1 & CPT_DONE_trigger2;
    always @ (posedge Clk or negedge reset_n)begin
      if(~reset_n)begin
        out_reset_n <= 1'b0;
        CPT_DATA <= 96'd0;
        Single_Chn_Test_Start <= 1'b0;
        SCurve_Data <= 16'd0;
        SCurve_Data_wr_en <= 1'b0;
        One_Channel_Done <= 1'b0;
        data_out_cnt <= 3'b0;
        TEST_State <= IDLE;
      end
      else begin
        case(TEST_State)
          IDLE:if(~SCurve_Test_Start)begin
            TEST_State <= IDLE;
            out_reset_n <= 1'b0;
            CPT_DATA <= 96'd0;
            One_Channel_Done <= 1'b0;
            Single_Chn_Test_Start <= 1'b0;
          end
          else begin
            out_reset_n <= 1'b1; 
            One_Channel_Done <= 1'b0;
            TEST_State <= TEST_START;
          end
          TEST_START:begin
            Single_Chn_Test_Start <= 1'b1;
            TEST_State <= TEST_PROCESS;
          end
          TEST_PROCESS:begin
            if(CPT_All_Done)begin
              Single_Chn_Test_Start <= 1'b1;
              TEST_State <= TEST_DONE;
            end
            else 
              TEST_State <= TEST_PROCESS;
          end
          TEST_DONE:begin
            CPT_DATA <= {CPT_PULSE_trigger0,CPT_TRIGGER0,CPT_PULSE_trigger1,CPT_TRIGGER1,CPT_PULSE_trigger2,CPT_TRIGGER2};
            Single_Chn_Test_Start <= 1'b0;
            TEST_State <= DATA_OUT;
          end
          DATA_OUT:begin
            if(data_out_cnt <= 3'd5) begin
              data_out_cnt <= data_out_cnt + 1'b1;
              SCurve_Data <= CPT_DATA[95:80];
              SCurve_Data_wr_en <= 1'b0;
              TEST_State <= DATA_OUT_ONCE;
            end
            else begin
              SCurve_Data_wr_en <= 1'b0;
              data_out_cnt <= 3'b0;
              TEST_State <= ALL_DONE;
            end
          end
          DATA_OUT_ONCE:begin
            SCurve_Data_wr_en <= 1'b1;
            CPT_DATA <= CPT_DATA << 16;
            TEST_State <= DATA_OUT;
          end
          ALL_DONE:begin
            One_Channel_Done <= 1'b1;
            out_reset_n <= 1'b0;
            TEST_State <= IDLE;
          end
        endcase
      end
    end
endmodule
