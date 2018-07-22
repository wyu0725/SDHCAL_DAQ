`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:28:08 07/19/2018
// Design Name:   RamReadDoneSync4Chain
// Module Name:   C:/WangYu/TestBenchInst/RamReadDoneSync4Chain_tb.v
// Project Name:  TestBenchInst
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: RamReadDoneSync4Chain
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module RamReadDoneSync4Chain_tb;

	// Inputs
	reg Clk;
	reg reset_n;
	reg [3:0] OnceEnd;
	reg [3:0] EndReadoutParameter;

	// Outputs
	wire RamReadoutDone;

	// Instantiate the Unit Under Test (UUT)
	RamReadDoneSync4Chain uut (
		.Clk(Clk), 
		.reset_n(reset_n), 
		.OnceEnd(OnceEnd), 
		.EndReadoutParameter(EndReadoutParameter), 
		.RamReadoutDone(RamReadoutDone)
	);

	initial begin
		// Initialize Inputs
		Clk = 1'b0;
		reset_n = 1'b0;
		OnceEnd = 4'd0;
		EndReadoutParameter = 4'b1111;

		// Wait 100 ns for global reset to finish
		#100;
    reset_n = 1'b1;
    #1000;
    OnceEnd <= 4'b0101;
    #25;
    OnceEnd <= 4'b0000;
    #200;
    OnceEnd = 4'b1111;
    #25;
    OnceEnd = 4'b0;
    #100;
    EndReadoutParameter = 4'b0011;
    #1000;
    OnceEnd = 4'b0011;
    #1000;
    EndReadoutParameter = 4'b1111;
    OnceEnd = 4'b0000;
    #100;
    OnceEnd = 4'b0001;
    #200;
    OnceEnd = 4'b0011;
    #300;
    OnceEnd = 4'b0111;
    #400;
    OnceEnd = 4'b1111;
        
		// Add stimulus here

	end
  localparam LOW = 13;
  localparam HIGH = 12;
  always begin
    #(LOW) Clk = ~Clk;
    #(HIGH) Clk = ~Clk;
  end
endmodule

