`timescale 1ns / 1ns

////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:   11:22:31 07/05/2018
// Design Name:   SCurve_Test_Top
// Module Name:   C:/WangYu/TestBenchInst/SCurve_Test_Top_tb.v
// Project Name:  TestBenchInst
// Target Device:
// Tool versions:
// Description:
//
// Verilog Test Fixture created by ISE for module: SCurve_Test_Top
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module SCurve_Test_Top_tb;

  // Inputs
  reg Clk;
  reg Clk_5M;
  reg reset_n;
  reg TrigEffi_or_CountEffi;
  reg Test_Start;
  reg [5:0] SingleTest_Chn;
  reg Single_or_64Chn;
  reg Ctest_or_Input;
  reg [15:0] CPT_MAX;
  reg [15:0] Counter_MAX;
  reg [9:0] StartDac;
  reg [9:0] EndDac;
  reg [9:0] AdcInterval;
  reg [3:0] TriggerDelay;
  reg [2:0] AsicNumber;
  reg [2:0] TestAsicNumber;
  reg UnmaskAllChannel;
  reg usb_data_fifo_full;
  reg Microroc_Config_Done;
  reg CLK_EXT;
  reg out_trigger0b;
  reg out_trigger1b;
  reg out_trigger2b;
  reg Data_Transmit_Done;
  reg TriggerClk;
  reg [19:0] TriggerSuppressWidth;

  // Outputs
  wire usb_data_fifo_wr_en;
  wire [15:0] usb_data_fifo_wr_din;
  wire [63:0] Microroc_CTest_Chn_Out;
  wire [9:0] Microroc_10bit_DAC_Out;
  wire [191:0] Microroc_Discriminator_Mask;
  wire SC_Param_Load;
  wire Force_Ext_RAZ;
  wire SCurve_Test_Done;

  // Instantiate the Unit Under Test (UUT)
  SCurve_Test_Top uut (
    .Clk(Clk),
    .Clk_5M(Clk_5M),
    .reset_n(reset_n),
    .TriggerEfficiencyOrCountEfficiency(TrigEffi_or_CountEffi),
    .Test_Start(Test_Start),
    .SingleTestChannel(SingleTest_Chn),
    .Single_or_64Chn(Single_or_64Chn),
    .Ctest_or_Input(Ctest_or_Input),
    .CPT_MAX(CPT_MAX),
    .Counter_MAX(Counter_MAX),
    .StartDac(StartDac),
    .EndDac(EndDac),
    .DacStep(AdcInterval),
    .TriggerDelay(TriggerDelay),
    .AsicNumber(AsicNumber),
    .TestAsicNumber(TestAsicNumber),
    .UnmaskAllChannel(UnmaskAllChannel),
    .SCurveTestDataoutEnable(usb_data_fifo_wr_en),
    .SCurveTestDataout(usb_data_fifo_wr_din),
    .ExternalDataFifoFull(usb_data_fifo_full),
    .MicrorocConfigurationDone(Microroc_Config_Done),
    .Microroc_CTest_Chn_Out(Microroc_CTest_Chn_Out),
    .Microroc_10bit_DAC_Out(Microroc_10bit_DAC_Out),
    .Microroc_Discriminator_Mask(Microroc_Discriminator_Mask),
    .SlowControlParameterLoadStart(SC_Param_Load),
    .Force_Ext_RAZ(Force_Ext_RAZ),
    .TriggerSuppressWidth(TriggerSuppressWidth),
    .CLK_EXT(CLK_EXT),
    .out_trigger0b(out_trigger0b),
    .out_trigger1b(out_trigger1b),
    .out_trigger2b(out_trigger2b),
    .SCurve_Test_Done(SCurve_Test_Done),
    .Data_Transmit_Done(Data_Transmit_Done)
    );

  initial begin
    // Initialize Inputs
    Clk = 0;
    Clk_5M = 0;
    reset_n = 0;
    TrigEffi_or_CountEffi = 0;
    Test_Start = 0;
    SingleTest_Chn = 3;
    Single_or_64Chn = 0;
    Ctest_or_Input = 1;
    CPT_MAX = 20;
    Counter_MAX = 20;
    StartDac = 500;
    EndDac = 550;
    AdcInterval = 1;
    TriggerDelay = 2;
    AsicNumber = 4;
    TestAsicNumber = 1;
    UnmaskAllChannel = 0;
    usb_data_fifo_full = 0;
    Microroc_Config_Done = 0;
    CLK_EXT = 0;
    out_trigger0b = 1;
    out_trigger1b = 1;
    out_trigger2b = 1;
    TriggerClk = 1'b0;
    TriggerSuppressWidth = 20'hB71B0;
    // Data_Transmit_Done = 0;

    // Wait 100 ns for global reset to finish
    #100;
    reset_n = 1'b1;

    // Add stimulus here
    #10000;
    Test_Start = 1'b1;
    
  end
  localparam LOW = 13;
  localparam HIGH = 12;
  localparam CLK_EXT_PEROID = 5000;
  localparam Clk_5M_PEROID = 100;
  always begin
    #(LOW) Clk = ~Clk;
    #(HIGH) Clk = ~Clk;
  end
  always #(CLK_EXT_PEROID) CLK_EXT = ~CLK_EXT;
  always #(Clk_5M_PEROID) Clk_5M = ~Clk_5M;

  reg [3:0] DelayCount;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      Data_Transmit_Done <= 1'b1;
      DelayCount <= 4'b0;
    end
    else if(Data_Transmit_Done && (DelayCount != 4'b0 || DelayCount <= 4'd15)) begin
      Data_Transmit_Done <= (DelayCount == 4'd15);
      DelayCount <= DelayCount + 1'b1;
    end
    else begin
      DelayCount <= 4'd0;
      Data_Transmit_Done <= 1'b0;
    end
  end

  localparam TRIGGER_CLK_PEROID = 27;
  always #(TRIGGER_CLK_PEROID) TriggerClk = ~TriggerClk;

  reg [6:0] Trigger0Count;
  reg [7:0] Trigger1Count;
  reg [8:0] Trigger2Count;
  always @ (posedge TriggerClk or negedge reset_n) begin
    if(~reset_n) begin
      Trigger0Count <= 7'b0;
      out_trigger0b <= 1'b1;
    end
    else if(Trigger0Count == 7'h7F) begin
      Trigger1Count <= 7'b0;
      out_trigger0b <= 1'b0;
    end
    else begin
      Trigger0Count <= Trigger0Count + 1'b1;
      out_trigger0b <= 1'b1;
    end
  end
  always @ (posedge TriggerClk or negedge reset_n) begin
    if(~reset_n) begin
      Trigger1Count <= 8'b0;
      out_trigger1b <= 1'b1;
    end
    else if(Trigger1Count == 8'hFF) begin
      Trigger1Count <= 8'b0;
      out_trigger1b <= 1'b0;
    end
    else begin
      Trigger1Count <= Trigger1Count + 1'b1;
      out_trigger1b <= 1'b1;
    end
  end
  always @ (posedge TriggerClk or negedge reset_n) begin
    if(~reset_n) begin
      Trigger2Count <= 9'b0;
      out_trigger2b <= 1'b1;
    end
    else if(Trigger2Count == 9'h1FF) begin
      Trigger2Count <= 9'b0;
      out_trigger2b <= 1'b0;
    end
    else begin
      Trigger2Count <= Trigger2Count + 1'b1;
      out_trigger2b <= 1'b1;
    end
  end




  reg [2:0] SC_Load_Cnt;
  always @(posedge Clk or negedge reset_n)begin
    if(~reset_n)begin
      SC_Load_Cnt <= 3'b0;
      Microroc_Config_Done <= 1'b0;
    end
    else if(SC_Param_Load ||(SC_Load_Cnt != 3'd0 && SC_Load_Cnt <= 3'd7))begin
      SC_Load_Cnt <= SC_Load_Cnt + 1'b1;
      Microroc_Config_Done <= (SC_Load_Cnt == 3'd7);
    end
    else begin
      SC_Load_Cnt <= 3'd0;
      Microroc_Config_Done <= 1'b0;
    end
  end

endmodule

