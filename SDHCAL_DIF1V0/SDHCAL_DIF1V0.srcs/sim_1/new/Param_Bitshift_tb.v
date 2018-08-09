module Param_Bitshift_tb;
  reg clk_5M;
  reg reset_n;
  reg start;
  reg [15:0] ext_fifo_data;
  reg ext_fifo_empty;
  wire ext_fifo_rden;
  wire sr_ck;
  wire sr_rstb;
  wire sr_in;
  wire RunEnd;
  reg [5:0] fifo_out_count;
  //instantiate uut
  //instance:../../../src/BitShiftOut.v
  BitShiftOut uut(
    .Clk5M(clk_5M),
    .reset_n(reset_n),
    .BitShiftOutStart(start),
    .ExternalFifoReadEn(ext_fifo_rden),
    .ExternalFifoEmpty(ext_fifo_empty),
    .ExternalFifoDataIn(ext_fifo_data),
    //*** Pins
    .SerialClock(sr_ck),
    .SerialReset(sr_rstb),
    .SerialDataout(sr_in),
    .BitShiftDone(RunEnd)
    );
  parameter PERIOD = 200;
  //initial
  initial begin
    clk_5M = 1'b0;
    reset_n = 1'b0;
    start = 1'b0;
    //ext_fifo_data = 16'b0;
    //ext_fifo_empty = 1'b1;
    #1000;
    reset_n = 1'b1;
    start = 1'b1;
    //#(64*37*PERIOD)
    #(PERIOD);
    start = 1'b0;
    //ext_fifo_empty = 1'b0;
  end
  //Generate data as fifo

  reg [2:0] ReadRegist_num = 3'd4;
  reg [5:0] SC_num = 6'd37;
  always @(posedge clk_5M,negedge reset_n) begin
    if(!reset_n) begin
      ext_fifo_data <= 16'ha5a5;
      ext_fifo_empty <= 1'b1;
      fifo_out_count <= 6'b0;
    end
    else begin
      if(fifo_out_count < SC_num) begin
        ext_fifo_empty <= 1'b0;
        if(ext_fifo_rden)begin
          ext_fifo_data <= ext_fifo_data + 1'b1;
          fifo_out_count <= fifo_out_count + 1'b1;
        end
        else begin
          ext_fifo_data <= ext_fifo_data;
        end
      end
      else begin
        ext_fifo_data <= 16'ha5a5;
        ext_fifo_empty <= 16'b1;
      end
    end
  end
  //Generate 5M clock

  always #(PERIOD/2) clk_5M = ~clk_5M;
endmodule
