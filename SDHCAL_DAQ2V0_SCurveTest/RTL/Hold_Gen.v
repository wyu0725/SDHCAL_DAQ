`timescale 1ns / 1ps
//They are 3 trigger outputs(OUT_TRIG0B, OUT_TRIG1B and OUT_TRIG2B ) worked in Read Register progress
//Once  a channel is selected, they are the results of 3 corresponding discriminators. 
//Any of them can be used for hold generation. Once the hold signal is generated, analogue output existed on "out_q" pin.
module Hold_Gen
(
  input Clk,          //500MHz
  input reset_n,
  input Hold_en, // Enable Hold output
  input [1:0] TrigCoincid,
  input [8:0] HoldDelay,//hold delay,maxium 800ns
  input OUT_TRIG0B,   //active, low
  input OUT_TRIG1B,   //active, low
  input OUT_TRIG2B,   //active, low
  input Ext_TRIGB,    //active,low from SMA
  output HOLD,         //Hold signal, Active high
  //Generate enable signal fro external raz_chn added by wyu 20170309
  input ExternalRaz_en,
  input [9:0] ExternalRazDelayTime,
  output reg SingleRaz_en
);
//synchronize the trigger input
//trig coincidence
reg TrigSync1;//active low
reg TrigSync2;
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n)begin
    TrigSync1 <= 1'b1;
    TrigSync2 <= 1'b1;
  end
  else begin
    case(TrigCoincid)
      2'b00: TrigSync1 <= OUT_TRIG0B;
      2'b01: TrigSync1 <= OUT_TRIG1B;
      2'b10: TrigSync1 <= OUT_TRIG2B;
      2'b11: TrigSync1 <= Ext_TRIGB;
    endcase
    TrigSync2 <= TrigSync1;
  end
end
wire TrigFall = TrigSync2 && !TrigSync1;
//hold generation, adjustable delay between trig and hold.
//maxium delay 640ns = 320 clock cycle
//hold width = 6400ns = 3200 clock cycle
reg [8:0] DelayCnt;
reg [15:0] HoldCnt;
reg Hold_r;
reg [1:0] State;
localparam [1:0] Idle = 2'b00,
                DELAY = 2'b01,
                HOLDGEN=2'b10;
                //END   = 2'b11
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n) begin
    DelayCnt <= 9'b0;
    HoldCnt <= 15'b0;
    Hold_r <= 1'b0;
    State <= Idle;
  end
  else begin
    case(State)
      Idle:begin
        if(TrigFall && Hold_en)
          State <= DELAY;
        else
          State <= Idle;
      end
      DELAY:begin
        if(DelayCnt < HoldDelay)
          DelayCnt <= DelayCnt + 1'b1;
        else begin
          DelayCnt <= 9'b0;
          State <= HOLDGEN;
          Hold_r <= 1'b1;
        end
      end
      HOLDGEN:begin
        if(HoldCnt < 16'd3200)
          HoldCnt <= HoldCnt + 1'b1;
        else begin
          HoldCnt <= 16'b0;
          Hold_r <= 1'b0;
          State <= Idle;
        end
      end
      default:State <= Idle;
    endcase
  end
end
assign HOLD = Hold_r;
//--- Capture the falling edge of the three triggres and generate External RAZ enable signal---//
wire TrigAnd = OUT_TRIG0B & OUT_TRIG1B & OUT_TRIG2B;
reg TrigAnd1;
reg TrigAnd2;
always @(posedge Clk or negedge reset_n) begin
  if(~reset_n) begin
    TrigAnd1 <= 1'b1;
    TrigAnd2 <= 1'b1;
  end
  else if(ExternalRaz_en)begin
    TrigAnd1 <= TrigAnd;
    TrigAnd2 <= TrigAnd1;
  end
  else begin
    TrigAnd1 <= 1'b1;
    TrigAnd2 <= 1'b1;
  end
end
wire TrigAndFall = TrigAnd2 & (~TrigAnd1);
// *** Generate External RAZ enable signal
reg [1:0] RazState;
localparam [1:0] IDLE = 2'b00,
                 RAZ_DELAY = 2'b01,
                 RAZ_ENABLE = 2'b10;
reg [9:0] ExternalRazDelayCount;
reg [4:0] RazEnableCount;
always @(posedge Clk or negedge reset_n) begin
  if(~reset_n) begin
    ExternalRazDelayCount <= 10'd0;
    RazEnableCount <= 5'b0;
    SingleRaz_en <= 1'b0;
    RazState <= IDLE;
  end
  else begin
    case(RazState)
      IDLE:begin
        if(TrigAndFall)begin
          RazState <= RAZ_DELAY;
        end
        else begin
          RazState <= IDLE;
        end
      end
      RAZ_DELAY:begin
        if(ExternalRazDelayCount < ExternalRazDelayTime)begin
          RazState <= RAZ_DELAY;
          ExternalRazDelayCount <= ExternalRazDelayCount + 1'b1;
        end
        else begin
          RazState <= RAZ_ENABLE;
          ExternalRazDelayCount <= 10'b0;
          SingleRaz_en <= 1'b1;
        end
      end
      RAZ_ENABLE:begin
        if(RazEnableCount < 5'd16) begin // The width of SingleRaz_en must longer than one period of Clk, thus 25ns
          RazState <= RAZ_ENABLE;
          RazEnableCount <= RazEnableCount + 1'b1;
        end
        else begin
          RazState <= IDLE;
          RazEnableCount <= 5'b0;
          SingleRaz_en <= 1'b0;
        end
      end
      default:RazState <= IDLE;
    endcase
  end
end
endmodule
