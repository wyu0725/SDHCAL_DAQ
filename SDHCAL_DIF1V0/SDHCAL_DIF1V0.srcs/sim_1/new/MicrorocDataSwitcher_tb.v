`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:38:44 07/17/2018
// Design Name:   MicrorocDataSwitcher
// Module Name:   C:/WangYu/TestBenchInst/MicrorocDataSwitcher_tb.v
// Project Name:  TestBenchInst
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MicrorocDataSwitcher
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module MicrorocDataSwitcher_tb;

	// Inputs
	reg Clk;
	reg reset_n;
	reg AcquisitionStart;
  reg EndReadout;
	reg [15:0] MicrorocChain1Data;
	reg MicrorocChain1DataEnable;
	reg [15:0] MicrorocChain2Data;
	reg MicrorocChain2DataEnable;
	reg [15:0] MicrorocChain3Data;
	reg MicrorocChain3DataEnable;
	reg [15:0] MicrorocChain4Data;
	reg MicrorocChain4DataEnable;

	// Outputs
	wire [15:0] MicrorocAcquisitionData;
	wire MicrorocAcquisitionDataEnable;

	// Instantiate the Unit Under Test (UUT)
	MicrorocDataSwitcher uut (
		.Clk(Clk), 
		.reset_n(reset_n), 
		.AcquisitionStart(AcquisitionStart),
    .EndReadout(EndReadout), 
		.MicrorocChain1Data(MicrorocChain1Data), 
		.MicrorocChain1DataEnable(MicrorocChain1DataEnable), 
		.MicrorocChain2Data(MicrorocChain2Data), 
		.MicrorocChain2DataEnable(MicrorocChain2DataEnable), 
		.MicrorocChain3Data(MicrorocChain3Data), 
		.MicrorocChain3DataEnable(MicrorocChain3DataEnable), 
		.MicrorocChain4Data(MicrorocChain4Data), 
		.MicrorocChain4DataEnable(MicrorocChain4DataEnable), 
		.MicrorocAcquisitionData(MicrorocAcquisitionData), 
		.MicrorocAcquisitionDataEnable(MicrorocAcquisitionDataEnable)
	);

	initial begin
		// Initialize Inputs
		Clk = 1'b0;
		reset_n = 1'b1;
		AcquisitionStart = 1'b0;
    EndReadout = 1'b0;
		MicrorocChain1Data = 16'b0;
		MicrorocChain1DataEnable = 1'b0;
		MicrorocChain2Data = 16'b0;
		MicrorocChain2DataEnable = 1'b0;
		MicrorocChain3Data = 16'b0;
		MicrorocChain3DataEnable = 1'b0;
		MicrorocChain4Data = 16'b0;
		MicrorocChain4DataEnable = 1'b0;

		// Wait 100 ns for global reset to finish
    #100;
    reset_n = 1'b0;
		#100;
    reset_n = 1'b1;
    AcquisitionStart = 1'b1;
    #1000;
    #25;//1
    MicrorocChain1DataEnable = 1'b1;
    MicrorocChain2DataEnable = 1'b1;
    MicrorocChain3DataEnable = 1'b1;
    MicrorocChain4DataEnable = 1'b1;
    MicrorocChain1Data = 16'hABCD;
    MicrorocChain2Data = 16'hBCDE;
    MicrorocChain3Data = 16'hCCDD;
    MicrorocChain4Data = 16'hEFAB;
    #25;
    MicrorocChain1DataEnable = 1'b0;
    MicrorocChain2DataEnable = 1'b0;
    MicrorocChain3DataEnable = 1'b0;
    MicrorocChain4DataEnable = 1'b0;
    #25;//2
    MicrorocChain1DataEnable = 1'b1;
    MicrorocChain2DataEnable = 1'b1;
    MicrorocChain3DataEnable = 1'b1;
    MicrorocChain4DataEnable = 1'b1;
    MicrorocChain1Data = 16'hBBCC;
    MicrorocChain2Data = 16'hFFDD;
    MicrorocChain3Data = 16'hACBD;
    MicrorocChain4Data = 16'hAEFC;
    #25;
    MicrorocChain1DataEnable = 1'b0;
    MicrorocChain2DataEnable = 1'b0;
    MicrorocChain3DataEnable = 1'b0;
    MicrorocChain4DataEnable = 1'b0;
    #25;//3
    MicrorocChain1DataEnable = 1'b1;
    MicrorocChain2DataEnable = 1'b1;
    MicrorocChain3DataEnable = 1'b1;
    MicrorocChain4DataEnable = 1'b1;
    MicrorocChain1Data = 16'h1123;
    MicrorocChain2Data = 16'hCD3F;
    MicrorocChain3Data = 16'hCAE4;
    MicrorocChain4Data = 16'h1896;
    #25;
    MicrorocChain1DataEnable = 1'b0;
    MicrorocChain2DataEnable = 1'b0;
    MicrorocChain3DataEnable = 1'b0;
    MicrorocChain4DataEnable = 1'b0;
    #25;//4
    MicrorocChain1DataEnable = 1'b1;
    MicrorocChain2DataEnable = 1'b1;
    MicrorocChain3DataEnable = 1'b1;
    MicrorocChain4DataEnable = 1'b1;
    MicrorocChain1Data = 16'hA13F;
    MicrorocChain2Data = 16'hBC3E;
    MicrorocChain3Data = 16'hC78D;
    MicrorocChain4Data = 16'hE98B;
    #25;
    MicrorocChain1DataEnable = 1'b0;
    MicrorocChain2DataEnable = 1'b0;
    MicrorocChain3DataEnable = 1'b0;
    MicrorocChain4DataEnable = 1'b0;
    #25;//5
    MicrorocChain1DataEnable = 1'b1;
    MicrorocChain2DataEnable = 1'b1;
    MicrorocChain3DataEnable = 1'b1;
    MicrorocChain4DataEnable = 1'b1;
    MicrorocChain1Data = 16'hABC4;
    MicrorocChain2Data = 16'hBCD3;
    MicrorocChain3Data = 16'hCCD4;
    MicrorocChain4Data = 16'hEFA2;
    #25;
    MicrorocChain1DataEnable = 1'b0;
    MicrorocChain2DataEnable = 1'b0;
    MicrorocChain3DataEnable = 1'b0;
    MicrorocChain4DataEnable = 1'b0;
    #25;//6
    MicrorocChain1DataEnable = 1'b1;
    MicrorocChain2DataEnable = 1'b1;
    MicrorocChain3DataEnable = 1'b1;
    MicrorocChain4DataEnable = 1'b1;
    MicrorocChain1Data = 16'hAB3D;
    MicrorocChain2Data = 16'hBC4E;
    MicrorocChain3Data = 16'h3CDD;
    MicrorocChain4Data = 16'hECAB;
    #25;
    MicrorocChain1DataEnable = 1'b0;
    MicrorocChain2DataEnable = 1'b0;
    MicrorocChain3DataEnable = 1'b0;
    MicrorocChain4DataEnable = 1'b0;
    #25;
    EndReadout = 1'b1;
    #2525;
    EndReadout = 1'b0;
    #200;
    EndReadout = 1'b1;
    #2525;
    EndReadout = 1'b0;
	end

  localparam LOW = 13;
  localparam HIGH = 12;
  always begin
    #(LOW) Clk = ~Clk;
    #(HIGH) Clk = ~Clk;
  end
endmodule

