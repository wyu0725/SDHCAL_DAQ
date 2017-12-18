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
    input [15:0] AcquisitionTime,     // Send from USB, default 8
    input [15:0] EndHoldTime,
    output reg RESET_B,             //Reset ASIC digital part
    output reg START_ACQ,           //Start & maintain acquisition, Active H
    output reg ForceExternalRaz,    //Active H, When the start does not come, force externalRaz
    output reg StartReadout,        //Digital RAM start reading signal
    output reg PWR_ON_A,            //Analogue Part Power Pulsing control, active H
    output reg PWR_ON_D,            //Digital Power Pulsing control, active H
    output PWR_ON_ADC,              //Slow shaper Power Pulsing Control, active H
    output reg PWR_ON_DAC,          //DAC Power Pulsing Control, Active H
    output reg OnceEnd,
    output reg AllDone,             //Acquisition Stop
    // DataTransmit
    input [15:0] MicrorocData,
    input MicrorocData_en,
    output reg [15:0] SlaveDaqData,
    output reg SlaveDaqData_en,
    input DataTransmitDone
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
    assign EndRead = (~EndReadout_r1) && EndReadout_r2;// Falling edge
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
    localparam [4:0] IDLE = 5'd0,
                     CHIP_RESET = 5'd1,
                     POWER_ON = 5'd2,
                     RELEASE = 5'd3,
                     WAIT_START = 5'd4,
                     START_ACQUISITION = 5'd5,
                     WAIT_READ = 5'd6,
                     START_READOUT = 5'd7,
                     WAIT_READ_DONE = 5'd8,
                     //RESET_ASIC = 4'd9, // There is no need to reset ASIC
                     ONCE_END = 5'd9,
					 WAIT_DATA_END =5'd10,
 					 END_DATA = 5'd11,	
                     OUT_TAIL = 5'd12,
                     OUT_COUNT1 = 5'd13,
                     OUT_COUNT2 = 5'd14,
                     OUT_COUNT3 = 5'd15,
                     ALL_DONE = 5'd16;
    reg [4:0] State;
		reg [11:0] DataEndCount;
    localparam TimeMinPowerReset = 8;//Time to wake up clock LVDS receivers 200ns
    localparam TimeMinResetStart = 40;//4 SlowClock ticks + 4 FastClock ticks (internal management) 1us
    localparam TimeMinSro = 16;//Time to wake up clock LVDS receivers 400ns
    reg ResetStartAcq_n;
    reg AcqEnable;
    reg TrigCount_en;
    reg ResetTrigCount_n;
    reg [23:0] TrigCounter;
    reg InternalData_en;
	// MicrorocHit high indicates a hit come and should add TrigID to the data
	reg MicrorocHit;
  	reg ResetMicrorocHit;	
    always @(posedge Clk or negedge reset_n) begin
      if(~reset_n) begin
        State <= IDLE;
        ResetStartAcq_n <= 1'b1;
        AcqEnable <= 1'b0;
        RESET_B <= 1'b1;
        StartReadout <= 1'b0;
        DelayCount <= 16'b0;
        OnceEnd <= 1'b0;
        AllDone <= 1'b0;
        ResetTrigCount_n <= 1'b1;
        InternalData_en <= 1'b0;
        TrigCount_en <= 1'b0;
		DataEndCount <= 12'b0;
		ResetMicrorocHit <= 1'b1;
      end
      else begin
        case(State)
          IDLE:begin
            if(ModuleStart) begin
              RESET_B <= 1'b0;
              ResetStartAcq_n <= 1'b0;
              State <= CHIP_RESET;
              ResetTrigCount_n <= 1'b0;
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
              ResetTrigCount_n <= 1'b1;
              TrigCount_en <= 1'b1;
              State <= WAIT_START;
            end
		  end
          WAIT_START:begin
			if(~ModuleStart) begin
              AcqEnable <= 1'b0;
              //AllDone <= 1'b1;
              State <= WAIT_DATA_END;
							DataEndCount <= 12'b0;
              TrigCount_en <= 1'b0;
            end
			else if(SingleAcqStart) begin
			  ResetMicrorocHit <= 1'b1;
              State <= START_ACQUISITION;
            end
            else begin
              State <= WAIT_START;
            end
          end
          START_ACQUISITION:begin
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
              State <= START_ACQUISITION;
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
            if(EndReadout) begin
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
              ResetStartAcq_n <= 1'b1;
              State <= WAIT_START;
            end
          end
					WAIT_DATA_END:begin
						if(DataEndCount < 12'd1600) begin
							DataEndCount <= DataEndCount + 1'b1;
							State <= WAIT_DATA_END;
						end
						else begin
							State <= END_DATA;
							DataEndCount <= 12'b0;
						end
					end
          END_DATA:begin
            State <= OUT_TAIL;
            InternalData_en <= 1'b0;
          end
          OUT_TAIL:begin
            if(DelayCount < 16'd1) begin
              DelayCount <= DelayCount + 1'b1;
              InternalData_en <= 1'b1;
              State <= OUT_TAIL;
            end
            else begin
              DelayCount <= 16'b0;
              InternalData_en <= 1'b0;
              State <= OUT_COUNT1;
            end
          end
          OUT_COUNT1:begin
            if(DelayCount < 16'd1) begin
              DelayCount <= DelayCount + 1'b1;
              InternalData_en <= 1'b1;
              State <= OUT_COUNT1;
            end
            else begin
              DelayCount <= 16'b0;
              InternalData_en <= 1'b0;
              State <= OUT_COUNT2;
            end
          end
          OUT_COUNT2:begin
            if(DelayCount < 16'd1) begin
              DelayCount <= DelayCount + 1'b1;
              InternalData_en <= 1'b1;
              State <= OUT_COUNT2;
            end
            else begin
              DelayCount <= 16'b0;
              InternalData_en <= 1'b0;
              State <= OUT_COUNT3;
            end
          end
          OUT_COUNT3:begin
            if(DelayCount < 16'd1) begin
              DelayCount <= DelayCount + 1'b1;
              InternalData_en <= 1'b1;
              State <= OUT_COUNT3;
            end
            else begin
              DelayCount <= 16'b0;
              InternalData_en <= 1'b0;
              State <= ALL_DONE;
              AllDone <= 1'b1;
            end
          end
          ALL_DONE:begin
            if(DataTransmitDone) begin
              ResetStartAcq_n <= 1'b1;
              AllDone <= 1'b0;
              State <= IDLE;
            end
            else begin
              State <= ALL_DONE;
            end
          end
          default:begin
            State <= IDLE;
          end
        endcase
      end
    end
    // Generate the START_ACQ signal
    always @(posedge AcqStart or negedge ResetStartAcq_n) begin
      if(~ResetStartAcq_n) begin
        START_ACQ <= 1'b0;
        ForceExternalRaz <= 1'b1;
      end
      else if(AcqEnable) begin
        START_ACQ <= 1'b1;
        ForceExternalRaz <= 1'b0;
      end
      else begin
        START_ACQ <= 1'b0;
        ForceExternalRaz <= 1'b1;
      end
    end
    always @(posedge AcqStart or negedge ResetTrigCount_n) begin
      if(~ResetTrigCount_n) 
        TrigCounter <= 24'b0;
      else if(TrigCount_en)
        TrigCounter <= TrigCounter + 1'b1;
      else
        TrigCounter <= TrigCounter;
    end
    //*** Synchronise
    reg [23:0] TrigCounter_sync;
    always @(posedge Clk or negedge reset_n) begin
      if(~reset_n)
        TrigCounter_sync <= 24'b0;
      else
        TrigCounter_sync <= TrigCounter;
    end
  // *** Monitor if Microroc id hit
  	always @(posedge MicrorocData_en or negedge ResetMicrorocHit) begin
		if(~ResetMicrorocHit)
		  	MicrorocHit <= 1'b0;
	  	else
			MicrorocHit <= 1'b1;
	end
    //*** Power On Control
    always @(State) begin
      if(State == POWER_ON || State == POWER_ON || State == RELEASE || State == WAIT_START || State == START_ACQUISITION || State == WAIT_READ || State == START_READOUT || State == WAIT_READ || State == WAIT_READ_DONE || State == ONCE_END)
        PWR_ON_D = 1'b1;
      else
        PWR_ON_D = 1'b0;
    end
    always @(State) begin
      if(State == CHIP_RESET || State == POWER_ON || State == POWER_ON || State == RELEASE || State == WAIT_START || State == START_ACQUISITION || State == WAIT_READ || State == START_READOUT || State == WAIT_READ || State == WAIT_READ_DONE || State == ONCE_END) begin
        PWR_ON_A = 1'b1;
        PWR_ON_DAC = 1'b1;
      end
      else begin
        PWR_ON_A = 1'b0;
        PWR_ON_DAC = 1'b0;
      end
    end
    assign PWR_ON_ADC = 1'b0;
    always @(*) begin
      if(State == END_DATA) begin
        SlaveDaqData = 16'h0000;
        SlaveDaqData_en = InternalData_en;
      end
      else if(State == OUT_TAIL) begin
        SlaveDaqData = 16'hFF45;
        SlaveDaqData_en = InternalData_en;
      end
      else if(State == OUT_COUNT1) begin
        //SlaveDaqData <= {8'hCC,TrigCounter_sync[23:16]};
        SlaveDaqData = {8'hCC,TrigCounter_sync[23:16]};
        SlaveDaqData_en = InternalData_en;
      end
      else if(State == OUT_COUNT2) begin
        SlaveDaqData = TrigCounter_sync[15:0];
        SlaveDaqData_en = InternalData_en;
      end
      else if(State == OUT_COUNT3) begin
        SlaveDaqData = 16'h45FF;
        SlaveDaqData_en = InternalData_en;
      end
      else begin
        //SlaveDaqData <= MicrorocData;
        SlaveDaqData = MicrorocData;
        SlaveDaqData_en = MicrorocData_en;
      end
    end
    /*(*mark_debug = "true"*)wire [15:0] SlaveDaqData_debug;
    assign SlaveDaqData_debug = SlaveDaqData;*/
endmodule
