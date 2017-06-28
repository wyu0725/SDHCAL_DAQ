`timescale 1ns/1ns
module DaqControl_tb;
reg clk;
reg reset_n;
reg start;
reg End_Readout;
reg Chipsatb;
reg [15:0] T_acquisition;
wire Reset_b;
wire Start_Acq;
wire Start_Readout;
wire Pwr_on_a;
wire Pwr_on_d;
wire Pwr_on_adc;
wire Pwr_on_dac;
wire Once_end;
//instantition
DaqControl uut
(
  .Clk(clk),
  .reset_n(reset_n),
  .start(start),
  .End_Readout(End_Readout),
  .Chipsatb(Chipsatb),
  .T_acquisition(T_acquisition),
  .Reset_b(Reset_b),
  .Start_Acq(Start_Acq),
  .Start_Readout(Start_Readout),
  .Pwr_on_a(Pwr_on_a),
  .Pwr_on_d(Pwr_on_d),
  .Pwr_on_adc(Pwr_on_adc),
  .Pwr_on_dac(Pwr_on_dac),
  .Once_end(Once_end)
);
//initial
parameter PERIOD = 25;//Use 40M clk when running simulation
parameter HighTime = 12;
parameter LowTime = 13;
initial begin
  clk = 1'b0;
  reset_n = 1'b0;
  start = 1'b0;
  End_Readout = 1'b0;
  Chipsatb = 1'b1;
  T_acquisition = 16'h4000;
  #100;
  reset_n = 1'b1;
  start = 1'b1;
  #(55*PERIOD)
  Chipsatb = 1'b0;
  #(4*PERIOD)
  Chipsatb = 1'b1;
  #(18*PERIOD)
  End_Readout = 1'b1;
  #(PERIOD)
  End_Readout = 1'b0;
  start = 1'b0;

end
//Generate clk
always begin
  #(HighTime) 
  clk = ~clk;
  #LowTime;
  clk = ~clk;
end
endmodule
