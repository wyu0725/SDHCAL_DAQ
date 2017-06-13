`timescale 1ns / 1ns
module ADC_AD9220_tb;
  reg Clk;
  reg reset_n;
  reg start;
  reg ADC_OTR;
  reg [11:0] ADC_DATA;
  wire ADC_CLK;
  wire data_ready;
  wire [11:0] data;
  ADC_AD9220 uut(
    .Clk(Clk),
    .reset_n(reset_n),
    .start(start),
    .ADC_OTR(ADC_OTR),
    .ADC_DATA(ADC_DATA),
    .ADC_CLK(ADC_CLK),
    .data_ready(data_ready),
    .data(data)
  );
  // initial
  initial begin
    Clk = 1'b0;
    reset_n = 1'b0;
    start = 1'b0;
    ADC_OTR = 1'b0;
    //ADC_DATA = 12'b0;
    #100;
    reset_n = 1'b1;
    #100;
    start = 1'b1;
  end
  // Generate ADC Data
  always @(posedge ADC_CLK or negedge reset_n) begin
    if(~reset_n)
      ADC_DATA <= 12'b0;
    else begin
      #(8); ADC_DATA <= ADC_DATA + 1'b1;
    end
  end
  // Generate Clk
  localparam HighTime = 13;
  localparam LowTime = 12;
  always begin
    #(LowTime) Clk = ~Clk;
    #(HighTime) Clk = ~Clk;
  end
endmodule
