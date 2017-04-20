`timescale 1ns/1ns
module SweepACQ_Control_tb;
reg clk;
reg reset_n;
// ACQ Control
reg SweepStart;
wire SingleACQStart;
wire OneDACDone;
wire ACQDone;
// Sweep ACQ Parameters
reg [9:0] StartDAC0;
reg [9:0] EndDAC0;
reg [15:0] MaxPackageNumber;
// ACQ Data Enable for Data Counts
reg ParallelData_en;
// SC param
wire [9:0] OutDAC0;
wire LoadSCParameter;
reg MicrorocConfigDone;
// Get ACQ Data
reg [15:0] SweepACQFifoData;
wire SweepACQFifoData_rden;
// Data output
wire [15:0] SweepACQData;
wire SweepACQData_en;
//Instantialtion
SweepACQ_Control uut(
  .Clk(clk),
  .reset_n(reset_n),
  .SweepStart(SweepStart),
  .SingleACQStart(SingleACQStart),
  .OneDACDone(OneDACDone),
  .ACQDone(ACQDone),
  .StartDAC0(StartDAC0),
  .EndDAC0(EndDAC0),
  .MaxPackageNumber(MaxPackageNumber),
  .ParallelData_en(ParallelData_en),
  ,OutDAC0(OutDAC0),
  .LoadSCPatrameter(LoadSCParameter),
  .MicrorocConfigDone(MicrorocConfigDone),
  .SweepACQFifoData(SweepACQFifoData),
  .SweepACQFifoData_rden(SweepACQFifoData_rden),
  .SweepACQData(SweepACQData),
  .SweepACQData_en(SweepACQData_en)
);
endmodule
