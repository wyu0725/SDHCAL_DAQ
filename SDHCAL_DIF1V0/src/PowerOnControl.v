`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/05/28 11:12:01
// Design Name:
// Module Name: PowerOnControl
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


module PowerOnControl(
	input PowerPulsingPinEnable,
	input PowerOnAnalog,
	input PowerOnDigital,
	input PowerOnAdc,
	input PowerOnDac,
	output PWR_ON_A,
	output PWR_ON_D,
	output PWR_ON_ADC,
	output PWR_ON_DAC
	);
	assign PWR_ON_D = PowerPulsingPinEnable ? PowerOnDigital : 1'b1;
	assign PWR_ON_A = PowerPulsingPinEnable ? PowerOnAnalog: 1'b1;
	assign PWR_ON_ADC = PowerPulsingPinEnable ? PowerOnAdc : 1'b1;
	assign PWR_ON_DAC = PowerPulsingPinEnable ? PowerOnDac : 1'b1;
endmodule
