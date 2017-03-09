`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Science and Technology of China
// Engineer: Junbin Zhang
// 
// Create Date: 11/14/2016 02:27:41 PM
// Design Name: SDHCAL_DAQ2V0
// Module Name: Redundancy
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

module Redundancy
(
  input  PowPulsing_En,//1 enable, 0 disable
  input  Sel_Readout_chn,//1 chn1, 0 chn2
  //input  Sel_Monitor_Sig,//1 out_q, 0 power consumtion

  input  Pwr_on_d,  //from DaqControl
  input  Pwr_on_a,  //from DaqControl
  input  Pwr_on_adc,//from DaqControl
  input  Pwr_on_dac,//from DaqControl
  input  Start_Readout, //from DaqControl
  output End_Readout,   //out to DaqControl

  output Dout,         //out to Ramreadout
  output TransmitOn,   //out to Ramreadout

  output PWR_ON_D,   //PIN
  output PWR_ON_A,   //PIN
  output PWR_ON_ADC, //PIN
  output PWR_ON_DAC,  //PIN
  output START_READOUT1,//PIN
  output START_READOUT2,//PIN
  input  END_READOUT1,  //PIN
  input  END_READOUT2,  //PIN
  input  Dout1b,        //PIN
  input  Dout2b,        //PIN
  input  TransmitOn1b,  //PIN
  input  TransmitOn2b  //PIN
 // output ADG819_IN      //PIN
);
assign PWR_ON_D = PowPulsing_En ? Pwr_on_d : 1'b1;
assign PWR_ON_A = PowPulsing_En ? Pwr_on_a : 1'b1;
assign PWR_ON_ADC = PowPulsing_En ? Pwr_on_adc : 1'b1;
assign PWR_ON_DAC = PowPulsing_En ? Pwr_on_dac : 1'b1;

assign End_Readout = Sel_Readout_chn ? END_READOUT1 : END_READOUT2;
assign START_READOUT1 = Sel_Readout_chn ? Start_Readout : 1'b0;
assign START_READOUT2 = Sel_Readout_chn ? 1'b0 : Start_Readout;

assign Dout = Sel_Readout_chn ? Dout1b : Dout2b;
assign TransmitOn = Sel_Readout_chn ? TransmitOn1b : TransmitOn2b;

//assign ADG819_IN = Sel_Monitor_Sig ? 1'b1 : 1'b0;
endmodule
