`timescale 1ns / 1ps
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
    input Ctest_or_Input,//Add by wyu 20170307. When single channel test, this parameter can choose the charge inject from Ctest pin or the input pin
    /*--- Microroc SC Parameter Interface ---*/  
    output reg [63:0] Microroc_CTest_Chn_Out,
    output reg [9:0] Microroc_10bit_DAC_Out,
    output reg [191:0] Microroc_Discriminator_Mask,
    output reg Force_Ext_RAZ,
    output reg SC_Param_Load,
    input Microroc_Config_Done,
    /*--- USB Data FIFO Interface ---*/
    //input usb_data_fifo_full,
    output reg [15:0] usb_data_fifo_wr_din,
    output reg usb_data_fifo_wr_en,
    input usb_data_fifo_full,
    /*--- Done Indicator ---*/
    output reg SCurve_Test_Done,
    input Data_Transmit_Done
    );
    reg [4:0] State;
    localparam [4:0] IDLE = 5'd0,
                     HEADER_OUT = 5'd1,
                     OUT_TEST_CHN_AND_DISCRI_MASK_SC = 5'd2,
                     OUT_TEST_CHN_USB = 5'd3,
                     OUT_DAC_CODE_SC = 5'd4,
                     OUT_DAC_CODE_USB = 5'd5,
                     LOAD_SC_PARAM = 5'd6,
                     WAIT_LOAD_SC_PARAM_DONE = 5'd7,
                     START_SCURVE_TEST = 5'd8,
                     PROCESS_SCURVE_TEST = 5'd9,
                     WAIT_TRIGGER_DATA = 5'd10,
                     GET_TRIGGER_DATA = 5'd11,
                     OUT_TRIGGER_DATA = 5'd12,
                     CHECK_CHN_DONE = 5'd13,
                     CHECK_ALL_DONE = 5'd14,
                     TAIL_OUT = 5'd15,
                     WAIT_TAIL_WRITE = 5'd16,
                     WAIT_DONE = 5'd17,
                     ALL_DONE = 5'd18;
  localparam [15:0] SCURVE_TEST_HEADER = 16'h5343;//In ASCII 53 = S,43 = C.0x5343 stands for SC
  localparam [63:0] SINGLE_CHN_PARAM_Ctest = 64'h0000_0000_0000_0001;
  localparam [63:0] CTest_CHN_PARAM_Input = 64'h0;
  localparam [191:0] DISCRIMINATOR_MASK = {189'b0, 3'b111};
  reg [8:0] Discri_Mask_Shift;
  reg [191:0] All_Chn_Discri_Mask;
  reg [63:0] All_Chn_Param;
  reg [5:0] Test_Chn;
  reg [9:0] Actual_10bit_DAC_Code;//In SC param the LSB of 10bit DAC code come first, so it's necessary to invert the code
  reg [15:0] SC_Param_Load_Cnt;
  localparam [15:0] SC_PARAM_LOAD_DELAY = 16'd40_000;
  reg [3:0] Wait_Tail_Cnt;
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
      Discri_Mask_Shift <= 8'b0;
      All_Chn_Discri_Mask <= {189'b0, 3'b111};
      Microroc_Discriminator_Mask <= {192{1'b1}};
      SC_Param_Load_Cnt <= 16'b0;
      Wait_Tail_Cnt <= 4'b0;
      Force_Ext_RAZ <= 1'b0;
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
            SCurve_Test_Done <= 1'b0;
            All_Chn_Discri_Mask <= {189'b0, 3'b111};
            Microroc_Discriminator_Mask <= {192{1'b1}};
            SC_Param_Load_Cnt <= 16'b0;
            Wait_Tail_Cnt <= 4'b0;
            State <= IDLE;
          end
          else begin
            SCurve_Test_Done <= 1'b0;
            usb_data_fifo_wr_din <= SCURVE_TEST_HEADER;
            Discri_Mask_Shift <= SingleTest_Chn + SingleTest_Chn + SingleTest_Chn;
            State <= HEADER_OUT;
          end
        end
        HEADER_OUT:begin
          usb_data_fifo_wr_en <= 1'b1;
          State <= OUT_TEST_CHN_AND_DISCRI_MASK_SC;
        end
        OUT_TEST_CHN_AND_DISCRI_MASK_SC:begin
          usb_data_fifo_wr_en <= 1'b0;
          if(Single_or_64Chn) begin //Select single channel test and the charge is injected from CTest pin
            Microroc_CTest_Chn_Out <= Ctest_or_Input ? (SINGLE_CHN_PARAM_Ctest << SingleTest_Chn) : CTest_CHN_PARAM_Input;
            usb_data_fifo_wr_din <= {8'h43, 2'b00, SingleTest_Chn};//0x43 in ascii is C   
            Microroc_Discriminator_Mask <= (DISCRIMINATOR_MASK << Discri_Mask_Shift);
            State <= OUT_TEST_CHN_USB;
          end
          else begin
            Microroc_CTest_Chn_Out <= Ctest_or_Input ? All_Chn_Param : CTest_CHN_PARAM_Input;
            usb_data_fifo_wr_din <= {8'h63, 2'b00, Test_Chn};//0x63 in ascii is c, meaning channel
            Microroc_Discriminator_Mask <= All_Chn_Discri_Mask;
            State <= OUT_TEST_CHN_USB;
          end
          /*if(~Single_or_64Chn)begin//64 Channel test, charge inject from CTest pin
            Microroc_CTest_Chn_Out <= All_Chn_Param;
            usb_data_fifo_wr_din <= {8'h63,2'b00,Test_Chn}; //0x63 in ascii is c, meaning channel
            State <= OUT_TEST_CHN_USB;
          end
          else if(Ctest_or_Input)begin//Single channel test, the charge is injected from Ctest pin, therefor the SC parameter should be valid
            Microroc_CTest_Chn_Out <= SINGLE_CHN_PARAM_Ctest << SingleTest_Chn;
            usb_data_fifo_wr_din <= {8'h43,2'b00,SingleTest_Chn};  //0x43 in ascii is C, meaning Ctest
            State <= OUT_TEST_CHN_USB;
          end
          else begin// Single channel test, the charge is injected from input pin, therefor none of Ctest parameter can be selected
            Microroc_CTest_Chn_Out <= SINGLE_CHN_PARAM_Input;
            usb_data_fifo_wr_din <= {8'h49,2'b00,SingleTest_Chn};  //0x49 in ascii is I, meaning Input
          end*/
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
          Force_Ext_RAZ <= 1'b1;
          State <= WAIT_LOAD_SC_PARAM_DONE;
        end
        WAIT_LOAD_SC_PARAM_DONE:begin
          SC_Param_Load <= 1'b0;
          if(Microroc_Config_Done || (SC_Param_Load_Cnt != 16'd0 && SC_Param_Load_Cnt < SC_PARAM_LOAD_DELAY)) begin
            State <= WAIT_LOAD_SC_PARAM_DONE;
            SC_Param_Load_Cnt <= SC_Param_Load_Cnt + 1'b1;
          end
          else if(SC_Param_Load_Cnt == SC_PARAM_LOAD_DELAY)begin            
            Force_Ext_RAZ <= 1'b0;
            SC_Param_Load_Cnt <= 16'b0;
            State <= START_SCURVE_TEST;
          end
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
          if(usb_data_fifo_full)
            State <= OUT_TRIGGER_DATA;
          else begin
            usb_data_fifo_wr_en <= 1'b1;
            State <= WAIT_TRIGGER_DATA;
          end
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
            //usb_data_fifo_wr_en <= 1'b1;
            //SCurve_Test_Done <= 1'b1;
            State <= TAIL_OUT;
          end
          else if(Test_Chn == 6'd63)begin
            All_Chn_Param <= 64'h0000_0000_0000_0001;
            All_Chn_Discri_Mask <= {189'b0, 3'b111};
            Test_Chn <= 6'd0;
            usb_data_fifo_wr_din <= 16'hFF45;
            //usb_data_fifo_wr_en <= 1'b1;
            //SCurve_Test_Done <= 1'b1;
            State <= TAIL_OUT;
          end
          else begin
            All_Chn_Param <= All_Chn_Param << 1'b1;
            All_Chn_Discri_Mask <= (All_Chn_Discri_Mask << 3);
            Test_Chn <= Test_Chn + 1'b1;
            State <= OUT_TEST_CHN_AND_DISCRI_MASK_SC;
          end
        end
        TAIL_OUT:begin
          usb_data_fifo_wr_en <= 1'b1;
          State <= WAIT_TAIL_WRITE;
        end
        WAIT_TAIL_WRITE:begin
          usb_data_fifo_wr_en <= 1'b0;
          if(Wait_Tail_Cnt < 15) begin
            Wait_Tail_Cnt <= Wait_Tail_Cnt + 1'b1;
            State <= WAIT_TAIL_WRITE;
          end
          else begin
            Wait_Tail_Cnt <= 4'b0;
            State <= WAIT_DONE;
          end
        end
        WAIT_DONE:begin
          //usb_data_fifo_wr_en <= 1'b0;
          SCurve_Test_Done <= 1'b1;
          State <= ALL_DONE;
        end
        ALL_DONE:begin
          //usb_data_fifo_wr_en <= 1'b0;
          if(Data_Transmit_Done)begin
            SCurve_Test_Done <= 1'b0;
            State <= IDLE;
          end
          else
            State <= ALL_DONE;
        end
        default:State <= IDLE;
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
