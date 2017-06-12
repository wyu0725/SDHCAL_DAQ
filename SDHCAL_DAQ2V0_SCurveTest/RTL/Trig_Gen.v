module Trig_Gen
(
  input Clk,
  input reset_n,
  input rst_cntb,
  input Raz_en,
  input Force_RAZ,// Active H, when H, force external raz to H
  input Trig_en,
  input [1:0] Raz_mode,
  output Raz_chn,     //the width of the pulse must be changed according to the chosen peaking time to avoid "re-triggering"
  output Val_evt,     //should be kept to "1"
  output Rst_counterb,//width of 1us, reset of 24bit counter BCID
  output Trig_ext     //trigger to memory write
);
//Val_evt should be kept to "1"
assign Val_evt = 1'b1; 
//generate 1us rst_counterb signal
reg Rst_counterb_reg;
reg [5:0] counter;
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n) begin
    Rst_counterb_reg <= 1'b1;
    counter <= 6'b0;
  end
  else if(counter < 6'd40 &&(rst_cntb ||  counter != 6'd0)) begin
    Rst_counterb_reg <= 1'b0;
    counter <= counter +1'b1;
  end
  else begin
    Rst_counterb_reg <= 1'b1;
    counter <= 6'b0;
  end
end
assign Rst_counterb = Rst_counterb_reg;
//external Raz_chn signal with a particular width 75ns,250ns,500ns,1us
reg [5:0] DELAY_CONST;
always @ (Raz_mode) begin
  case(Raz_mode)
    2'b00:DELAY_CONST = 6'd3; //75ns
    2'b01:DELAY_CONST = 6'd10;//250ns
    2'b10:DELAY_CONST = 6'd20;//500ns
    2'b11:DELAY_CONST = 6'd40;//1us
  endcase
end
//
reg Raz_chn_ext;
reg [5:0] counter1;
reg Raz_r1;
reg Raz_r2;
always @(posedge Clk or negedge reset_n) begin
  if(~reset_n) begin
    Raz_r1 <= 1'b0;
    Raz_r2 <= 1'b0;
  end
  else begin
    Raz_r1 <= Raz_en;
    Raz_r2 <= Raz_r1;
  end
end
wire RazEnableRise = Raz_r1 && (~Raz_r2);
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n) begin
    Raz_chn_ext <= 1'b0;
    counter1 <= 6'b0;
  end
  else if (Force_RAZ)begin
    Raz_chn_ext <= 1'b1;
  end
  else if(RazEnableRise || (counter1 < DELAY_CONST && counter1 != 6'd0))begin
    Raz_chn_ext <= 1'b1;
    counter1 <= counter1 +1'b1;
  end
  else begin
    Raz_chn_ext <= 1'b0;
    counter1 <= 6'b0;
  end
end
assign Raz_chn = Raz_chn_ext;
//generate Trig_ext, trigger to memory write
reg Trig_ext_reg;
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n) 
    Trig_ext_reg <= 1'b0;
  else if (Trig_en)
    Trig_ext_reg <= 1'b1;
  else
    Trig_ext_reg <= 1'b0;
end
assign Trig_ext = Trig_ext_reg;
endmodule
