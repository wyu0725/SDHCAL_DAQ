`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/07/20 14:33:52
// Design Name:
// Module Name: AutoDaq_tb
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


module AutoDaq_tb();
  reg Clk;
  reg reset_n;
  reg start;
  reg StartEnable;
  reg End_Readout;
  reg Chipsatb;
  reg [15:0] T_acquisition;
  wire Reset_b;
  wire Start_Acq;
  wire Start_Readout;
  wire Pwr_on_d;
  wire Pwr_on_a;
  wire Pwr_on_adc;
  wire Pwr_on_dac;
  wire Once_end;

  //instance:../../../src/AutoDaq.v
  AutoDaq uut
  (
    .Clk(Clk),                     // 40M
    .reset_n(reset_n),
    .start(start),
    .StartEnable(StartEnable),
    .End_Readout(End_Readout),     // Digitial RAM end reading signal, Active H
    .Chipsatb(Chipsatb),           // Chip is full, Active L
    .T_acquisition(T_acquisition), // Send from USB, default 8
    .Reset_b(Reset_b),             // Reset ASIC digital part
    .Start_Acq(Start_Acq),         // Start & maintain acquisition, Active H
    .Start_Readout(Start_Readout), // Digital RAM start reading signal
    .Pwr_on_a(Pwr_on_a),           // Analogue Part Power Pulsing control, active H
    .Pwr_on_d(Pwr_on_d),           // Digital Power Pulsing control, active H
    .Pwr_on_adc(Pwr_on_adc),       // Slow shaper Power Pulsing Control, active H
    .Pwr_on_dac(Pwr_on_dac),       // DAC Power Pulsing Control, Active H
    .Once_end(Once_end)
    );

  initial begin
    Clk = 1'b0;
    reset_n = 1'b0;
    start = 1'b0;
    StartEnable = 1'b0;
    T_acquisition = 16'd20;
    #100;
    reset_n = 1'b1;
    #100;
    reset_n = 1'b0;
    #100;
    reset_n = 1'b1;
    #1000;
    start = 1'b1;
    #5000;
    StartEnable = 1'b1;
    #2525;
    StartEnable = 1'b0;
    #5000;
    start = 1'b0;
    #2000;
    start = 1'b1;

  end

  reg [5:0] StartCount;
	reg [1:0] StartState;
	localparam [1:0] IDLE = 2'b00,
	START = 2'b01,
	CHIP_FULL = 2'b10;
	//DONE = 2'b11;
	always @(posedge Clk or negedge reset_n) begin
		if(~reset_n) begin
			Chipsatb <= 1'b1;
			StartCount <= 6'b0;
			StartState <= IDLE;
		end
		else begin
			case(StartState)
				IDLE:begin
					if(Start_Acq) begin
						StartState <= START;
					end
					else
						StartState <= IDLE;
				end
				START:begin
					if(StartCount < 6'd60 && Start_Acq) begin
						StartCount <= StartCount + 1'b1;
						StartState <= START;
					end
					else begin
						StartState <= CHIP_FULL;
						StartCount <= 6'b0;
						Chipsatb <= 1'b0;
					end
				end
				CHIP_FULL:begin
					if(StartCount < 6'd10) begin
						StartCount <= StartCount + 1'b1;
						StartState <= CHIP_FULL;
					end
					else begin
						Chipsatb <= 1'b1;
						StartCount <= 6'b0;
						StartState <= IDLE;
					end
				end
				default:StartState <= IDLE;
			endcase
		end
  end
  
  reg [5:0] ReadCount;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      ReadCount = 6'b0;
      End_Readout = 1'b0;
    end
    else if(Start_Readout || (ReadCount != 6'd0)) begin
      ReadCount <= ReadCount + 1'b1;
      End_Readout <= (ReadCount == 6'h3F);
    end
    else begin
      ReadCount <= 6'b0;
      End_Readout <= 1'b0;
    end
  end

  localparam LOW = 13;
  localparam HIGH = 12;
  always begin
    #(LOW) Clk = ~Clk;
    #(HIGH) Clk = ~Clk;
  end
endmodule
