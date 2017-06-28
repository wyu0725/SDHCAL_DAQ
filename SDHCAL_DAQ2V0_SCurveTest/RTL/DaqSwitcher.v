`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/06/28 22:03:34
// Design Name: 
// Module Name: DaqSwitcher
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DaqSwitcher(
    input DaqSelect,
    // Power pulsing control
    input AutoDaq_PWR_ON_A,
    input AutoDaq_PWR_ON_D,
    input AutoDaq_PWR_ON_ADC,
    input AutoDaq_PWR_ON_DAC,
    input SlaveDaq_PWR_ON_A,
    input SlaveDaq_PWR_ON_D,
    input SlaveDaq_PWR_ON_ADC,
    input SlaveDaq_PWR_ONDAC,
    output PWR_ON_D,
    output PWR_ON_A,
    output PWR_ON_ADC,
    output PWR_ON_DAC,
    // Pin
    input AutoDaq_RESET_B,
    input SlaveDaq_RESET_B,
    output RESET_B
    input AutoDaq_START_ACQ,
    input SlaveDaq_START_ACQ,
    output START_ACQ,

    // StartAcqSignal
    input UsbAcqStart,
    output AutoAcq_Start,
    output SlaveAcq_Start,
    
    
    );
endmodule
