`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Science and Technology of China
// Engineer: Junbin Zhang
// 
// Create Date: 11/14/2016 02:27:41 PM
// Design Name: SDHCAL_DAQ2V0
// Module Name: Microroc_top
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


module Microroc_top(
      input Clk,
      input Clk_5M,
      input reset_n,
      input MicrorocForceReset,// New add by wyu 20170519
      //--------Microroc slow control registers interaface----------//
      input sc_or_read, //slow control or read? 1 => read register
      input start_load,      //start load parameters
      input [2:0] asic_num,//how many asics?
      //-----parameters-------//
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
      //--64bit read register-//
      input [63:0] Read_reg,
      //-----Redundancy interface---------//
      input PowPulsing_En,//1 enable, 0 disable
      input Sel_Readout_chn,//1 chn1, 0 chn2
      //------start_acq------------//
      input Acq_start, //level or a pulse?
      input [15:0] AcqStart_time,  //Acquisition time, get from USB, default8
      //------Hold gen interface-----//
      input [1:0] Trig_Coincid,
      input [4:0] Hold_delay,//hold delay,maxium 800ns
      //------fifo interface-----//
      input ext_fifo_full,
      output [15:0] parallel_data,
      output parallel_data_en,
      //--------Trig_Gen interface---//
      input rst_cntb,
      input Raz_en,
      input Force_RAZ,
      input Trig_en,
      input [1:0] Raz_mode,
      input [3:0] External_RAZ_Delay_Time,//Set delay time for external raz mode
      output Config_Done,
      /*---Slow control and ReadReg---*/
      output SELECT, //select = 1,slowcontrol register; select = 0,read register
      output SR_RSTB,//Selected Register Reset
      output SR_CK,  //Selected Register Clock
      output SR_IN,  //Selected Register Input
      //input  SR_OUT, //Selected Register Output,Asic's daisy chain slow control output
      //---power pulsing-----//
      output PWR_ON_D,
      output PWR_ON_A,
      output PWR_ON_DAC,
      output PWR_ON_ADC,
      //-------DAQ Control------//
      output START_ACQ,
      output RESET_B,
      input  CHIPSATB,
      output START_READOUT1,
      output START_READOUT2,
      input END_READOUT1,
      input END_READOUT2,
      //----RAM readout------//
      input DOUT1B, 
      input DOUT2B,
      input TRANSMITON1B,
      input TRANSMITON2B,
      //----hold gen---------//
      input OUT_TRIG0B,
      input OUT_TRIG1B,
      input OUT_TRIG2B,
      input EXT_TRIGB,//external pin
      output HOLD,
      //--Trig gen---------------//
      output TRIG_EXT,
      output RAZ_CHNP,
      output RAZ_CHNN,
      output VAL_EVTP,
      output VAL_EVTN,
      output RST_COUNTERB,
      //---clk gen--------//
      output CK_40P,
      output CK_40N,
      output CK_5P,
      output CK_5N,
      //---Test port---//
      output Start_Readout_t
    );
assign Start_Readout_t = Start_Readout;
//submodules instantiation
SlowControl_ReadReg SC_Readreg
(
   .Clk(Clk),

   .Clk_5M(Clk_5M),

   .reset_n(reset_n),

   .sc_or_read(sc_or_read), //slow control or read? 1 => read register

   .start(start_load),      //start load parameters, a pulse or a level?

   .asic_num(asic_num),//how many asics?

  //--------Microroc slow control registers----------//

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

   //------Microroc read register-------------//

   .Read_reg(Read_reg),

  //--------ASIC Pin---------------------------//

   .SELECT(SELECT), //select = 1,slowcontrol register; select = 0,read register

   .SR_RSTB(SR_RSTB),//Selected Register Reset

   .SR_CK(SR_CK),  //Selected Register Clock

   .SR_IN(SR_IN),  //Selected Register Input

   //.SR_OUT(SR_OUT), //Selected Register Output,Asic's daisy chain slow control output

   //----------------------------------------//

   .Config_Done(Config_Done)     
);

wire Pwr_on_d;
wire Pwr_on_a;
wire Pwr_on_adc;
wire Pwr_on_dac;
wire Start_Readout;
wire End_Readout;
wire Dout;
wire TransmitOn;
Redundancy Redundancy
(
   .PowPulsing_En(PowPulsing_En),//1 enable, 0 disable
   .Sel_Readout_chn(Sel_Readout_chn),//1 chn1, 0 chn2
   //.Sel_Monitor_Sig(),//1 out_q, 0 power consumtion
   .Pwr_on_d(Pwr_on_d),  //from DaqControl
   .Pwr_on_a(Pwr_on_a),  //from DaqControl
   .Pwr_on_adc(Pwr_on_adc),//from DaqControl
   .Pwr_on_dac(Pwr_on_dac),//from DaqControl
   .Start_Readout(Start_Readout), //from DaqControl
   .End_Readout(End_Readout),   //out to DaqControl

   .Dout(Dout),         //out to Ramreadout
   .TransmitOn(TransmitOn),   //out to Ramreadout

   .PWR_ON_D(PWR_ON_D),   //PIN
   .PWR_ON_A(PWR_ON_A),   //PIN
   .PWR_ON_ADC(PWR_ON_ADC), //PIN
   .PWR_ON_DAC(PWR_ON_DAC),  //PIN
   .START_READOUT1(START_READOUT1),//PIN
   .START_READOUT2(START_READOUT2),//PIN
   .END_READOUT1(END_READOUT1),  //PIN
   .END_READOUT2(END_READOUT2),  //PIN
   .Dout1b(DOUT1B),        //PIN
   .Dout2b(DOUT2B),        //PIN
   .TransmitOn1b(TRANSMITON1B),  //PIN
   .TransmitOn2b(TRANSMITON2B)  //PIN
);
wire ResetMicroroc_n;
assign ResetMicroroc_n = reset_n & (~MicrorocForceReset);
DaqControl AutoDAQ
(
   .Clk(Clk),         //40M
   .reset_n(ResetMicroroc_n),
   .start(Acq_start), //a pulse or a level?
   .End_Readout(End_Readout), //Digitial RAM end reading signal, Active H
   .Chipsatb(CHIPSATB),    //Chip is full, Active L, PIN
   .T_acquisition(AcqStart_time),//Get from USB, default 8
   .Reset_b(RESET_B),      //Reset ASIC digital part, PIN
   .Start_Acq(START_ACQ),  //Start & maintain acquisition, Active H,PIN
   .Start_Readout(Start_Readout),//Digital RAM start reading signal
   .Pwr_on_a(Pwr_on_a),  //Analogue Part Power Pulsing control, active H
   .Pwr_on_d(Pwr_on_d),  //Digital Power Pulsing control, active H
   .Pwr_on_adc(Pwr_on_adc),//Slow shaper Power Pulsing Control, active H
   .Pwr_on_dac(Pwr_on_dac),//DAC Power Pulsing Control, Active H
   .Once_end() //a pulse
);

RamReadOut RAM_Read
(
   .Clk(Clk),
   .reset_n(ResetMicroroc_n),  
   .Dout(Dout), //pin Active L
   .TransmitOn(TransmitOn),//pin  Active L
   //--fifo access-----------//
   .ext_fifo_full(ext_fifo_full),
   .parallel_data(parallel_data),
   .parallel_data_en(parallel_data_en)
);
wire Single_RAZ_en;
Hold_Gen Hold_Gen
(
   .Clk(Clk),          //40MHz
   .reset_n(reset_n),
   .Trig_Coincid(Trig_Coincid),
   .Hold_delay(Hold_delay),//hold delay,maxium 800ns
   .OUT_TRIG0B(OUT_TRIG0B),   //active, low
   .OUT_TRIG1B(OUT_TRIG1B),   //active, low
   .OUT_TRIG2B(OUT_TRIG2B),   //active, low
   .Ext_TRIGB(EXT_TRIGB),    //active,low from SMA
   .HOLD(HOLD),         //Hold signal, Active high
   .External_RAZ_en(Raz_en),//Gengerate the Single raz signal from the trigger falling edge. New add by wyu 20170309
   .External_RAZ_Delay_Time(External_RAZ_Delay_Time),
   .Single_RAZ_en(Single_RAZ_en)
);

wire Raz_chn;
wire Val_evt;
wire Trig_en_i;//Modefied by wyu for RAM test
Internal_Trig_Gen Trig_Gen_en
(
  .Clk(Clk),
  .reset_n(reset_n),
  .start_acq(START_ACQ),
  .Trig_en(Trig_en),
  .trig_en_i(Trig_en_i)
);
Trig_Gen Trig_Gen
(
   .Clk(Clk),
   .reset_n(reset_n),
   .rst_cntb(rst_cntb),
   .Raz_en(Single_RAZ_en),
   .Force_RAZ(Force_RAZ),
   .Trig_en(Trig_en_i),//Modefied by wyu for RAM test
   .Raz_mode(Raz_mode),
   .Raz_chn(Raz_chn), //the width of the pulse must be changed according to the chosen peaking time to avoid "re-triggering"
   .Val_evt(Val_evt), //should be kept to "1"
   .Rst_counterb(RST_COUNTERB),//width of 1us, reset of 24bit counter BCID
   .Trig_ext(TRIG_EXT) //trigger to memory write
);
// OBUFDS: Differential Output Buffer
  OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) OBUFDS_Raz (
      .O(RAZ_CHNP),     // Diff_p output (connect directly to top-level port)
      .OB(RAZ_CHNN),   // Diff_n output (connect directly to top-level port)
      .I(Raz_chn)      // Buffer input 
   );
// OBUFDS: Differential Output Buffer  
    OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) OBUFDS_evt (
      .O(VAL_EVTP),     // Diff_p output (connect directly to top-level port)
      .OB(VAL_EVTN),   // Diff_n output (connect directly to top-level port)
      .I(Val_evt)      // Buffer input 
   );
 // OBUFDS: Differential Output Buffer  
    OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) OBUFDS_Clk40 (
      .O(CK_40P),     // Diff_p output (connect directly to top-level port)
      .OB(CK_40N),   // Diff_n output (connect directly to top-level port)
      .I(Clk)      // Buffer input 
   ); 
  // OBUFDS: Differential Output Buffer  
    OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) OBUFDS_Clk5 (
      .O(CK_5P),     // Diff_p output (connect directly to top-level port)
      .OB(CK_5N),   // Diff_n output (connect directly to top-level port)
      .I(Clk_5M)      // Buffer input 
   );   
endmodule
