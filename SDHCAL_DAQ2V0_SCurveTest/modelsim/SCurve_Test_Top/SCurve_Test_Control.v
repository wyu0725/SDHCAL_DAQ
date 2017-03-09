`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:USTC 
// Engineer: Yu W
// 
// Create Date: 2017/03/01 18:29:33
// Design Name: SDHCAL_DAQ2V0_SCurve_Test
// Module Name: SCurve_Test_Control
// Project Name: 
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


module SCurve_Test_Control(
    input Clk,
    input reset_n,
    input Test_Start,
    /*--- Lower-Level module:SCurve Single Channel Interface ---*/
    output reg Single_Test_Start,
    input Single_Test_Done,
    input SCurve_Data_fifo_empty,
    input [15:0] SCurve_Data_fifo_din,
    output reg SCurve_Data_fifo_rd_en,
    /*--- Test Parameter Interface ---*/
    input Single_or_64Chn,//High:Single Channel test, Low:64 Channel test through Ctest pin
    input [5:0] SingleTest_Chn,
    /*--- Microroc SC Parameter Interface ---*/  
    output reg [63:0] Microroc_CTest_Chn_Out,
    output reg [9:0] Microroc_10bit_DAC_Out,
    output reg SC_Param_Load,
    input Microroc_Config_Done,
    /*--- USB Data FIFO Interface ---*/
    output reg [15:0] usb_data_fifo_wr_din,
    output reg usb_data_fifo_wr_en,
    /*--- Done Indicator ---*/
    output reg SCurve_Test_Done
    );
    reg [3:0] State;
    localparam [3:0] IDLE = 4'd0,
                     HEADER_OUT = 4'd1,
                     OUT_TEST_CHN_SC = 4'd2,
                     OUT_TEST_CHN_USB = 4'd3,
                     OUT_DAC_CODE_SC = 4'd4,
                     OUT_DAC_CODE_USB = 4'd5,
                     LOAD_SC_PARAM = 4'd6,
                     WAIT_LOAD_SC_PARAM_DONE = 4'd7,
                     START_SCURVE_TEST = 4'd8,
                     PROCESS_SCURVE_TEST = 4'd9,
                     WAIT_TRIGGER_DATA = 4'd10,
                     GET_TRIGGER_DATA = 4'd11,
                     OUT_TRIGGER_DATA = 4'd12,
                     CHECK_CHN_DONE = 4'd13,
                     CHECK_ALL_DONE = 4'd14,
                     ALL_DONE = 4'd15;
  localparam [15:0] SCURVE_TEST_HEADER = 16'h5343;//In ASCII 53 = S,43 = C.0x5343 stands for SC
  localparam [63:0] SINGLE_CHN_PARAM = 64'h0;
  reg [63:0] All_Chn_Param;
  reg [5:0] Test_Chn;
  reg [9:0] Actual_10bit_DAC_Code;//In SC param the LSB of 10bit DAC code come first, so it's necessary to invert the code
  always @(posedge Clk or negedge reset_n)begin
    if(~reset_n)begin
      All_Chn_Param <= 64'h0000_0000_0000_0001;
      Test_Chn <= 6'b0;
      SCurve_Data_fifo_rd_en <= 1'b0;
      Single_Test_Start <= 1'b0;
      Microroc_CTest_Chn_Out <= 64'd0;
      usb_data_fifo_wr_din <= 16'd0;
      usb_data_fifo_wr_en <= 1'b0;
      Actual_10bit_DAC_Code <= 10'b0;
      Microroc_10bit_DAC_Out <= 10'b0;
      SC_Param_Load <= 1'b0;
      SCurve_Test_Done <= 1'b0;
      State <= IDLE;
    end
    else begin
      case(State)
        IDLE:begin
          if(~Test_Start)begin
            All_Chn_Param <= 64'h0000_0000_0000_0001;
            Test_Chn <= 6'b0;
            SCurve_Data_fifo_rd_en <= 1'b0;
            Single_Test_Start <= 1'b0;
            Microroc_CTest_Chn_Out <= 64'd0;
            usb_data_fifo_wr_din <= 16'd0;
            usb_data_fifo_wr_en <= 1'b0;
            Microroc_10bit_DAC_Out <= 10'b0;
            SC_Param_Load <= 1'b0;
            //SCurve_Test_Done <= 1'b0;
            State <= IDLE;
          end
          else begin
            SCurve_Test_Done <= 1'b0;
            usb_data_fifo_wr_din <= SCURVE_TEST_HEADER;
            State <= HEADER_OUT;
          end
        end
        HEADER_OUT:begin
          usb_data_fifo_wr_en <= 1'b1;
          State <= OUT_TEST_CHN_SC;
        end
        OUT_TEST_CHN_SC:begin
          usb_data_fifo_wr_en <= 1'b0;
          if(Single_or_64Chn)begin //Single Channel test, charge inject from input pin 
            Microroc_CTest_Chn_Out <= SINGLE_CHN_PARAM;
            usb_data_fifo_wr_din <= {8'h63,2'b00,SingleTest_Chn}; 
            State <= OUT_TEST_CHN_USB;
          end
          else begin//64 Channel test, charge inject from CTest pin
            Microroc_CTest_Chn_Out <= All_Chn_Param;
            usb_data_fifo_wr_din <= {8'h43,2'b00,Test_Chn};
            State <= OUT_TEST_CHN_USB;            
          end
        end
        OUT_TEST_CHN_USB:begin
          usb_data_fifo_wr_en <= 1'b1;
          State <= OUT_DAC_CODE_SC;
        end
        OUT_DAC_CODE_SC:begin
          usb_data_fifo_wr_en <= 1'b0;
          Microroc_10bit_DAC_Out <= Invert(Actual_10bit_DAC_Code);
          usb_data_fifo_wr_din <= {4'hD,2'b00,Actual_10bit_DAC_Code};
          State <= OUT_DAC_CODE_USB;
        end
        OUT_DAC_CODE_USB:begin
          usb_data_fifo_wr_en <= 1'b1;
          State <= LOAD_SC_PARAM;
        end
        LOAD_SC_PARAM:begin
          usb_data_fifo_wr_en <= 1'b0;
          SC_Param_Load <= 1'b1;
          State <= WAIT_LOAD_SC_PARAM_DONE;
        end
        WAIT_LOAD_SC_PARAM_DONE:begin
          SC_Param_Load <= 1'b0;
          if(Microroc_Config_Done)
            State <= START_SCURVE_TEST;
          else
            State <= WAIT_LOAD_SC_PARAM_DONE;
        end
        START_SCURVE_TEST:begin
          Single_Test_Start <= 1'b1;
          State <= PROCESS_SCURVE_TEST;
        end
        PROCESS_SCURVE_TEST:begin
          Single_Test_Start <= 1'b0;
          if(Single_Test_Done)
            State <= WAIT_TRIGGER_DATA;
          else
            State <= PROCESS_SCURVE_TEST;
        end
        WAIT_TRIGGER_DATA:begin
          usb_data_fifo_wr_en <= 1'b0;
          if(SCurve_Data_fifo_empty)
            State <= CHECK_CHN_DONE;
          else begin
            SCurve_Data_fifo_rd_en <= 1'b1;
            State <= GET_TRIGGER_DATA;
          end
        end
        GET_TRIGGER_DATA:begin
          SCurve_Data_fifo_rd_en <= 1'b0;
          usb_data_fifo_wr_din <= SCurve_Data_fifo_din;
          State <= OUT_TRIGGER_DATA;
        end
        OUT_TRIGGER_DATA:begin
          usb_data_fifo_wr_en <= 1'b1;
          State <= WAIT_TRIGGER_DATA;
        end
        CHECK_CHN_DONE:begin
          if(Actual_10bit_DAC_Code == 10'd1023)begin
            Actual_10bit_DAC_Code <= 10'b0;
            State <= CHECK_ALL_DONE;
          end
          else begin
            Actual_10bit_DAC_Code <= Actual_10bit_DAC_Code + 1'b1;
            State <= OUT_DAC_CODE_SC;
          end
        end
        CHECK_ALL_DONE:begin
          if(Single_or_64Chn)begin //If single Channel test, only need one Channel data.
            usb_data_fifo_wr_din <= 16'hFF45;
            usb_data_fifo_wr_en <= 1'b1;
            State <= ALL_DONE;
          end
          else if(Test_Chn == 6'd63)begin
            All_Chn_Param <= 64'h0000_0000_0000_0001;
            Test_Chn <= 6'd0;
            usb_data_fifo_wr_din <= 16'hFF45;
            usb_data_fifo_wr_en <= 1'b1;
            State <= ALL_DONE;
          end
          else begin
            All_Chn_Param <= All_Chn_Param << 1'b1;
            Test_Chn <= Test_Chn + 1'b1;
            State <= OUT_TEST_CHN_SC;
          end
        end
        ALL_DONE:begin
          usb_data_fifo_wr_en <= 1'b0;
          SCurve_Test_Done <= 1'b1;
          State <= IDLE;
        end
      endcase
    end
  end
  //Swap the LSB and MSB
  function [9:0] Invert(input [9:0] num);
    begin
      Invert = {num[0], num[1], num[2], num[3], num[4], num[5], num[6], num[7], num[8], num[9]};
    end
  endfunction
endmodule
