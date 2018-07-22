`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Yu Wang
//
// Create Date: 2018/07/19 15:59:55
// Design Name: SDHCAL DIF 1V0
// Module Name: MicrorocCommonControl
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


module MicrorocCommonControl
  #(
    parameter ASIC_CHAIN_NUMBER = 4'd4
  )
(
  input Clk,
  input reset_n,
  input SlowClock,
  input SyncClk,
  input TriggerIn,
  // Hold
  input HoldEnable,
  input [7:0] HoldDelay,
  input [15:0] HoldTime,
  output HoldSignal,
  // ExternalRaz
  input [1:0] RazMode,
  input ExternalRazSignalEnable,
  input [ASIC_CHAIN_NUMBER - 1:0] ForceExternalRaz,
  input [3:0] ExternalRazDelayTime,
  // Select 1:Slow Control Register, 0:Read Register
  input SlowControlOrReadScopeSelect,
  output SELECT,
  input [ASIC_CHAIN_NUMBER - 1:0] reset_b,
  output RESET_B,
  input ResetTimeStamp,
  output rst_counterb,
  input DataTrigger,
  input DataTriggerEnable,
  output TRIG_EXT,
  input [ASIC_CHAIN_NUMBER - 1:0] pwr_on_a,
  input [ASIC_CHAIN_NUMBER - 1:0] pwr_on_d,
  input [ASIC_CHAIN_NUMBER - 1:0] pwr_on_adc,
  input [ASIC_CHAIN_NUMBER - 1:0] pwr_on_dac,
  input [ASIC_CHAIN_NUMBER - 1:0] OnceEnd,
  input [ASIC_CHAIN_NUMBER - 1:0] EndReadoutParameter,
  output RamReadoutDone,
  output PWR_ON_A,
  output PWR_ON_D,
  output PWR_ON_ADC,
  output PWR_ON_DAC,
  output CK_5P,
  output CK_5N,
  output CK_40P,
  output CK_40N,
  output RAZ_CHNP,
  output RAZ_CHNN,
  output VAL_EVTP,
  output VAL_EVTN
  );

  wire RAZ_CHN;
  ExternalRazGenerate ExternalRazGen(
    .Clk                 (Clk),
    .reset_n             (reset_n),
    .TriggerIn           (TriggerIn),
    .ExternalRaz_en      (ExternalRazSignalEnable),
    .ExternalRazDelayTime(ExternalRazDelayTime),
    .RazMode             (RazMode),
    .ForceRaz            (|ForceExternalRaz),
    .RAZ_CHN             (RAZ_CHN)
    );

  HoldGenerate HoldGen(
    .Clk              (Clk),
    .SyncClk          (SyncClk),
    .reset_n          (reset_n),
    .TriggerIn        (TriggerIn),
    .HoldEnable       (HoldEnable),
    .HoldDelay        (HoldDelay),
    .HoldTime         (HoldTime),
    .HoldOut          (HoldSignal)
    );

  TimeStampSyncAndDataTrigger TimeStampSyncAndTrigger(
    .Clk              (Clk),
    .reset_n          (reset_n),
    .TimeStampReset   (ResetTimeStamp),
    .RST_COUNTERB     (rst_counterb),
    .DataTrigger      (DataTrigger),
    .DataTriggerEnable(DataTriggerEnable),
    .TriggerExt       (TRIG_EXT)
    );

  RamReadDoneSync4Chain RamReadDoneDetect(
    .Clk(Clk),
    .reset_n(reset_n),
    .OnceEnd(OnceEnd),
    .EndReadoutParameter(EndReadoutParameter),
    .RamReadoutDone(RamReadoutDone)
    );

  assign SELECT = ~SlowControlOrReadScopeSelect;
  assign RESET_B = |reset_b;
  assign PWR_ON_A = |pwr_on_a;
  assign PWR_ON_D = |pwr_on_d;
  assign PWR_ON_ADC = |pwr_on_adc;
  assign PWR_ON_DAC = |pwr_on_dac;

  // LVDS BUFF OBUFDS
  // See UG593
  // https://www.xilinx.com/support/documentation/sw_manuals/xilinx2014_2/ug953-vivado-7series-libraries.pdf

  // RAZ_CHN
  OBUFDS #(
    .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
    .SLEW("SLOW")           // Specify the output slew rate
  ) RazChn (
    .O(RAZ_CHNP),           // Diff_p output (connect directly to top-level port)
    .OB(RAZ_CHNN),          // Diff_n output (connect directly to top-level port)
    .I(RAZ_CHN)             // Buffer input
    );
  // VAL_EVT should always set 1
  OBUFDS #(
    .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
    .SLEW("SLOW")           // Specify the output slew rate
  ) ValEvt (
    .O(VAL_EVTP),           // Diff_p output (connect directly to top-level port)
    .OB(VAL_EVTN),          // Diff_n output (connect directly to top-level port)
    .I(1'b1)                // Buffer input
    );
  // CK_40
  OBUFDS #(
    .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
    .SLEW("SLOW")           // Specify the output slew rate
  ) Ck40M (
    .O(CK_40P),             // Diff_p output (connect directly to top-level port)
    .OB(CK_40N),            // Diff_n output (connect directly to top-level port)
    .I(Clk)                 // Buffer input
    );
  // CK_5
  OBUFDS #(
    .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
    .SLEW("SLOW")           // Specify the output slew rate
  ) Ck5M (
    .O(CK_5P),              // Diff_p output (connect directly to top-level port)
    .OB(CK_5N),             // Diff_n output (connect directly to top-level port)
    .I(SlowClock)           // Buffer input
    );
endmodule
