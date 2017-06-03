`timescale 1ns / 1ns
module TestCyclicShift(
  input Clk,
  input reset_n,
  input [2:0] MaskChoise,
  input [5:0] MaskChannel,
  input [1:0] MaskOrUnmask,
  output reg [191:0] ChannelMask
);
reg [7:0] MaskShift;
always @(posedge Clk or negedge reset_n) begin
  if(~reset_n)
    MaskShift <= 8'b0;
  else
    MaskShift <= MaskChannel + MaskChannel + MaskChannel;
end
always @(posedge Clk or negedge reset_n) begin
  if(~reset_n)
    ChannelMask <= {192{1'b1}};
  else if(MaskOrUnmask == 2'b00)
    ChannelMask <= {192{1'b1}};
  else if(MaskOrUnmask == 2'b01)
    ChannelMask <= ({{189{1'b1}},MaskChoise} << MaskShift | {MaskChoise,{189{1'b1}}} >> (192- MaskShift - 3));
  else if(MaskOrUnmask == 2'b10)
    ChannelMask <= {189'b0, 3'b111} << MaskShift;
  else
    ChannelMask <= {192{1'b1}};
end
endmodule
