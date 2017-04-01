`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Science and Technology of China
// Engineer: Junbin Zhang
// 
// Create Date: 11/14/2016 02:27:41 PM
// Design Name: SDHCAL_DAQ2V0
// Module Name: Microroc_Param
// Project Name: SDHCAL_DAQ2V0
// Target Devices: XC7A100TFGG484
// Tool Versions: Vivado 2016.3
// Description: this module contains all the sc parameters and read register of Microroc
// Microroc has 592bits slow control parameters and 64-bit read register
// Dependencies: //parameter
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module Microroc_Parameters
(
  input Clk,
  input reset_n,
  input sc_or_read, //slow control or read? 1 => read register
  input start,      //start load parameters
  input [2:0] asic_num,//how many asics?
  //--------Microroc slow control registers----------//
  input [1:0] En_dout,
  input [1:0] En_transmiton,
  input En_chipsatb,
  input Sel_startreadout,
  input Sel_endreadout,
  input [1:0] Sel_raz,
  input Ck_mux,
  input Sc_on,
  input Raz_chn_ext_validation,
  input Raz_chn_int_validation,
  input Trig_ext_validation,
  input Disc_or_or,
  input En_trig_out,
  input [2:0] Trigb,
  input [9:0] DAC2_Vth,
  input [9:0] DAC1_Vth,
  input [9:0] DAC0_Vth,
  input En_dac,
  input En_dac_pp,
  input En_bg,
  input En_bg_pp,
  input [7:0] header,
  input [191:0] Chn_discri_mask,
  input Rs_or_discri,
  input En_discri1_pp,
  input En_discri2_pp,
  input En_discri0_pp,
  input En_otaq_pp,
  input En_otaq,
  input En_dac4bit_pp,
  input [255:0] Chn_adjust,
  input [1:0] Sw_hg,
  input Va_shlg_read,
  input En_widlar_pp,
  input [1:0] Sw_lg,
  input En_shlg_pp,
  input En_shhg_pp,
  input En_gbst,
  input En_Preamp_pp,
  input [63:0] Ctest,
  //--------Microroc read register-------------//
  input [63:0] Read_reg,
  //--------FIFO interface--------------------//
  output ext_fifo_wr_en,
  output [15:0]ext_fifo_din,
  output Done
);
//--------------sc parameters map----------------------//
wire [592:1] param592b;
assign param592b[592:591] = En_dout;               //enable dout1b and dout2b
assign param592b[590:589] = En_transmiton;         //enable transmiton1b and transmiton2b
assign param592b[588]     = En_chipsatb;           //enable chipsatb
assign param592b[587]     = Sel_startreadout;      //select startreadout 1 or 2
assign param592b[586]     = Sel_endreadout;        //select endreadout 1 or 2
assign param592b[585:584] = 2'b11;                 //NC
assign param592b[583:582] = Sel_raz;               //select raz_chn_width and mux raz_chn width
assign param592b[581]     = Ck_mux;                //bypass Synchronous PoweronDigital
assign param592b[580]     = Sc_on;                 //enable clocks LVDS Receriver power pulsing
//---------Trigger cell--------------//
assign param592b[579]     = Raz_chn_ext_validation;//Enable external Raz_Channel signal
assign param592b[578]     = Raz_chn_int_validation;//Enable internal Raz_Channel signal
assign param592b[577]     = Trig_ext_validation;   //Enable external trigger signal
assign param592b[576]     = Disc_or_or;            //Select Channel Trigger selected by Read Register(0) or NOR64 output(1)
assign param592b[575]     = En_trig_out;           //Enable trigger out
assign param592b[574:572] = Trigb;                 //select Trigger to write to memory
                                                   //Reverse high bit and low
                                                   //bit,the top level should
                                                   //also reverse.
//--------Triple DAC-----------------//
assign param592b[571:562] = DAC2_Vth;              //10-bit Triple DAC voltage threshold
assign param592b[561:552] = DAC1_Vth;
assign param592b[551:542] = DAC0_Vth;
assign param592b[541]     = En_dac;                //Enable dac
assign param592b[540]     = En_dac_pp;             //Enable dac for power pulsing
assign param592b[539]     = En_bg;                 //Enable bandgap
assign param592b[538]     = En_bg_pp;              //Enable banggap power pulsing
//--------Chip ID--------------------//
assign param592b[537:530] = header;                //chip id, revise the chip id
//----Channel discriminators mask----//
assign param592b[529:338] = Chn_discri_mask;       //channel discriminators mask
//---------------BIAS---------------//
assign param592b[337]     = Rs_or_discri;          //select latched or direct output --default: 1 => latched
assign param592b[336]     = En_discri1_pp;         //enable discri1 power pulsing if discri0 enabled --default: 0 => off
assign param592b[335]     = En_discri2_pp;         //enable discri2 power pulsing if discri0 enabled --default: 0 => off
assign param592b[334]     = En_discri0_pp;         //enable discri0 for power pulsing   --default: 0 => off
assign param592b[333]     = En_otaq_pp;            //enable otaq for power pulsing      --default: 0 => off
assign param592b[332]     = En_otaq;               //enable selected Charge outputs     --default: 0 => off
assign param592b[331]     = En_dac4bit_pp;         //enable 4-bit DAC for power pulsing --default: 0 => off
//----Channel 4-bit DAC adjustment---//
assign param592b[330:75]  = Chn_adjust;            //channel 4-bit DAC adjustment
//-------------BIAS-----------------//
assign param592b[74:73]   = Sw_hg;                 //switch high gain shaper
                                                   //Reverse high bit and low
                                                   //bit,the top level should
                                                   //also reverse.
assign param592b[72]      = Va_shlg_read;          //valid low gain shaper for read  --default: 1 => on
assign param592b[71]      = En_widlar_pp;          //enable widlar for power pulsing --default: 0 => off
assign param592b[70:69]   = Sw_lg;                 //switch low gain shaper
                                                   //Reverse high bit and low
                                                   //bit,the top level should
                                                   //also reverse.
assign param592b[68]      = En_shlg_pp;            //enable shaper low gain power pulsing --default: 0 => off
assign param592b[67]      = En_shhg_pp;            //enable shaper high gain power pulsing --default:0 => off
assign param592b[66]      = En_gbst;               //enable gain boost----default:1 => on
assign param592b[65]      = En_Preamp_pp;          //enable preamplifier power pulsing -- default:0 => off
//--Enable test capacitor from chn0 ~ chn63---//
assign param592b[64:1]    = Ctest;                 //--------default value: 64x 0(all off)--------//
//----------push paramters into a fifo------------//
reg param_store_fifo_wr_en;
reg [15:0] param_store_fifo_din;
//-------------------------//
reg [591:0] param592b_shiftreg;
reg [63:0] Read_shiftreg;
reg [5:0] shift_cnt; //shift counter
reg [2:0] asic_cnt;  //asic counter
reg Process_Done;
reg [2:0] State;
localparam SC_NUM = 37-1;
localparam RE_NUM = 4-1;
localparam [3:0] Idle = 3'd0,
         READ_PROCESS = 3'd1,
    READ_PROCESS_LOOP = 3'd2,
    READ_PROCESS_ASIC = 3'd3,
           SC_PROCESS = 3'd4,
      SC_PROCESS_LOOP = 3'd5,
      SC_PROCESS_ASIC = 3'd6,
          END_PROCESS = 3'd7;
always @ (posedge Clk , negedge reset_n) begin
  if(~reset_n) begin
    //param_store_fifo_rst <= 1'b1; //reset fifo
    param_store_fifo_wr_en <= 1'b0;
    param_store_fifo_din <= 16'b0;
    State <= Idle;
    param592b_shiftreg <= 592'b0;
    Read_shiftreg <= 64'b0;
    shift_cnt <= 6'b0;
    asic_cnt <= 3'b0;
    Process_Done <= 1'b0;
  end
  else begin
    case (State)
      Idle:begin
        if(start) begin //judge whether it is sc or read register
          if(sc_or_read) begin
            State <= READ_PROCESS; //read register
            Read_shiftreg <= Read_reg; //load parameter
          end  
          else begin
            State <= SC_PROCESS; //slow control
            param592b_shiftreg <= param592b; //load parameter
          end
        end
        else
          State <= Idle; //no action
      end                                                   //Reverse high bit and low
                                                   //bit,the top level should
                                                   //also reverse.
      READ_PROCESS:begin
        param_store_fifo_wr_en <= 1'b1;
        param_store_fifo_din <= Read_shiftreg[63:48];
        State <= READ_PROCESS_LOOP;
      end
      READ_PROCESS_LOOP:begin
        param_store_fifo_wr_en <= 1'b0;
         if(shift_cnt < RE_NUM) begin
           State <= READ_PROCESS;
           Read_shiftreg <= Read_shiftreg << 16;
           shift_cnt <= shift_cnt + 1'b1;           
         end
         else begin
           shift_cnt <= 6'b0;
           State <= READ_PROCESS_ASIC; //
         end
      end
      READ_PROCESS_ASIC:begin
        if(asic_cnt < asic_num - 1'b1) begin
          asic_cnt <= asic_cnt + 1'b1;
          Read_shiftreg <= Read_reg; //reload parameter
          State <= READ_PROCESS;
        end
        else begin
          asic_cnt <= 3'b0;
          State <= END_PROCESS;
          Process_Done <= 1'b1;
        end
      end
      SC_PROCESS:begin
        param_store_fifo_wr_en <= 1'b1;
        param_store_fifo_din <= param592b_shiftreg[591:576];
        State <= SC_PROCESS_LOOP;
      end
      SC_PROCESS_LOOP:begin
        param_store_fifo_wr_en <= 1'b0;
         if(shift_cnt < SC_NUM) begin
           State <= SC_PROCESS;
           param592b_shiftreg <= param592b_shiftreg << 16;
           shift_cnt <= shift_cnt + 1'b1;           
         end
         else begin
           shift_cnt <= 6'b0;
           State <= SC_PROCESS_ASIC; 
         end
      end
      SC_PROCESS_ASIC:begin
        asic_cnt <= 3'b0;
        State <= END_PROCESS;
        Process_Done <= 1'b1;
        /*if(asic_cnt < asic_num - 1'b1) begin
          asic_cnt <= asic_cnt + 1'b1;
          param592b_shiftreg <= param592b; //reload parameter
          State <= SC_PROCESS;
        end
        else begin
          asic_cnt <= 3'b0;
          State <= END_PROCESS;
          Process_Done <= 1'b1;
        end*/
      end      
      END_PROCESS:begin
        Process_Done <= 1'b0;
        State <= Idle;
      end
      default: State <= Idle;
    endcase
  end
end
//----------assignment--------------------//
assign ext_fifo_wr_en = param_store_fifo_wr_en;
assign ext_fifo_din = param_store_fifo_din;
assign Done = Process_Done;
endmodule

