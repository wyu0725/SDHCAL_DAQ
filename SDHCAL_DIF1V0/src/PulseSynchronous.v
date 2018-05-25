`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/24 16:27:18
// Design Name: 
// Module Name: PulseSynchronous
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


module PulseSynchronous (
    input ClkSource,
    input reset_n,
    input PulseSource,
    input ClkDestination,
    output PulseDestination
    );
	reg Toggle;
	always @ (posedge ClkSource or negedge reset_n) begin
		if(~reset_n)
			Toggle <= 1'b0;
		else if(PulseSource)
			Toggle <= ~Toggle;
	end
	reg [2:0] SynchronousReg;
	always @ (posedge ClkDestination) begin
		if(~reset_n)
			SynchronousReg <= 3'b0;
		else
			SynchronousReg <= {SynchronousReg[1:0], Toggle};
	end
	assign PulseDestination = SynchronousReg[1] ^ SynchronousReg[2];
endmodule
