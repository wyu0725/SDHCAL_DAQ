`timescale 1ns/1ns
module SweepACQ_Top_tb;
reg clk;
reg reset_n;
// ACQ Control
reg SweepStart;
wire SingleACQStart;
wire ACQDone;
wire ForceMicrorocAcqReset;
reg DataTransmitDone;
// Sweep ACQ Parameters
reg [9:0] StartDAC0;
reg [9:0] EndDAC0;
reg [15:0] MaxPackageNumber;
// ACQ Data Enable for Data Counts
reg [15:0] ParallelData;
reg ParallelData_en;
// SC param
wire [9:0] OutDAC0;
wire LoadSCParameter;
reg MicrorocConfigDone;
// Data output
wire [15:0] SweepACQData;
wire SweepACQData_en;
reg UsbDataFifoFull;
//Instantialtion
SweepACQ_Top uut(
  .Clk(clk),
  .reset_n(reset_n),
  .SweepStart(SweepStart),
  .SingleACQStart(SingleACQStart),
  .ForceMicrorocAcqReset(ForceMicrorocAcqReset),
  .ACQDone(ACQDone),  
  .DataTransmitDone(DataTransmitDone),
  .StartDAC0(StartDAC0),
  .EndDAC0(EndDAC0),
  .MaxPackageNumber(MaxPackageNumber),
  .ParallelData(ParallelData),
  .ParallelData_en(ParallelData_en),
  .OutDAC0(OutDAC0),
  .LoadSCParameter(LoadSCParameter),
  .MicrorocConfigDone(MicrorocConfigDone),
  .SweepACQData(SweepACQData),
  .SweepACQData_en(SweepACQData_en),
  .UsbDataFifoFull(UsbDataFifoFull)
);
//Initial
initial begin
  clk = 1'b0;
  reset_n = 1'b0;
  SweepStart <= 1'b0;
  StartDAC0 = 10'd475;
  EndDAC0 = 10'd525;
  MaxPackageNumber = 16'd10;
  UsbDataFifoFull = 1'b0;
  #(100)
  reset_n = 1'b1;
  #(100)
  SweepStart = 1'b1;
  #(100)
  SweepStart = 1'b0;
  #(23062);
  UsbDataFifoFull = 1'b1;
  #(100);
  UsbDataFifoFull = 1'b0;
end
// Genarate Clk
localparam High = 13;
localparam Low = 12;
always begin
	#(Low) clk = ~clk;
	#(High) clk = ~clk;
end
// Generate Config done signal
reg [2:0] SCLoadCount;
always @(posedge clk or posedge reset_n) begin
	if (~reset_n) begin
		SCLoadCount <= 3'b0;
		MicrorocConfigDone <= 1'b0;
  end
	else if (LoadSCParameter || (SCLoadCount != 3'b0 && SCLoadCount <= 3'd7)) begin
		SCLoadCount <= SCLoadCount + 1'b1;
		MicrorocConfigDone <= (SCLoadCount == 3'd7);
	end
	else begin
		SCLoadCount <= 3'd0;
		MicrorocConfigDone <= 1'b0;
	end
end
// Generate Fire Data and Enable
reg [3:0] ParallelDataCount;
reg [2:0] DataInterval;
reg [4:0] DataWait;
reg [2:0] State;
localparam [2:0] IDLE = 3'd0,
                 DATAWAIT = 3'd1,
                 DATAOUT = 3'd3,
                 DATAINTERVAL = 3'd2,
                 END = 3'd6;
always @ (posedge clk or negedge reset_n) begin
  if(~reset_n) begin
    ParallelData_en <= 1'b0;
    ParallelData <= 16'b0;
    ParallelDataCount <= 4'b0;
    DataInterval <= 3'b0;
    DataWait <= 5'b0;
    State <= IDLE;
  end
  else begin
    case(State)
      IDLE:begin
        if(~SingleACQStart) begin
          ParallelData_en <= 1'b0;
          ParallelData <= 16'b0;
          ParallelDataCount <= 4'b0;
          DataInterval <= 3'b0;
          DataWait <= 5'b0;
          State <= IDLE;
        end
        else begin
          State <= DATAWAIT;
        end
      end
      DATAWAIT:begin
        if(DataWait < 5'd30) begin
          DataWait <= DataWait + 1'b1;
          State <= DATAWAIT;
        end
        else begin
          DataWait <= 5'b0;          
          State <= DATAOUT;
        end
      end
      DATAOUT:begin
        if(ParallelDataCount < 4'd10)begin
          ParallelData <= ParallelData + 2'd3;
          ParallelData_en <= 1'b1;
          ParallelDataCount <= ParallelDataCount + 1'b1;
          State <= DATAINTERVAL;
        end
        else begin
          ParallelDataCount <= 4'b0;
          State <= IDLE;
        end
      end
      DATAINTERVAL:begin
        ParallelData_en <= 1'b0;
        if(DataInterval < 3'd7) begin
          DataInterval <= DataInterval + 1'b1;
          State <= DATAINTERVAL;
        end
        else begin
          DataInterval <= 3'b0;
          State <= DATAOUT;
        end
      end
      default:State <= IDLE;
    endcase
  end
end
// Generate DataTransmitDone Signal
always @ (posedge clk or negedge reset_n) begin
  if(~reset_n)
    DataTransmitDone <= 1'b0;
  else if(ACQDone)
    DataTransmitDone <= 1'b1;
  else
    DataTransmitDone <= 1'b0;
end
endmodule
