`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Yu Wang
// 
// Create Date: 2017/06/12 20:03:14
// Design Name: SDHCAL_DAQ 
// Module Name: AdcControl
// Project Name: 
// Target Devices: XC7A100TFGG484-2 
// Tool Versions: Vivado 16.3
// Description: 
// This module is use to Control the ADC AD9220. AD9220 is a 12-bit pipline
// ADC and the max sample rate is 10MHz. The output latency is 3 clock period,
// and time clock to output is 8ns. In this module we don't provide the
// function that the sample rate can be changed
// In this module we choose 10MHz Sample rate. When acquisition, the hold
// signal start the ADC and the convertion time is decided by the user. 
// Dependencies: 
// 
// Revision: 
// Revision 0.01 - File Created
// V1.0 File Completed 20170613 9:20
// V1.1 Fiel Simlation Completed 20170613 9:20
// V2.0 Change average into conversion directly
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AdcControl(
    input Clk,
    input reset_n,
    input Hold,
    input StartAcq,
    input [3:0] AdcStartDelay,
    input [7:0] AdcDataNumber,
    input [11:0] ADC_DATA,
    input ADC_OTR,
    output ADC_CLK,
    output [15:0] Data,
    output Data_en
    );
    // ***Instantiate the Adc Module
    reg AdcStart;
    wire [11:0] AdcData;
    wire AdcData_en;
    ADC_AD9220 Ad9220Control(
      .Clk(Clk),
      .reset_n(reset_n),
      .start(AdcStart),
      .ADC_OTR(ADC_OTR),
      .ADC_DATA(ADC_DATA),
      .ADC_CLK(ADC_CLK),
      .data_ready(AdcData_en),
      .data(AdcData)
    );
    // ***Capture the rasing edge of Hold
    reg Hold_reg1;
    reg Hold_reg2;
    always @(posedge Clk or negedge reset_n) begin
      if(~reset_n) begin
        Hold_reg1 <= 1'b0;
        Hold_reg2 <= 1'b0;
      end
      else begin
        Hold_reg1 <= Hold;
        Hold_reg2 <= Hold_reg1;
      end
    end
    wire HoldRising;
    assign HoldRising = Hold_reg1 && (~Hold_reg2);
    wire HoldFalling;
    assign HoldFalling = (~Hold_reg1) && Hold_reg2;
    reg [1:0] State;
    localparam [1:0] IDLE = 2'b00,
                     START_ADC = 2'b01,
                     WAIT_DATA = 2'b10,
                     DONE = 2'b11;
    reg [7:0] AdcDataCount;
    reg ResetCount_n;
    reg [3:0] AdcStartDelayCount;
    always @(posedge Clk or negedge reset_n) begin
      if(~reset_n) begin
        State <= IDLE;
        //AdcDataCount <= 8'b0;
        AdcStartDelayCount <= 4'b0;
        AdcStart <= 1'b0;
        ResetCount_n <= 1'b0;
      end
      else begin
        case(State)
          IDLE:begin
            if(StartAcq && HoldRising) begin
              State <= START_ADC;
              //AdcDataCount <= 8'b0;
            end
            else begin
              State <= IDLE;
              //AdcDataCount <= 8'b0;
            end
          end
          START_ADC:begin
            if(AdcStartDelayCount < AdcStartDelay) begin
              State <= START_ADC;
              AdcStartDelayCount <= AdcStartDelayCount + 1'b1;
              AdcStart <= 1'b0;
            end
            else begin
              State <= WAIT_DATA;
              AdcStartDelayCount <= 4'b0;
              AdcStart <= 1'b1;
              ResetCount_n <= 1'b1;
            end
          end
          WAIT_DATA:begin
            if(AdcDataCount < AdcDataNumber && Hold_reg1) begin
              State <= WAIT_DATA;
            end
            else begin
              State <= DONE;
              AdcStart <= 1'b0;
              ResetCount_n <= 1'b0;
            end
          end
          DONE:begin
            ResetCount_n <= 1'b1;
            State <= IDLE;
          end
        endcase
      end
    end
    always @(posedge AdcData_en or negedge ResetCount_n) begin
      if(~ResetCount_n) begin
        AdcDataCount <= 8'b0;
      end
      else begin
        AdcDataCount <= AdcDataCount + 1'b1;
      end
    end
    assign Data = {3'b0,ADC_OTR,AdcData};
    assign Data_en = AdcData_en;
    /*
    // ***Adc Control
    reg [2:0] State;
    localparam [2:0] IDLE = 3'b000,
                     START_ADC = 3'b001,
                     GET_ADC_DATA = 3'b011,
                     CHECK_ACQ_DONE = 3'b010,
                     DEVIDE_DATA = 3'b110,
                     OUT_DATA = 3'b111,
                     END = 3'b101;
    reg [4:0] DataCount;
    reg [3:0] AdcStartDelayCount;
    reg [16:0] InternalSumData;
    always @(posedge Clk or negedge reset_n) begin
      if(~reset_n) begin
        AdcStart <= 1'b0;
        State <= IDLE;
        DataCount <= 5'b0;
        AdcStartDelayCount <= 4'b0;
        InternalSumData <= 17'b0;
        SumData_en <= 1'b0;
      end
      else begin
        case(State)
          IDLE:begin
            if(StartAcq && HoldRising) begin
              State <= START_ADC;
              AdcStart <= 1'b0;              
              DataCount <= 5'b0;
              InternalSumData <= 16'b0;
              AdcStartDelayCount <= 4'b0;
            end
            else begin
              State <= IDLE;
              AdcStart <= 1'b0;              
              DataCount <= 5'b0;
            end
          end
          START_ADC:begin
            if(AdcStartDelayCount < AdcStartDelay) begin
              AdcStartDelayCount <= AdcStartDelayCount + 1'b1;
              State <= START_ADC;
            end
            else begin
              AdcStartDelayCount <= 4'b0;
              AdcStart <= 1'b1;
              State <= GET_ADC_DATA;
            end
          end
          GET_ADC_DATA:begin
            if(AdcData_en) begin
              InternalSumData <= InternalSumData + AdcData;
              State <= CHECK_ACQ_DONE;
            end
            else begin
              InternalSumData <= InternalSumData;
              State <= GET_ADC_DATA;
            end
          end
          CHECK_ACQ_DONE:begin
            if(DataCount < 5'd31) begin
              DataCount <= DataCount + 1'b1;              
              State <= GET_ADC_DATA;
            end
            else begin
              DataCount <= 5'b0;
              AdcStart <= 1'b0;
              State <= DEVIDE_DATA;
            end
          end
          DEVIDE_DATA:begin
            InternalSumData <= InternalSumData >> 1'b1;
            State <= OUT_DATA;
          end
          OUT_DATA:begin
            SumData_en <= 1'b1;
            State <= END;
          end
          END:begin
            SumData_en <= 1'b0;
            State <= IDLE;
          end
        endcase
      end
    end*/
    //assign SumData = InternalSumData[15:0];
endmodule
