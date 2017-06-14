`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Science and Technology of China
// Engineer: Junbin Zhang
// 
// Create Date: 11/14/2016 10:01:11 AM
// Design Name: SDHCAL_DAQ2V0
// Module Name: Clk_Management
// Project Name: 
// Target Devices: XC7A100TFGG484
// Tool Versions: Vivado 2016.3
// Description: Clock management of the RTL project
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Clk_Management(
    input CLK_40M,
    input usb_clkout, //clock from usb
    input rst_n,
    output Clk,
    output Clk_5M,
    output Clk_320M,
    output IFCLK,     //usb ifclk domain
    output usb_ifclk, //out to usb chip
    output reset_n,
    output CLKGOOD
    );
//PLL来实现

BUFG BUFG_IFCLK
(
    .O(IFCLK),
    .I(usb_clkout)
);
assign usb_ifclk = IFCLK; 

wire pll_40;
wire pll_5;
wire Pll_320M;
wire feedback;
wire LOCKED;

   MMCME2_BASE #(
      .BANDWIDTH("OPTIMIZED"),   // Jitter programming (OPTIMIZED, HIGH, LOW)
      .CLKFBOUT_MULT_F(16.0),     // Multiply value for all CLKOUT (2.000-64.000).
      .CLKFBOUT_PHASE(0.0),      // Phase offset in degrees of CLKFB (-360.000-360.000).
      .CLKIN1_PERIOD(25.0),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz). --40M
      // CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
      .CLKOUT1_DIVIDE(16), //40M
      .CLKOUT2_DIVIDE(128),//5M
      .CLKOUT3_DIVIDE(1),
      .CLKOUT4_DIVIDE(1),
      .CLKOUT5_DIVIDE(1),
      .CLKOUT6_DIVIDE(1),
      .CLKOUT0_DIVIDE_F(2),    // Divide amount for CLKOUT0 (1.000-128.000).
                                  // 40M * 16 / 2 = 320M
      // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
      .CLKOUT0_DUTY_CYCLE(0.5),
      .CLKOUT1_DUTY_CYCLE(0.5),
      .CLKOUT2_DUTY_CYCLE(0.5),
      .CLKOUT3_DUTY_CYCLE(0.5),
      .CLKOUT4_DUTY_CYCLE(0.5),
      .CLKOUT5_DUTY_CYCLE(0.5),
      .CLKOUT6_DUTY_CYCLE(0.5),
      // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      .CLKOUT0_PHASE(0.0),
      .CLKOUT1_PHASE(0.0),
      .CLKOUT2_PHASE(0.0),
      .CLKOUT3_PHASE(0.0),
      .CLKOUT4_PHASE(0.0),
      .CLKOUT5_PHASE(0.0),
      .CLKOUT6_PHASE(0.0),
      .CLKOUT4_CASCADE("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      .DIVCLK_DIVIDE(1),         // Master division value (1-106)
      .REF_JITTER1(0.0),         // Reference input jitter in UI (0.000-0.999).
      .STARTUP_WAIT("FALSE")     // Delays DONE until MMCM is locked (FALSE, TRUE)
   )
   MMCME2_BASE_inst (
      // Clock Outputs: 1-bit (each) output: User configurable clock outputs
      .CLKOUT0(Pll_320M),     // 1-bit output: CLKOUT0
      .CLKOUT0B(),   // 1-bit output: Inverted CLKOUT0
      .CLKOUT1(pll_40),     // 1-bit output: CLKOUT1
      .CLKOUT1B(),   // 1-bit output: Inverted CLKOUT1
      .CLKOUT2(pll_5),     // 1-bit output: CLKOUT2
      .CLKOUT2B(),   // 1-bit output: Inverted CLKOUT2
      .CLKOUT3(),     // 1-bit output: CLKOUT3
      .CLKOUT3B(),   // 1-bit output: Inverted CLKOUT3
      .CLKOUT4(),     // 1-bit output: CLKOUT4
      .CLKOUT5(),     // 1-bit output: CLKOUT5
      .CLKOUT6(),     // 1-bit output: CLKOUT6
      // Feedback Clocks: 1-bit (each) output: Clock feedback ports
      .CLKFBOUT(feedback),   // 1-bit output: Feedback clock
      .CLKFBOUTB(), // 1-bit output: Inverted CLKFBOUT
      // Status Ports: 1-bit (each) output: MMCM status ports
      .LOCKED(LOCKED),       // 1-bit output: LOCK
      // Clock Inputs: 1-bit (each) input: Clock input
      .CLKIN1(CLK_40M),       // 1-bit input: Clock
      // Control Ports: 1-bit (each) input: MMCM control ports
      .PWRDWN(1'b0),       // 1-bit input: Power-down
      .RST(!rst_n),             // 1-bit input: Reset
      // Feedback Clocks: 1-bit (each) input: Clock feedback ports
      .CLKFBIN(feedback)      // 1-bit input: Feedback clock
   );
   // End of MMCME2_BASE_inst instantiation
   
   assign reset_n = LOCKED;
   assign CLKGOOD = LOCKED;

	   BUFG BUFG_gclk
	(
	    .O(Clk),
	    .I(pll_40)
	);
	   BUFG BUFG_Clk_5M
	(
	    .O(Clk_5M),
	    .I(pll_5)
	);
  BUFG BUFG_Clk_320M(
    .O(Clk_320M),
    .I(Pll_320M)
  );
endmodule
