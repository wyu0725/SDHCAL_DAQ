`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/05/25 14:50:01
// Design Name:
// Module Name: AsicRamReadout_tb
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


module AsicRamReadout_tb();
	reg ReadClk;
	reg reset_n;
	reg AsicDin;
	reg TransmitOn;
	wire [15:0] ExternalFifoData;
	wire ExternalFifoWriteEn;
	wire ReadDone;

	AsicRamReadout uut (
		.ReadClk(ReadClk),
		.reset_n(reset_n),
		.AsicDin(AsicDin),
		.TransmitOn(TransmitOn),
		.ExternalFifoData(ExternalFifoData),
		.ExternalFifoWriteEn(ExternalFifoWriteEn),
		.ReadDone(ReadDone)
		);
	localparam PEROID = 200;
	initial begin
		ReadClk = 1'b0;
		reset_n = 1'b0;
		AsicDin = 1'b0;
		TransmitOn = 1'b1;
		#150;
		reset_n = 1'b1;
		#1000;
		TransmitOn = 1'b0;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;//16
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;//16
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;
		#PEROID;
		AsicDin = 1'b0;
		#PEROID;
		AsicDin = 1'b1;//16
		TransmitOn = 1'b1;
		#PEROID;
		AsicDin = 1'bz;
		

	end

	always #(PEROID/2) ReadClk = ~ReadClk;
endmodule
