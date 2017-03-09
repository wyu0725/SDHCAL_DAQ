
//AD9220 12-Bit A/D Converter 10Msps
//AD9220 utiliza a four-stage pipeline architecture with a wideband input SHA
//inplemented on a cost-effective CMOS process. Pipeline Delay 3 clock cycles
//BIT12--> LSB, BIT1 --> MSB
module ADC_AD9220
(
  input Clk,
  input reset_n,
  input start,  //start acquisition
  //-------AD9220 access-----//
  input ADC_OTR,//An out-of-range condition exists then the analog input voltage is beyond the input range of the converter.High active
  input [11:0] ADC_DATA,
  output ADC_CLK,
  //-------ADC output
  output reg data_ready,
  output reg [11:0] data
);
//Generate ADC frequency a quarter of Clk, ADC_CLK = 10MHz
reg [1:0] cnt;
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n)
    cnt <= 2'b0;
  else if(start) begin
    cnt <= cnt + 1'b1;
  end
  else
    cnt <= 2'b0;
end
assign ADC_CLK = cnt[1];
reg [3:0] delay_cnt;
reg [1:0] State;
localparam [1:0] Idle = 2'b00,
                ACQ   = 2'b01,
                PERIOD= 2'b10;
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n) begin
    data_ready <= 1'b0;
    data <= 12'b0;
    delay_cnt <= 4'b0;
    State <= Idle;
  end
  else begin
    case(State)
      Idle:begin
        if(start) begin
          if(delay_cnt < 4'd15) begin //first time Pipeline delay 3 clock cycles
            delay_cnt <= delay_cnt + 1'b1;
            State <= Idle;
          end
          else begin
            delay_cnt <= 4'b0;
            State <= ACQ;
          end
        end
        else begin
          data_ready <= 1'b0;
          data <= data;
          State <= Idle;
        end
      end
      ACQ:begin
          data_ready <= 1'b1;
          data <= ADC_DATA;
          State <= PERIOD;
        end
      PERIOD:begin
        data_ready <= 1'b0;
        if(start) begin
          if(delay_cnt < 4'd2) begin   //read data every 100ns,100ns should contain PERIOD and ACQ state,ACQ state last 25 ns,PEROID state should continue 75ns that is 3 time cycle
            delay_cnt <= delay_cnt + 1'b1;
            State <= PERIOD;
          end
          else begin
            delay_cnt <= 4'd0;
            State <= ACQ;
          end
        end
        else begin
          State <= Idle;
          data <= data;
        end
      end
      default:State <= Idle;
    endcase
  end
end
endmodule
