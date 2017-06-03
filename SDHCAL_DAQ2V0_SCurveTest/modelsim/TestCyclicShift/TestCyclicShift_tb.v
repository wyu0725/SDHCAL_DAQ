module TestCyclicShift_tb;
reg Clk;
reg reset_n;
reg [2:0] MaskChoise;
reg [5:0] MaskChannel;
reg [1:0] MaskOrUnmask;
wire [191:0] ChannelMask;

TestCyclicShift uut(
  .Clk(Clk),
  .reset_n(reset_n),
  .MaskChoise(MaskChoise),
  .MaskChannel(MaskChannel),
  .MaskOrUnmask(MaskOrUnmask),
  .ChannelMask(ChannelMask)
);

initial begin
  Clk = 1'b0;
  reset_n = 1'b0;
  MaskChoise = 3'b111;
  MaskChannel = 6'd5;
  MaskOrUnmask = 2'b00;
  #100;
  reset_n = 1'b1;
  #(100);
  MaskChoise = 3'b000;
  MaskChannel = 5;
  MaskOrUnmask = 2'b01;
  #(100);
  MaskOrUnmask = 2'b10;
  MaskChoise = 3'b111;
end

parameter PEROID = 20;
always #(PEROID/2) Clk = ~Clk;
endmodule
