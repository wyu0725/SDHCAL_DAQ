`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC 
// Engineer: Yu Wang
// 
// Create Date: 2017/06/27 14:18:35
// Design Name: SDHCAL_DAQ2V0
// Module Name: SlaveDaq
// Project Name: SDHCAL_DAQ2V0
// Target Devices: XC7A200TFGG484-2
// Tool Versions: Vivado 16.3
// Description: This module is used to control the DAQ function of the ASIC,
// as it's name shows, this module is started by a trigger signal that is
// AcqStart. When Module Start, if the AcqStart signal is enable, this module
// start the ASIC once.
// In this module the START_ACQ is started asynchronous and disabled
// synchronous, when one acq done the digital part of the ASIC should be
// reset. And this module send a done signal.
// As for the RESET_B signal, to my understanding, the Reset_b
// signal is only used for reset the digital part of the
// ASIC, especially the LVDS recevier, before power on.
// There is no need to reset the ASIC as there is no
// power down after one acquisition.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SlaveDaq(
    input Clk,
    input reset_n,
    input ModuleStart,              //Module start signal, from USB
    input AcqStart,                 // External start trigger
    input EndReadout,               // Digitial RAM end reading signal. Active H
    input CHIPSATB,                 // Chip is full, active L
    input [15:0] AcquitionTime,     // Send from USB, default 8
    input [15:0] EndHoldTime,
    output reg RESET_B,             //Reset ASIC digital part
    output reg START_ACQ,           //Start & maintain acquisition, Active H
    output reg StartReadout,        //Digital RAM start reading signal
    output reg PWR_ON_A,            //Analogue Part Power Pulsing control, active H
    output reg PWR_ON_D,            //Digital Power Pulsing control, active H
    output PWR_ON_ADC,              //Slow shaper Power Pulsing Control, active H
    output reg PWR_ON_DAC,          //DAC Power Pulsing Control, Active H
    output reg OnceEnd
    );
    // Synchronize the external CHIPSATB signal
    reg ChipSatB_r1, ChipSatB_r2;
    always @(posedge Clk or negedge reset_n) begin
      if(~reset_n) begin
        ChipSatB_r1 <= 1'b1;
        ChipSatB_r2 <= 1'b1;
      end
      else begin
        ChipSatB_r1 <= CHIPSATB;
        ChipSatB_r2 <= ChipSatB_r1;
      end
    end
    wire ChipFull;
    assign ChipFull = (~ChipSatB_r1) && ChipSatB_r2;//falling edge indicates that one or more ASICs are full
    wire ReadStart;
    assign ReadStart = ChipSatB_r1 && (~ChipSatB_r2);//rising edge indicates that readout cound start
    // Synchronize the EndReadout
    reg EndReadout_r1;
    reg EndReadout_r2;
    always @(posedge Clk or negedge reset_n) begin
      if(~reset_n) begin
        EndReadout_r1 <= 1'b0;
        EndReadout_r2 <= 1'b0;
      end
      else begin
        EndReadout_r1 <= EndReadout;
        EndReadout_r2 <= EndReadout_r1;
      end
    end
    wire EndRead;
    assign EndRead = (~EndReadout_r1) && EndReadout_r2;
    //*** DAQ Control
    // Synchronize the External trigger
    reg AcqStart_r1;
    reg AcqStart_r2;
    always @(posedge Clk or negedge reset_n) begin
      if(~reset_n) begin
        AcqStart_r1 <= 1'b0;
        AcqStart_r2 <= 1'b0;
      end
      else begin
        AcqStart_r1 <= AcqStart;
        AcqStart_r2 <= AcqStart_r1;
      end
    end
    wire SingleAcqStart;
    assign SingleAcqStart = AcqStart_r1 && (~AcqStart_r2);
    reg [15:0] DelayCount;
    localparam [3:0] IDLE = 4'd0,
                     CHIP_RESET = 4'd1,
                     POWER_ON = 4'd2,
                     RELEASE = 4'd3,
                     WAIT_START = 4'd4,
                     START_ACQ = 4'd5,
                     WAIT_READ = 4'd6,
                     START_READOUT = 4'd7,
                     WAIT_READ_DONE = 4'd8,
                     //RESET_ASIC = 4'd9, // There is no need to reset ASIC
                     ONCE_END = 4'd10,
                     ALL_DONE = 4'd11;
    reg [3:0] State;
    localparam TimeMinPowerReset = 8;//Time to wake up clock LVDS receivers 200ns
    localparam TimeMinResetStart = 40;//4 SlowClock ticks + 4 FastClock ticks (internal management) 1us
    localparam TimeMinSro = 16;//Time to wake up clock LVDS receivers 400ns
    reg ResetStartAcq_n;
    reg AcqEnable;
    always @(posedge Clk or negedge reset_n) begin
      if(~reset_n) begin
        State <= IDLE;
        RsetStartAcq_n <= 1'b1;
        AcqEnable <= 1'b0;
        RESET_B <= 1'b1;
        StartReadout <= 1'b0;
        DelayCount <= 16'b0;
        OnceEnd <= 1'b0;
      end
      else begin
        case(State)
          ILDE:begin
            if(ModuleStart) begin
              RESET_B <= 1'b0;
              ResetStartAcq_n <= 1'b0;
              State <= CHIP_RESET;
            end
            else
              State <= IDLE;
          end
          CHIP_RESET:begin
            State <= POWER_ON;
          end
          POWER_ON:begin
            if(DelayCount < TimeMinPowerReset) begin
              DelayCount <= DelayCount + 1'b1;
              State <= POWER_ON;
            end
            else begin
              DelayCount <= 16'b0;
              State <= RELEASE;
              RESET_B <= 1'b1;
              ResetStartAcq_n <= 1'b1;
            end
          end
          RELEASE:begin
            if(DelayCount < TimeMinResetStart) begin
              DelayCount <= DelayCount + 1'b1;
              State <= RELEASE;
            end
            else begin
              DelayCount <= 16'b0;
              AcqEnable <= 1'b1;
              ResetStartAcq_n <= 1'b1;
              State <= WAIT_START;
            end
          end
          WAIT_START:begin
            if(~ModuleStart) begin
              AcqEnable <= 1'b0;
              State <= ALL_DONE;
            end
            else if(SingleAcqStart) begin
              State <= START_ACQ;
            end
            else begin
              State <= WAIT_START;
            end
          end
          START_ACQ:begin
            if(DelayCount >= AcquisitionTime) begin
              State <= WAIT_READ;
              DelayCount <= 16'b0;
              ResetStartAcq_n <= 1'b0;
            end
            else if(ChipFull) begin
              State <= WAIT_READ;
              DelayCount <= 16'b0;
              ResetStartAcq_n <= 1'b0;
            end
            else begin
              DelayCount <= DelayCount + 1'b1;
              State <= START_ACQ;
            end
          end
          WAIT_READ:begin
            if(ReadStart)begin
              StartReadout <= 1'b1;
              State <= START_READOUT;
            end
            else begin
              State <= WAIT_READ;
            end
          end
          START_READOUT:begin
            if(DelayCount < TimeMinSro) begin
              DelayCount <= DelayCount + 1'b1;
              State <= START_READOUT;
            end
            else begin
              DelayCount <= 16'b0;
              StartReadout <= 1'b0;
              State <= WAIT_READ_DONE;
            end
          end
          WAIT_READ_DONE:begin
            if(ReadEnd) begin
              OnceEnd <= 1'b1;
              State <= ONCE_END;
            end
            else begin
              State <= WAIT_READ_DONE;
            end
          end
          ONCE_END:begin
            if(DelayCount < EndHoldTime) begin
              DelayCount <= DelayCount + 1'b1;
              State <= ONCE_END;
            end
            else begin
              OnceEnd <= 1'b0;
              DelayCount <= 16'b0;
              State <= WAIT_START;
            end
          end
          ALL_DONE:begin
            ResetStartAcq <= 1'b1;
            State <= IDLE;
          end
          default:begin
            State <= IDLE;
          end
        endcase
      end
    end
    // Generate the START_ACQ signal
    always @(posedge AcqStart or negedge ResetStartAcq_n) begin
      if(~ResetStartAcq_n)
        START_ACQ <= 1'b0;
      else if(AcqEnable)
        START_ACQ <= 1'b1;
      else
        START_ACQ <= 1'b0;
    end
    //*** Power On Control
    always @(State) begin
      if(State == POWER_ON || State == POWER_ON || State == RELEASE || State == WAIT_START || State == START_ACQ || State == WAIT_READ || State == START_READOUT || State == WAIT_READ_OUT || State == WAIT_READ_DONE || State == ONCE_END)
        POWER_ON_D = 1'b1;
      else
        POWER_ON_D = 1'b0;
    end
    always @(State) begin
      if(State == CHIP_RESET || State == POWER_ON || State == POWER_ON || State == RELEASE || State == WAIT_START || State == START_ACQ || State == WAIT_READ || State == START_READOUT || State == WAIT_READ_OUT || State == WAIT_READ_DONE || State == ONCE_END) begin
        POWER_ON_A = 1'b1;
        POWEWR_ON_DAC = 1'b1;
      end
      else begin
        POWER_ON_A = 1'b0;
        POWER_ON_DAC = 1'b0;
      end
    end
    assign POWER_ON_ADC = 1'b0;
endmodule
