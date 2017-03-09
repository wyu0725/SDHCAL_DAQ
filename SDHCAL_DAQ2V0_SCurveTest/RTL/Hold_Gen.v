//They are 3 trigger outputs(OUT_TRIG0B, OUT_TRIG1B and OUT_TRIG2B ) worked in Read Register progress
//Once  a channel is selected, they are the results of 3 corresponding discriminators. 
//Any of them can be used for hold generation. Once the hold signal is generated, analogue output existed on "out_q" pin.
module Hold_Gen
(
  input Clk,          //40MHz
  input reset_n,
  input [1:0] Trig_Coincid,
  input [4:0] Hold_delay,//hold delay,maxium 800ns
  input OUT_TRIG0B,   //active, low
  input OUT_TRIG1B,   //active, low
  input OUT_TRIG2B,   //active, low
  input Ext_TRIGB,    //active,low from SMA
  //output RST_COUNTERB,//Reset Gray Counter 24bit counter BCID
  //output TRIG_EXT,    //External trigger, Active rising edge
  output HOLD,         //Hold signal, Active high
  //Generate enable signal fro external raz_chn added by wyu 20170309
  input External_RAZ_en,
  input [3:0] External_RAZ_Delay_Time,
  output reg Single_RAZ_en
);
//synchronize the trigger input
/*
reg [3:0] out_trig;
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n)
    out_trig <= 4'b1111;
  else begin
    out_trig[3] <= Ext_TRIGB;
    out_trig[2] <= OUT_TRIG2B;
    out_trig[1] <= OUT_TRIG1B;
    out_trig[0] <= OUT_TRIG0B;
  end
end
*/
//trig coincidence
reg trig;//active low
reg trig1;
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n)begin
    trig <= 1'b1;
    trig1 <= 1'b1;
  end
  else begin
    case(Trig_Coincid)
      2'b00: trig <= OUT_TRIG0B;
      2'b01: trig <= OUT_TRIG1B;
      2'b10: trig <= OUT_TRIG2B;
      2'b11: trig <= Ext_TRIGB;
    endcase
    trig1 <= trig;
  end
end
wire trig_fall = trig1 && !trig;
//capture rising edge or falling edge
/*
reg [1:0] trig_sync;
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n) begin
    trig_sync <= 2'b11;
  end
  else begin
    trig_sync[0] <= trig;
    trig_sync[1] <= trig_sync[0];
  end
end
wire trig_fall = trig_sync[1] & !trig_sync[0];
*/
//hold generation, adjustable delay between trig and hold.
//maxium delay 640ns = 26 clock cycle
//hold width = 6400ns = 256 clock cycle
reg [4:0] cnt;
reg [7:0] hold_cnt;
reg hold_sig;
reg [1:0] State;
localparam [1:0] Idle = 2'b00,
                DELAY = 2'b01,
                HOLDGEN=2'b10;
                //END   = 2'b11
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n) begin
    cnt <= 5'b0;
    hold_cnt <= 8'b0;
    hold_sig <= 1'b0;
    State <= Idle;
  end
  else begin
    case(State)
      Idle:begin
        if(trig_fall)
          State <= DELAY;
        else
          State <= Idle;
      end
      DELAY:begin
        if(cnt < Hold_delay)
          cnt <= cnt + 1'b1;
        else begin
          cnt <= 5'b0;
          State <= HOLDGEN;
          hold_sig <= 1'b1;
        end
      end
      HOLDGEN:begin
        if(hold_cnt < 8'hff)
          hold_cnt <= hold_cnt + 1'b1;
        else begin
          hold_cnt <= 8'b0;
          hold_sig <= 1'b0;
          State <= Idle;
        end
      end
     /* END:begin
        State <= Idle;
      end
      */
      default:State <= Idle;
    endcase
  end
end
assign HOLD = hold_sig;
/*--- Capture the falling edge of the three triggres ---*/
wire trigger_and = OUT_TRIG0B & OUT_TRIG1B & OUT_TRIG2B;
reg trigger_and_1;
reg trigger_and_2;
always @(posedge Clk or negedge reset_n) begin
  if(~reset_n) begin
    trigger_and_1 <= 1'b1;
    trigger_and_2 <= 1'b1;
  end
  else if(External_RAZ_en)begin
    trigger_and_1 <= trigger_and;
    trigger_and_2 <= trigger_and_1;
  end
  else begin
    trigger_and_1 <= 1'b1;
    trigger_and_2 <= 1'b1;
  end
end
wire trigger_and_fall = trigger_and_2 & (~trigger_and_1);
reg [3:0]trigger_delay_cnt;
always @(posedge Clk or negedge reset_n) begin
  if(~reset_n) begin
    trigger_delay_cnt <= 4'd0;
    Single_RAZ_en <= 1'b0;
  end
  else if(trigger_and_fall || (trigger_delay_cnt != 4'd0 && trigger_delay_cnt <= External_RAZ_Delay_Time)) begin
    trigger_delay_cnt <= trigger_delay_cnt + 1'b1;
    Single_RAZ_en <= (trigger_delay_cnt == External_RAZ_Delay_Time);
  end
  else begin
    trigger_delay_cnt <= 4'd0;
    Single_RAZ_en <= 1'b0;
  end
end
endmodule
