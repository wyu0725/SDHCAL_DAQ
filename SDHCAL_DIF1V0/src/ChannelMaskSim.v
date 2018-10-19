`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/10/19 09:38:37
// Design Name:
// Module Name: ChannelMaskSim
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

`include "CommandParameter.v"
module ChannelMaskSim(
  input Clk,
  input IFCLK,
  input reset_n,
  // USB interface
  input CommandWordEn,
  input [15:0] CommandWord,
  output reg [191:0] MicrorocChannelDiscriminatorMask
  );

// Command FIFO interface
  wire [15:0] COMMAND_WORD;
  reg CommandFifoReadEn;
  wire CommandFifoEmpty;
  wire FifoWriteResetBusy;
  wire FifoReadResetBusy;
  wire FifoReady;
  wire FifoFull;
  assign FifoReady = !FifoReadResetBusy & !FifoReadResetBusy;
  CommandFifo CommandFifo32Depth (
    .rst(!reset_n),                   // input wire rst
    .wr_clk(~IFCLK),                   // input wire wr_clk
    .rd_clk(~Clk),                     // input wire rd_clk
    .din(CommandWord),                // input wire [15 : 0] din
    .wr_en(CommandWordEn),            // input wire wr_en
    .rd_en(CommandFifoReadEn),        // input wire rd_en
    .dout(COMMAND_WORD),              // output wire [15 : 0] dout
    .full(FifoFull),                          // output wire full
    .empty(CommandFifoEmpty),         // output wire empty
    .wr_rst_busy(FifoWriteResetBusy), // output wire wr_rst_busy
    .rd_rst_busy(FifoReadResetBusy)   // output wire rd_rst_busy
    );

  //*** Read command
  localparam Idle = 1'b0;
  localparam READ = 1'b1;
  reg State;
  always @ (posedge Clk, negedge reset_n) begin
    if(~reset_n) begin
      CommandFifoReadEn <= 1'b0;
      State <= Idle;
    end
    else begin
      case (State)
        Idle:begin
          if(CommandFifoEmpty)
            State <= Idle;
          else begin
            CommandFifoReadEn <= 1'b1;
            State <= READ;
          end
        end
        READ:begin
          CommandFifoReadEn <= 1'b0;
          State <= Idle;
        end
        default:State <= Idle;
      endcase
    end
  end
  reg CommandFifoReadEnDelayed;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n)
      CommandFifoReadEnDelayed <= 1'b0;
    else
      CommandFifoReadEnDelayed <= CommandFifoReadEn;
  end

  //////////////////////////////////////////////////////////////
  // ChannelDiscriminatorMask
  //
  // Each discriminator of all channels can be masked by set the
  // corresponding bit to 0. The
  // 1. Set the mask channel
  //    MaskChannel[3:0], A2AX
  //    MaskChannel[5:4], A2BX
  // 2. Set the disciminator mask parameter
  //    3'b000: mask discri0,1,2
  //    3'b001: mask discri1,2
  //    3'b010: mask discri0,2
  //    3'b011: mask discri2
  //    3'b100: mask discri0,1
  //    3'b101: mask discri1
  //    3'b110: mask discri0
  //    3'b111: no mask
  //
  //    DiscriMask[2:0], A2CX
  // 3. Set Mask or Unmask all channel
  //    Maks A2D1
  //    Unmask A2D2
  //    MaskClear A0D3
  //
  ////////////////////////////////////////////////////////////////
  reg [7:0] MaskShift;
  wire [5:0] MaskChannel;
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'd3),
    .COMMAND_ADDRESS_AND_DEFAULT(`MaskChannel3to0_CAND)
  )
  MaskChannel3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEnDelayed(CommandFifoReadEnDelayed),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(MaskChannel[3:0])
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'd1),
    .COMMAND_ADDRESS_AND_DEFAULT(`MaskChannel5to4_CAND)
  )
  MaskChannel5to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEnDelayed(CommandFifoReadEnDelayed),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(MaskChannel[5:4])
    );

  wire [2:0] DiscriMask;
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'd2),
    .COMMAND_ADDRESS_AND_DEFAULT(`DiscriMask_CAND)
  )
  DiscriMaskSet(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEnDelayed(CommandFifoReadEnDelayed),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(DiscriMask)
    );

  wire [2:0] MaskOrUnmask;
  // Pulse signal
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b0),
    .COMMAND_WIDTH(2'd2),
    .COMMAND_ADDRESS_AND_DEFAULT(`MaskSet_CAND)
  )
  MaskSet(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEnDelayed(CommandFifoReadEnDelayed),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(MaskOrUnmask)
    );

  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n)
      MaskShift <= 8'b0;
    else
      MaskShift <= MaskChannel + MaskChannel + MaskChannel;
  end

  reg [191:0] SingleChannelMask;
  reg [2:0] MaskState;
  localparam [2:0]  IDLE = 3'b000,
  MASK                   = 3'b001,
  UNMASK                 = 3'b010,
  MASK_CLEAR             = 3'b011,
  MASK_ALL               = 3'b100;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      MaskState <= IDLE;
      SingleChannelMask <= {192{1'b1}};
      MicrorocChannelDiscriminatorMask <= {192{1'b1}};
    end
    else begin
      case(MaskState)
        IDLE:begin
          if(MaskOrUnmask == 3'b000) begin
            MicrorocChannelDiscriminatorMask <= MicrorocChannelDiscriminatorMask;
            MaskState <= IDLE;
          end
          else if(MaskOrUnmask == 3'b001) begin
            SingleChannelMask <= {{189{1'b1}},DiscriMask} << MaskShift | {DiscriMask,{189{1'b1}}} >> (192- MaskShift - 3);
            MaskState <= MASK;
          end
          else if(MaskOrUnmask == 3'b010) begin
            SingleChannelMask <= {189'b0, 3'b111} << MaskShift;
            MaskState <= UNMASK;
          end
          else if(MaskOrUnmask == 3'b011) begin
            MaskState <= IDLE;
            MicrorocChannelDiscriminatorMask <= {192{1'b1}};
          end
          else if(MaskOrUnmask == 3'b100) begin
            MaskState <= IDLE;
            MicrorocChannelDiscriminatorMask = 192'b0;
          end
          else begin
            MicrorocChannelDiscriminatorMask <= MicrorocChannelDiscriminatorMask;
            MaskState <= IDLE;
          end
        end
        MASK:begin
          MicrorocChannelDiscriminatorMask <= MicrorocChannelDiscriminatorMask & SingleChannelMask;
          MaskState <= IDLE;
        end
        UNMASK:begin
          MicrorocChannelDiscriminatorMask <= MicrorocChannelDiscriminatorMask | SingleChannelMask;
          MaskState <= IDLE;
        end
        MASK_CLEAR:begin
          MicrorocChannelDiscriminatorMask <= {192{1'b1}};
        end
        default:begin
          MicrorocChannelDiscriminatorMask <= MicrorocChannelDiscriminatorMask;
          MaskState <= IDLE;
        end
      endcase
    end
  end
endmodule
