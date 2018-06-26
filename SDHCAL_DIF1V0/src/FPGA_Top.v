`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/05/21 10:57:19
// Design Name:
// Module Name: FPGA_Top
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
//////////////////////////////////////////////////////////////////
//																//
//                                                    `:/+:		//
//                                                 .odNmydMs	//
//                                               :hMNy: `dMh	//
//     ./+oo+-   -://////+oo`  `:/ooso/`       :dMNy.  .dMm-	//
//   /dNy/:/hM/ odyNMmssso+. +dNNd+/+yMM/    .hMMh- ..oNMd-		//
// `hMd-     -  ` .MMo      -m+sMN-   mMy   /NMN+ .yMMMNs`		//	
// yMm.         `ymMMmddd+  .- dMd` -hMh.  yMMd- :NMMNy.		//	
// NMh          .:NMh...`   .ymMMmdmds:   yMMm.  /dd+.    `		//
// dMm.    `+h`  :MM/         yMm-`      :MMN/         `oh-		//
// .hMNysydNd+   /MMdyyhdd`  `NMs        sMMN.       :yd+`		//
//   ./++/:.      ./++/:-`   -mm:        /MMMh:..-+ymd/`		//
//                                        +mMMMMMNdo-			//
//                                          .:/:-`				//
//																//
//////////////////////////////////////////////////////////////////
module FPGA_Top(
	input Clk40M,
	input rst_n
	);
	MicrorocControl MicrorocChain1(
		);
	MicrorocControl MicrorocChain2(
	
		);
	/*-----------USB2.0 instantiation------------*/
    wire [15:0] in_from_ext_fifo_dout;
    wire out_to_ext_fifo_rd_en;
    wire out_to_Microroc_SC_Param_Load;
    wire UsbStartStop;
    usb_synchronous_slavefifo usb_cy7c68013A
    (
      .IFCLK(IFCLK),
      .FLAGA(FLAGA),
      .FLAGB(FLAGB),
      .FLAGC(FLAGC),
      .nSLCS(nSLCS),
      .nSLOE(nSLOE),
      .nSLRD(nSLRD),
      .nSLWR(nSLWR),
      .nPKTEND(nPKTEND),
      .FIFOADR(FIFOADR),
      .FD_BUS(FD_BUS),
      .Acq_Start_Stop(UsbStartStop),
      .Ctr_rd_en(in_from_usb_Ctr_rd_en),              //fifo interface
      .ControlWord(in_from_usb_ControlWord),          //fifo interface
      .in_from_ext_fifo_dout(in_from_ext_fifo_dout),  //fifo interface
      .in_from_ext_fifo_empty(in_from_ext_fifo_empty),//fifo interface
      .out_to_ext_fifo_rd_en(out_to_ext_fifo_rd_en)   //fifo interface
    );
endmodule
