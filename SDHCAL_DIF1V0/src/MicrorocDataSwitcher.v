`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Yu Wang
//
// Create Date: 2018/07/16 20:56:19
// Design Name: SDHCAL DIF 1V0
// Module Name: MicrorocDataSwitcher
// Project Name: SDHCAL DIF 1V0
// Target Devices: XC7A100TFGG484-2L
// Tool Versions: Vivado 2018.1
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module MicrorocDataSwitcher(
  input Clk,
  input reset_n,
  input AcquisitionStart,
  input EndReadout,
  input [15:0] MicrorocChain1Data,
  input MicrorocChain1DataEnable,
  input [15:0] MicrorocChain2Data,
  input MicrorocChain2DataEnable,
  input [15:0] MicrorocChain3Data,
  input MicrorocChain3DataEnable,
  input [15:0] MicrorocChain4Data,
  input MicrorocChain4DataEnable,
  output reg [15:0] MicrorocAcquisitionData,
  output reg MicrorocAcquisitionDataEnable
  );

  reg EndReadout_r1;
  reg EndReadout_r2;
  wire EndReadoutRising;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      EndReadout_r1 <= 1'b0;
      EndReadout_r2 <= 1'b0;
    end
    else begin
      EndReadout_r1 <= EndReadout;
      EndReadout_r2 <= EndReadout_r1;
    end
  end
  assign EndReadoutRising = EndReadout_r1 & ~EndReadout_r2;

  reg [3:0] State;
  localparam [3:0]
  IDLE         = 4'd0,
  WAIT         = 4'd1,
  FIFO_DETECT  = 4'd2,
  FIFO1_READ   = 4'd4,
  FIFO2_READ   = 4'd5,
  FIFO3_READ   = 4'd6,
  FIFO4_READ   = 4'd7,
  FIFO_DATAOUT = 4'd8,
  DONE         = 4'd9;
  reg Fifo1ReadEnable;
  reg Fifo2ReadEnable;
  reg Fifo3ReadEnable;
  reg Fifo4ReadEnable;
  wire [15:0] Fifo1Data;
  wire [15:0] Fifo2Data;
  wire [15:0] Fifo3Data;
  wire [15:0] Fifo4Data;
  wire Fifo1Empty;
  wire Fifo2Empty;
  wire Fifo3Empty;
  wire Fifo4Empty;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n)begin
      Fifo1ReadEnable <= 1'b0;
      Fifo2ReadEnable <= 1'b0;
      Fifo3ReadEnable <= 1'b0;
      Fifo4ReadEnable <= 1'b0;
      MicrorocAcquisitionData <= 16'b0;
      MicrorocAcquisitionDataEnable <= 16'b0;
      State <= IDLE;
    end
    else begin
      case(State)
        IDLE: begin
          if(AcquisitionStart)
            State <= WAIT;
          else
            State <= IDLE;
        end
        WAIT:begin
          if(~AcquisitionStart) begin
            State <= DONE;
          end
          else if(EndReadoutRising) begin
            State <= FIFO_DETECT;
          end
          else begin
            State <= WAIT;
          end
        end
        FIFO_DETECT:begin
          MicrorocAcquisitionDataEnable <= 1'b0;
          if(~Fifo1Empty) begin
            Fifo1ReadEnable <= 1'b1;
            State <= FIFO1_READ;
          end
          else if(~Fifo2Empty) begin
            Fifo2ReadEnable <= 1'b1;
            State <= FIFO2_READ;
          end
          else if(~Fifo3Empty) begin
            Fifo3ReadEnable <= 1'b1;
            State <= FIFO3_READ;
          end
          else if(~Fifo4Empty) begin
            Fifo4ReadEnable <= 1'b1;
            State <= FIFO4_READ;
          end
          else begin
            Fifo1ReadEnable <= 1'b0;
            Fifo2ReadEnable <= 1'b0;
            Fifo3ReadEnable <= 1'b0;
            Fifo4ReadEnable <= 1'B0;
            State <= WAIT;
          end
        end
        FIFO1_READ:begin
          Fifo1ReadEnable <= 1'b0;
          MicrorocAcquisitionData <= Fifo1Data;
          State <= FIFO_DATAOUT;
        end
        FIFO2_READ:begin
          Fifo2ReadEnable = 1'b0;
          MicrorocAcquisitionData <= Fifo2Data;
          State <= FIFO_DATAOUT;
        end
        FIFO3_READ:begin
          Fifo3ReadEnable <= 1'b0;
          MicrorocAcquisitionData <= Fifo3Data;
          State <= FIFO_DATAOUT;
        end
        FIFO4_READ:begin
          Fifo4ReadEnable <= 1'b0;
          MicrorocAcquisitionData <= Fifo4Data;
          State <= FIFO_DATAOUT;
        end
        FIFO_DATAOUT:begin
          MicrorocAcquisitionDataEnable <= 1'b1;
          State <= FIFO_DETECT;
        end
        DONE:begin
          State <= IDLE;
        end
        default:State <= IDLE;
      endcase
    end
  end

  MicrorocChainDataFifo MicrorocChain1DataFIFO (
    .clk        (~Clk),                      // input wire clk
    .rst        (~reset_n),                  // input wire rst
    .din        (MicrorocChain1Data),       // input wire [15 : 0] din
    .wr_en      (MicrorocChain1DataEnable), // input wire wr_en
    .rd_en      (Fifo1ReadEnable),          // input wire rd_en
    .dout       (Fifo1Data),                // output wire [15 : 0] dout
    .full       (),                         // output wire full
    .empty      (Fifo1Empty),               // output wire empty
    .wr_rst_busy(),                         // output wire wr_rst_busy
    .rd_rst_busy()                          // output wire rd_rst_busy
    );

  MicrorocChainDataFifo MicrorocChain2DataFIFO (
    .clk        (~Clk),                      // input wire clk
    .rst        (~reset_n),                  // input wire rst
    .din        (MicrorocChain2Data),       // input wire [15 : 0] din
    .wr_en      (MicrorocChain2DataEnable), // input wire wr_en
    .rd_en      (Fifo2ReadEnable),          // input wire rd_en
    .dout       (Fifo2Data),                // output wire [15 : 0] dout
    .full       (),                         // output wire full
    .empty      (Fifo2Empty),               // output wire empty
    .wr_rst_busy(),                         // output wire wr_rst_busy
    .rd_rst_busy()                          // output wire rd_rst_busy
    );

  MicrorocChainDataFifo MicrorocChain3DataFIFO (
    .clk        (~Clk),                      // input wire clk
    .rst        (~reset_n),                  // input wire rst
    .din        (MicrorocChain3Data),       // input wire [15 : 0] din
    .wr_en      (MicrorocChain3DataEnable), // input wire wr_en
    .rd_en      (Fifo3ReadEnable),          // input wire rd_en
    .dout       (Fifo3Data),                // output wire [15 : 0] dout
    .full       (),                         // output wire full
    .empty      (Fifo3Empty),               // output wire empty
    .wr_rst_busy(),                         // output wire wr_rst_busy
    .rd_rst_busy()                          // output wire rd_rst_busy
    );

  MicrorocChainDataFifo MicrorocChain4DataFIFO (
    .clk        (~Clk),                      // input wire clk
    .rst        (~reset_n),                  // input wire rst
    .din        (MicrorocChain4Data),       // input wire [15 : 0] din
    .wr_en      (MicrorocChain4DataEnable), // input wire wr_en
    .rd_en      (Fifo4ReadEnable),          // input wire rd_en
    .dout       (Fifo4Data),                // output wire [15 : 0] dout
    .full       (),                         // output wire full
    .empty      (Fifo4Empty),               // output wire empty
    .wr_rst_busy(),                         // output wire wr_rst_busy
    .rd_rst_busy()                          // output wire rd_rst_busy
    );
endmodule
