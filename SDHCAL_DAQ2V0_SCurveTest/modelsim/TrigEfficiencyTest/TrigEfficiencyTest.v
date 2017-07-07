`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Yu Wang
// 
// Create Date: 2017/07/06 17:20:53
// Design Name: SDHCAL_DAQ2V0
// Module Name: TrigEfficiencyTest
// Project Name: SDHCAL_DAQ2V0
// Target Devices: XC7A100TFGG484-2
// Tool Versions: Vivado 16.3
// Description: This module is used to test the trigger efficiency without
// changing any SC parameter. So that this module can keep the channel and
// discriminator mask as which the software set
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TrigEfficiencyTest(
    input Clk,
    input reset_n,
    input CLK_EXT,
    input OUT_TRIGGER0B,
    input OUT_TRIGGER1B,
    input OUT_TRIGGER2B,
    input Start,
    input [15:0] CPT_MAX,
    input [3:0] TriggerDelay,
    output reg [15:0] TrigEfficiencyData,
    output reg TrigEfficiencyData_en,
    output reg TestDone,
    input DataTransmitDone
    );
    reg ResetSingleTest_n;
    reg SingleTestStart;
    wire [15:0] CPT_PULSE0;
    wire [15:0] CPT_TRIGGER0;
    wire [15:0] CPT_PULSE1;
    wire [15:0] CPT_TRIGGER1;
    wire [15:0] CPT_PULSE2;
    wire [15:0] CPT_TRIGGER2;
    wire Trigger0Done;
    wire Trigger1Done;
    wire Trigger2Done;
    SCurve_Single_Input Trigger0(
      .Clk(Clk),
      .reset_n(ResetSingleTest_n),
      .TrigEffi_or_CountEffi(1'b1),
      .Trigger(OUT_TRIGGER0B),
      .CLK_EXT(CLK_EXT),
      .Test_Start(SingleTestStart),
      .CPT_MAX(CPT_MAX),
      .TriggerDelay(TriggerDelay),
      .CPT_PULSE(CPT_PULSE0),
      .CPT_TRIGGER(CPT_TRIGGER0),
      .CPT_DONE(Trigger0Done)
    );
    SCurve_Single_Input Trigger1(
      .Clk(Clk),
      .reset_n(ResetSingleTest_n),
      .TrigEffi_or_CountEffi(1'b1),
      .Trigger(OUT_TRIGGER1B),
      .CLK_EXT(CLK_EXT),
      .Test_Start(SingleTestStart),
      .CPT_MAX(CPT_MAX),
      .TriggerDelay(TriggerDelay),
      .CPT_PULSE(CPT_PULSE1),
      .CPT_TRIGGER(CPT_TRIGGER1),
      .CPT_DONE(Trigger1Done)
    );
    SCurve_Single_Input Trigger2(
      .Clk(Clk),
      .reset_n(ResetSingleTest_n),
      .TrigEffi_or_CountEffi(1'b1),
      .Trigger(OUT_TRIGGER2B),
      .CLK_EXT(CLK_EXT),
      .Test_Start(SingleTestStart),
      .CPT_MAX(CPT_MAX),
      .TriggerDelay(TriggerDelay),
      .CPT_PULSE(CPT_PULSE2),
      .CPT_TRIGGER(CPT_TRIGGER2),
      .CPT_DONE(Trigger2Done)
    );
    reg [2:0] TestState;
    localparam [2:0] IDLE = 3'd0,
                     OUT_HEADER = 3'd1,
                     TEST_START = 3'd2,
                     TEST_PROCESS = 3'd3,
                     TEST_DONE = 3'd4,
                     DATA_OUT = 3'd5,
                     DATA_OUT_ONCE = 3'd6,
                     ALL_DONE = 3'd7;
    reg [95:0] CPT_DATA;
    reg [2:0] DataOutCount;
    wire TriggerAllDone;
    assign TriggerAllDone = Trigger0Done && Trigger1Done && Trigger2Done;
    always @(posedge Clk or negedge reset_n) begin
      if(~reset_n) begin
        ResetSingleTest_n <= 1'b0;
        CPT_DATA <= 96'd0;
        SingleTestStart <= 1'b0;
        TrigEfficiencyData <= 16'b0;
        TrigEfficiencyData_en <= 1'b0;
        TestDone <= 1'b0;
        TestState <= IDLE;
      end
      else begin
        case(TestState)
	        IDLE:begin
	          if(~Start) begin
	            ResetSingleTest_n <= 1'b0;
	            CPT_DATA <= 96'd0;
	            SingleTestStart <= 1'b0;
	            TrigEfficiencyData <= 16'b0;
	            TrigEfficiencyData_en <= 1'b0;
	            TestDone <= 1'b0;
	            DataOutCount <= 3'd0;
	            TestState <= IDLE;
	          end
	          else begin
	            ResetSingleTest_n <= 1'b1;
	            TestDone <= 1'b0;
	            TrigEfficiencyData <= 16'h4343;
	            TestState <= OUT_HEADER;
	          end
	        end
	        OUT_HEADER:begin
	          if(DataOutCount < 3'd1) begin
	            TrigEfficiencyData_en <= 1'b1;
	            TestState <= OUT_HEADER;
	            DataOutCount <= DataOutCount + 1'b1;
	          end
	          else begin
	            TrigEfficiencyData_en <= 1'b0;
	            DataOutCount <= 3'b0;
	            TestState <= TEST_START;
	          end
	        end
	        TEST_START:begin
	          SingleTestStart <= 1'b1;
	          TestState <= TEST_PROCESS;
	        end
	        TEST_PROCESS:begin
	          if(TriggerAllDone) begin
	            SingleTestStart <= 1'b0;
	            TestState <= TEST_DONE;
	          end
	          else begin
	            TestState <= TEST_PROCESS;
	          end
	        end
	        TEST_DONE:begin
	          CPT_DATA <= {CPT_PULSE0, CPT_TRIGGER0, CPT_PULSE1, CPT_TRIGGER1, CPT_PULSE2, CPT_TRIGGER2};
	          TestState <= DATA_OUT;
	        end
	        DATA_OUT:begin
            TrigEfficiencyData_en <= 1'b0;
	          if(DataOutCount <= 3'd5) begin
	            DataOutCount <= DataOutCount + 1'b1;
	            TrigEfficiencyData <= CPT_DATA[95:80];
	            TestState <= DATA_OUT_ONCE;
	          end
	          else begin
	            DataOutCount <= 3'd0;
	            TestDone <= 1'b1;
	            TestState <= ALL_DONE;
	          end
	        end
          DATA_OUT_ONCE:begin
            TrigEfficiencyData_en <= 1'b1;
            CPT_DATA <= CPT_DATA << 16;
            TestState <= DATA_OUT;
          end
	        ALL_DONE:begin
	          if(DataTransmitDone) begin
	            TestDone <= 1'b0;
	            TestState <= IDLE;
	          end
	          else
	            TestState <= ALL_DONE;
	        end
        endcase
      end
    end
endmodule
