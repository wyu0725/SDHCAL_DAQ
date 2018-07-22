`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:   20:19:04 07/19/2018
// Design Name:   MicrorocCommonControl
// Module Name:   C:/WangYu/TestBenchInst/MicrorocCommomControl_tb.v
// Project Name:  TestBenchInst
// Target Device:
// Tool versions:
// Description:
//
// Verilog Test Fixture created by ISE for module: MicrorocCommonControl
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module MicrorocCommomControl_tb;

  // Inputs
  reg Clk;
  reg reset_n;
  reg SlowClock;
  reg SyncClk;
  reg TriggerIn;
  reg HoldEnable;
  reg [7:0] HoldDelay;
  reg [15:0] HoldTime;
  reg [1:0] RazMode;
  reg ExternalRazSignalEnable;
  reg [3:0] ForceExternalRaz;
  reg [3:0] ExternalRazDelayTime;
  reg SlowControlOrReadScopeSelect;
  reg [3:0] reset_b;
  reg ResetTimeStamp;
  reg DataTrigger;
  reg DataTriggerEnable;
  reg [3:0] pwr_on_a;
  reg [3:0] pwr_on_d;
  reg [3:0] pwr_on_adc;
  reg [3:0] pwr_on_dac;
  reg [3:0] OnceEnd;
  reg [3:0] EndReadoutParameter;

  // Outputs
  wire HoldSignal;
  wire SELECT;
  wire RESET_B;
  wire rst_counterb;
  wire TRIG_EXT;
  wire RamReadoutDone;
  wire PWR_ON_A;
  wire PWR_ON_D;
  wire PWR_ON_ADC;
  wire PWR_ON_DAC;
  wire CK_5P;
  wire CK_5N;
  wire CK_40P;
  wire CK_40N;
  wire RAZ_CHNP;
  wire RAZ_CHNN;
  wire VAL_EVTP;
  wire VAL_EVTN;

  // Instantiate the Unit Under Test (UUT)
  // instance:../../../src/MicrorocCommonControl.v
  MicrorocCommonControl
  #(
    .ASIC_CHAIN_NUMBER(4'd4)
  )
  uut(
    .Clk(Clk),
    .reset_n(reset_n),
    .SlowClock(SlowClock),
    .SyncClk(SyncClk),
    .TriggerIn(TriggerIn),
    // Hold
    .HoldEnable(HoldEnable),
    .HoldDelay(HoldDelay),
    .HoldTime(HoldTime),
    .HoldSignal(HoldSignal),
    // ExternalRaz
    .RazMode(RazMode),
    .ExternalRazSignalEnable(ExternalRazSignalEnable),
    .ForceExternalRaz(ForceExternalRaz),
    .ExternalRazDelayTime(ExternalRazDelayTime),
    // Select 1:Slow Control Register, 0:Read Register
    .SlowControlOrReadScopeSelect(SlowControlOrReadScopeSelect),
    .SELECT(SELECT),
    .reset_b(reset_b),
    .RESET_B(RESET_B),
    .ResetTimeStamp(ResetTimeStamp),
    .rst_counterb(rst_counterb),
    .DataTrigger(DataTrigger),
    .DataTriggerEnable(DataTriggerEnable),
    .TRIG_EXT(TRIG_EXT),
    .pwr_on_a(pwr_on_a),
    .pwr_on_d(pwr_on_d),
    .pwr_on_adc(pwr_on_adc),
    .pwr_on_dac(pwr_on_dac),
    .OnceEnd(OnceEnd),
    .EndReadoutParameter(EndReadoutParameter),
    .RamReadoutDone(RamReadoutDone),
    .PWR_ON_A(PWR_ON_A),
    .PWR_ON_D(PWR_ON_D),
    .PWR_ON_ADC(PWR_ON_ADC),
    .PWR_ON_DAC(PWR_ON_DAC),
    .CK_5P(CK_5P),
    .CK_5N(CK_5N),
    .CK_40P(CK_40P),
    .CK_40N(CK_40N),
    .RAZ_CHNP(RAZ_CHNP),
    .RAZ_CHNN(RAZ_CHNN),
    .VAL_EVTP(VAL_EVTP),
    .VAL_EVTN(VAL_EVTN)
    );

  initial begin
    // Initialize Inputs
    Clk = 1'b0;
    reset_n = 1'b0;
    SlowClock = 1'b0;
    SyncClk = 1'b0;
    TriggerIn = 1'b0;
    HoldEnable = 1'b0;
    HoldDelay = 8'd2;
    HoldTime = 16'd20;
    RazMode = 2'b0;
    ExternalRazSignalEnable = 1'b0;
    ForceExternalRaz = 4'b0;
    ExternalRazDelayTime = 4'd3;
    SlowControlOrReadScopeSelect = 0;
    reset_b = 4'd0;
    ResetTimeStamp = 1'd0;
    DataTrigger = 1'd0;
    DataTriggerEnable = 1'd0;
    pwr_on_a = 4'd0;
    pwr_on_d = 4'd0;
    pwr_on_adc = 4'd0;
    pwr_on_dac = 4'd0;
    OnceEnd = 4'd0;
    EndReadoutParameter = 4'b1111;

    // Wait 100 ns for global reset to finish
    #100;
    reset_n = 1'b1;
    // Add stimulus here
    #1000;
    ExternalRazSignalEnable = 1'b1;
    #50;
    TriggerIn= 1'b1;
    #50;
    TriggerIn = 1'b0;
    #3333;
    TriggerIn = 1'b1;
    #50;
    TriggerIn = 1'b0;
    #1000;
    HoldEnable = 1'b1;
    #50;
    TriggerIn = 1'b1;
    #100;
    TriggerIn = 1'b0;
    #2338;
    TriggerIn = 1'b1;
    #50;
    TriggerIn = 1'b0;
    #2000;
    ResetTimeStamp = 1'b1;
    #25;
    ResetTimeStamp = 1'b0;
    #2000;
    OnceEnd = 4'b1111;
    #2525;
    OnceEnd = 4'b0000;

  end
  localparam LOW = 13;
  localparam HIGH = 12;
  localparam SLOWCLOCK_PEROID = 200;
  localparam SYNCCLOCK_PEROID = 10;
  always begin
    #(LOW) Clk = ~Clk;
    #(HIGH) Clk = ~Clk;
  end
  always #(SLOWCLOCK_PEROID/2) SlowClock = ~SlowClock;
  always #(SYNCCLOCK_PEROID/2) SyncClk = ~SyncClk;

endmodule

