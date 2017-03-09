`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: University of Science and Technology of China
// Engineer: Junbin Zhang
// 
// Create Date: 11/14/2016 02:27:41 PM
// Design Name: SDHCAL_DAQ2V0
// Module Name: SlowControl_ReadReg
// Project Name: SDHCAL_DAQ2V0
// Target Devices: XC7A100TFGG484
// Tool Versions: Vivado 2016.3
// Description: Top level of slow control and read register
//this module for slowcontrol Read and Control register <top muodule>
//General discription: 2 shift registers are integrated: a read register to
//select one channel among 64 and a SC register to load serially  the SC
//parameters.The data input 'sr_in', clock 'sr_ck' and reset 'sr_rstb' are
//sent to the SC or Read register inputs depending of the level of external
//signal 'select'. when select = 0 the inputs are connected to the read
//register, when select =1, the inputs are connected to the SC register.
//-----------------------------show control-------------------------------//
 
//General discription: show control used to configure the chip.
//The FPGA load the slow control which is a shift register. If the chip
//contains N parameters,you have to send N clock ticks @sr_ck and put your
//parameter @ sr_in. The chip capture the data on rising edge so the data
//should be present on the falling edge of sr_ck. sr_ck frequency often use is
//about 1MHz. The sr_out output is the end of the shift register(clocked on
//the falling edge) If you push new parameters @sr_in, sr_out outputs the
//previously load parameters. This is often used when chips were daisy
//chained. 
//Hardroc2b contains 872 slow control parameters.
//Microroc2 contains 592 slow control parameters.

//------------------------------read register-----------------------------//

//General discription: the read register is used to readout the charge output,
//the output of the selected fast shaper, and also the trigger outputs.
//1.Readout multiplexed (1 over 64) charge output on pin "out_q"
//2.Readout the selected (1 over 3) fast shaper of a channel(1 over 64) on pin
//"out_fsb"
//3.Readout the 3 triggers of a selected channel(1 over 64) on pin "out_trigxb"
//----need confirmation
//the read register is a shift register of 64(64channels).You must send one
//'1' and 63 '0'(one-hot encoding). the position of the '1' gives you the
//channel selected. In All cases you have to reset the 'read register'(even if
//you do not use it).
//How to readout a fast shaper of a channel on pin "out_fsb"? Here is the procedure :
//1) you select the desired channel with the "read register". Ex: to select channel 3 
//(ch range is 0 to 63) you have to put in HEXA "0000 0000 0000 0008" (in binary end is 00001000")
//2) you select the desired shaper (HG/LG) with the SC bit "valid_sh_hg" (sc bit 72) 
//3) you can look signal @ out_sh pin 128
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 

//////////////////////////////////////////////////////////////////////////////////

module SlowControl_ReadReg

(

  input Clk,
  input Clk_5M,
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
  //--------ASIC Pin---------------------------//
  output SELECT, //select = 1,slowcontrol register; select = 0,read register
  output SR_RSTB,//Selected Register Reset
  output SR_CK,  //Selected Register Clock
  output SR_IN,  //Selected Register Input
  //input  SR_OUT, //Selected Register Output,Asic's daisy chain slow control output
  //---------------------------------------------//
  output Config_Done

);

// 4 submodules

wire ext_fifo_wr_en;

wire [15:0] ext_fifo_din;

wire Done;

Microroc_Parameters Microroc_Param

(

  .Clk(Clk),

  .reset_n(reset_n),

  .sc_or_read(sc_or_read),

  .start(start),

  .asic_num(asic_num),

  .En_dout(En_dout),

  .En_transmiton(En_transmiton),

  .En_chipsatb(En_chipsatb),

  .Sel_startreadout(Sel_startreadout),

  .Sel_endreadout(Sel_endreadout),

  .Sel_raz(Sel_raz),

  .Ck_mux(Ck_mux),

  .Sc_on(Sc_on),

  .Raz_chn_ext_validation(Raz_chn_ext_validation),

  .Raz_chn_int_validation(Raz_chn_int_validation),

  .Trig_ext_validation(Trig_ext_validation),

  .Disc_or_or(Disc_or_or),

  .En_trig_out(En_trig_out),

  .Trigb(Trigb),

  .DAC2_Vth(DAC2_Vth),

  .DAC1_Vth(DAC1_Vth),

  .DAC0_Vth(DAC0_Vth),

  .En_dac(En_dac),

  .En_dac_pp(En_dac_pp),

  .En_bg(En_bg),

  .En_bg_pp(En_bg_pp),

  .header(header),

  .Chn_discri_mask(Chn_discri_mask),

  .Rs_or_discri(Rs_or_discri),

  .En_discri1_pp(En_discri1_pp),

  .En_discri2_pp(En_discri2_pp),

  .En_discri0_pp(En_discri0_pp),

  .En_otaq_pp(En_otaq_pp),

  .En_otaq(En_otaq),

  .En_dac4bit_pp(En_dac4bit_pp),

  .Chn_adjust(Chn_adjust),

  .Sw_hg(Sw_hg),

  .Va_shlg_read(Va_shlg_read),

  .En_widlar_pp(En_widlar_pp),

  .Sw_lg(Sw_lg),

  .En_shlg_pp(En_shlg_pp),

  .En_shhg_pp(En_shhg_pp),

  .En_gbst(En_gbst),

  .En_Preamp_pp(En_Preamp_pp),

  .Ctest(Ctest),

  .Read_reg(Read_reg),

  .ext_fifo_wr_en(ext_fifo_wr_en),//

  .ext_fifo_din(ext_fifo_din),//

  .Done(Done)//

);

wire start_pulse;
//there needs a pulse synchronizer
PULSESYNC pulse_sync
(
  .clk_src(Clk),
  .reset_n(reset_n),
  .pulse_src(Done),//Done is a pulse, 40M clock domain, 
  .clk_dst(Clk_5M),
  .pulse_dst(start_pulse)//start pulse, 5M clock domain
);

wire [15:0] ext_fifo_data;

wire ext_fifo_empty;

wire ext_fifo_rden;

wire shift_done;

Param_Bitshift BitShift

(

  .Clk_5M(Clk_5M),

  .reset_n(reset_n),

  .start_pulse(start_pulse),

  .ext_fifo_data(ext_fifo_data),

  .ext_fifo_empty(ext_fifo_empty),

  .ext_fifo_rden(ext_fifo_rden),

  .sr_ck(SR_CK),

  .sr_rstb(SR_RSTB),

  .sr_in(SR_IN),

  .RunEnd(shift_done)//shift_done is a pulse,5M clock domain

);

//---16-bit width 256 deepth async FIFO instantiation---//

param_store_fifo param_store_fifo_16bitx256deep

(

  .rst(!reset_n || shift_done),

  .wr_clk(Clk),

  .wr_en(ext_fifo_wr_en),

  .din(ext_fifo_din),

  .full(),

  .rd_clk(Clk_5M),

  .rd_en(ext_fifo_rden),

  .dout(ext_fifo_data),

  .empty(ext_fifo_empty)

);

//-----------assignment------------------//

assign SELECT = !sc_or_read;

assign Config_Done = shift_done;

endmodule

