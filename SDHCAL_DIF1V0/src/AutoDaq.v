`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Science and Technology of China
// Engineer: Junbin Zhang
// 
// Create Date: 11/14/2016 02:27:41 PM
// Design Name: SDHCAL_DAQ2V0
// Module Name: DaqControl
// Project Name: SDHCAL_DAQ2V0
// Target Devices: XC7A100TFGG484
// Tool Versions: Vivado 2016.3
// Description: Top level of the Microroc ASIC, including slow control Data Acquisition and so on.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module AutoDaq
(
  input Clk,         //40M
  input reset_n,
  input start,
  input End_Readout, //Digitial RAM end reading signal, Active H
  input Chipsatb,    //Chip is full, Active L
  input [15:0] T_acquisition,//Send from USB, default 8
  output reg Reset_b,//Reset ASIC digital part
  output reg Start_Acq,    //Start & maintain acquisition, Active H
  output reg Start_Readout,//Digital RAM start reading signal
  output reg Pwr_on_a,  //Analogue Part Power Pulsing control, active H
  output reg Pwr_on_d,  //Digital Power Pulsing control, active H
  output Pwr_on_adc,//Slow shaper Power Pulsing Control, active H
  output reg Pwr_on_dac,//DAC Power Pulsing Control, Active H
  output reg Once_end
);
//synchronize external Chipsatb input
reg Chipsatb_sync1,Chipsatb_sync2;
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n) begin
    Chipsatb_sync1 <= 1'b1;
    Chipsatb_sync2 <= 1'b1;
  end
  else begin
    Chipsatb_sync1 <= Chipsatb;
    Chipsatb_sync2 <= Chipsatb_sync1;
  end
end
wire Chip_full = Chipsatb_sync2 & !Chipsatb_sync1; //falling edge indicates that one or more ASICs are full
wire Read_start = !Chipsatb_sync2 & Chipsatb_sync1;//rising edge indicates that readout cound start
//synchronize external End_Readout input
reg End_Readout_sync1,End_Readout_sync2;
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n) begin
    End_Readout_sync1 <= 1'b0;
    End_Readout_sync2 <= 1'b0;
  end
  else begin
    End_Readout_sync1 <= End_Readout;
    End_Readout_sync2 <= End_Readout_sync1;
  end
end
wire Read_End = End_Readout_sync2 & !End_Readout_sync1;//falling edge
//fsm of daq control
reg [15:0] delay_cnt;
localparam [3:0] Idle = 4'd0,
            CHIPRESET = 4'd1,
            POWOND    = 4'd2,
            RELEASE   = 4'd3,
            ACQUISITION = 4'd4,
            WAIT = 4'd5,
            START_READOUT = 4'd6,
            WAIT_READ = 4'd7,
            END_READOUT = 4'd8;
reg [3:0] State;
localparam T_minPwrRst = 8; //200ns, time to wake up clock LVDS receivers 
localparam T_minRstStart = 40;//1us, 
//localparam T_acquisition = 8; //acquisition time corresponding to the bunch crossing
localparam T_minSro      = 16;//400ns, time to wake up clock LVDS receivers
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n) begin
    Reset_b <= 1'b1;
    Start_Acq <= 1'b0;
    Start_Readout <= 1'b0;
    //Pwr_on_a <= 1'b0;
    //Pwr_on_d <= 1'b0;
    //Pwr_on_adc <= 1'b0;
    //Pwr_on_dac <= 1'b0;
    delay_cnt <= 16'b0;
    Once_end <= 1'b0;
    State <= Idle;
  end
  else begin
    case(State)
      Idle:begin
        if(start) begin
          Reset_b <= 1'b0;
          State <= CHIPRESET;
        end
        else 
          State <= Idle;
      end
      CHIPRESET:begin    //reset the chip
        //Pwr_on_d <= 1'b1;    //This signal is set during the reset State before each acquisition
        State <= POWOND;
      end
      POWOND:begin               
        if(delay_cnt < T_minPwrRst) begin//T_minPwrRst = 8
          delay_cnt <= delay_cnt + 1'b1;
          State <= POWOND;
        end
        else begin
          delay_cnt <= 16'b0;
          State <= RELEASE;
          Reset_b <= 1'b1;
        end
      end
      RELEASE:begin
        if(delay_cnt < T_minRstStart) begin//T_minRstStart = 40
          delay_cnt <= delay_cnt + 1'b1;
          State <= RELEASE;
        end
        else begin
          delay_cnt <= 16'b0;
          Start_Acq <= 1'b1;
          State <= ACQUISITION;
        end
      end
      ACQUISITION:begin
        if(delay_cnt < T_acquisition) begin//T_acquisition = 8//send from USB, default 8
          //delay_cnt <= delay_cnt + 1'b1;
          if(Chip_full) begin //chip full during acquisition
            State <= WAIT;
            delay_cnt <= 16'b0;
            Start_Acq <= 1'b0;
          end
          else
            delay_cnt <= delay_cnt + 1'b1;
            State <= ACQUISITION;
        end
        else begin
          delay_cnt <= 16'b0;
          Start_Acq <= 1'b0;
          State <= WAIT;
        end
      end
      WAIT:begin
        if(Read_start) begin
          //Pwr_on_d <= 1'b0;
          Start_Readout <= 1'b1;
          State <= START_READOUT;
        end
        else begin
          State <= WAIT;
        end
      end
      START_READOUT:begin
        if(delay_cnt < T_minSro) begin // T_minSro      = 16
          delay_cnt <= delay_cnt + 1'b1;
          State <= START_READOUT;
        end
        else begin
          delay_cnt <= 16'b0;
          Start_Readout <= 1'b0;
          State <= WAIT_READ;
        end
      end
      WAIT_READ:begin
        if(Read_End) begin//
          Once_end <= 1'b1;
          State <= END_READOUT;
        end
        else
          State <= WAIT_READ;
      end
      END_READOUT:begin
        Once_end <= 1'b0;
        State <= Idle;
      end
      default:State <= Idle;
    endcase
  end
end
//Powerpulsing control
//Pwr_on_d
always @ (State) begin
  if(State == POWOND || State == RELEASE || State == ACQUISITION || State == WAIT)
    Pwr_on_d = 1'b1;
  else
    Pwr_on_d = 1'b0;
end
//Pwr_on_a
//Pwr_on_dac
always @ (State) begin
  if(State == CHIPRESET || State == POWOND || State == RELEASE || State == ACQUISITION
    || State == WAIT || State == START_READOUT) begin
    Pwr_on_a = 1'b1;
    Pwr_on_dac = 1'b1;
  end
  else begin
    Pwr_on_a = 1'b0;
    Pwr_on_dac = 1'b0;
  end
end
assign Pwr_on_adc = 1'b0;
/*(*mark_debug = "true"*)wire start_debug;
(*mark_debug = "true"*)wire End_Readout_debug;
(*mark_debug = "true"*)wire Chipsatb_debug;
(*mark_debug = "true"*)wire Reset_b_debug;
(*mark_debug = "true"*)wire Start_Acq_debug;
(*mark_debug = "true"*)wire Start_Readout_debug;
(*mark_debug = "true"*)wire Pwr_on_a_debug;
(*mark_debug = "true"*)wire Pwr_on_d_debug;
(*mark_debug = "true"*)wire Pwr_on_dac_debug;
(*mark_debug = "true"*)wire Once_end_debug;
assign start_debug = start;
assign End_Readout_debug = End_Readout;
assign Chipsatb_debug = Chipsatb;
assign Reset_b_debug = Reset_b;
assign Start_Acq_debug = Start_Acq;
assign Start_Readout_debug = Start_Readout;
assign Pwr_on_a_debug = Pwr_on_a;
assign Pwr_on_d_debug = Pwr_on_d;
assign Pwr_on_dac_debug = Pwr_on_dac;
assign Once_end_debug = Once_end;*/
endmodule
