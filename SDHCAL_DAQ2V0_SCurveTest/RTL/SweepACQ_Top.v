`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/04/20 19:38:25
// Design Name: 
// Module Name: SweepACQ_Top
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


module SweepACQ_Top(
    input Clk,
    input reset_n,
    // ACQ Control
    input SweepStart,
    output SingleACQStart,
    output ACQDone,
    input DataTransmitDone,
    // Sweep ACQ Parameters
    input [9:0] StartDAC0,
    input [9:0] EndDAC0,
    input [15:0] MaxPackageNumber,
    // ACQ Data
    input [15:0] ParallelData,
    input ParallelData_en,
    // SC Parameters
    output [9:0] OutDAC0,
    output LoadSCParameter,
    input MicrorocConfigDone,
    //Data out
    output [15:0] SweepACQData,
    output SweepACQData_en
    );
    // Generate the Start Pulse
    wire SweepStart_Pulse;
    reg SweepStart_reg1;
    reg SweepStart_reg2;
    always @ (posedge Clk or negedge reset_n) begin
      if(~reset_n) begin
        SweepStart_reg1 <= 1'b0;
        SweepStart_reg2 <= 1'b0;
      end
      else begin
        SweepStart_reg1 <= SweepStart;
        SweepStart_reg2 <= SweepStart_reg1;
      end
    end
    assign SweepStart_Pulse = SweepStart_reg1 && (~SweepStart_reg2);
    //Instantiation SweepACQ Control
    wire rstExtFIFO;
    wire [15:0] SweepFifoData;
    wire SweepFifoData_rden;
    wire SweepFifoFull;
    wire SweepFifoEmpty;
    SweepACQ_Control SweepACQ_Control(
      .Clk(Clk),
      .reset_n(reset_n),
      //ACQ Control
      .SweepStart(SweepStart_Pulse),
      .SingleACQStart(SingleACQStart),
      .OneDACDone(rstExtFIFO),
      .ACQDone(ACQDone),
      .DataTransmitDone(DataTransmitDone),
      // Sweep ACQ Parameters
      .StartDAC0(StartDAC0),
      .EndDAC0(EndDAC0),
      .MaxPackageNumber(MaxPackageNumber),
      //ACQ Data Enable for Data Counts
      .ParallelData_en(ParallelData_en),
      // Microroc SC Parameters
      .OutDAC0(OutDAC0),
      .LoadSCParameter(LoadSCParameter),
      .MicrorocConfigDone(MicrorocConfigDone),
      // Get ACQ Data
      .SweepACQFifoData(SweepFifoData),
      .SweepACQFifoData_rden(SweepFifoData_rden),
      // Data Output
      .SweepACQData(SweepACQData),
      .SweepACQData_en(SweepACQData_en)
    );
    SweepACQ_FIFO SweepACQ_DataFIFO16x128(
      .clk(Clk),
      .rst(~reset_n | rstExtFIFO | (~StartSweep)),
      .din(ParallelData),
      .wr_en(ParallelData_en),
      .rd_en(SweepFifoData_rden),
      .dout(SweepFifoData),
      .full(SweepFifoFull),
      .empty(SweepFifoEmpty)
    );

endmodule
