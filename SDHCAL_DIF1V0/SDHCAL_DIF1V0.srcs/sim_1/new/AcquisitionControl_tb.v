`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:16:00 07/09/2018
// Design Name:   AcquisitionControl
// Module Name:   C:/WangYu/TestBenchInst/AcquisitionControl_tb.v
// Project Name:  TestBenchInst
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: AcquisitionControl
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module AcquisitionControl_tb;

	// Inputs
	reg Clk;
	reg Clk5M;
	reg reset_n;
	reg [3:0] ModeSelect;
	reg [15:0] MicrorocAcquisitionData;
	reg MicrorocAcquisitionDataEnable;
	reg ExternalFifoFull;
	reg CommandMicrorocConfigurationParameterLoad;
	reg MicrorocConfigurationDone;
	reg [63:0] CommandMicrorocCTestChannel;
	reg [191:0] CommandMicrorocChannelDiscriminatorMask;
	reg [9:0] CommandMicrorocVth0Dac;
	reg [9:0] CommandMicrorocVth1Dac;
	reg [9:0] CommandMicrorocVth2Dac;
	reg CommandMicrorocSlowControlOrReadScopeSelect;
	reg CommandMicrorocAcquisitionStartStop;
	reg CommandSCurveTestStartStop;
	reg CommandAdcStartStop;
	reg nPKTEND;
	reg TriggerEfficiencyOrCountEfficiency;
	reg [5:0] SingleTestChannel;
	reg SingleOr64Channel;
	reg CTestOrInput;
	reg [15:0] TriggerCountMax;
	reg [15:0] CounterMax;
	reg [9:0] StartDac;
	reg [9:0] EndDac;
	reg [9:0] DacStep;
	reg [3:0] TriggerDelay;
	reg [2:0] AsicNumber;
	reg [2:0] TestAsicNumber;
	reg UnmaskAllChannel;
	reg SynchronousSignalIn;
	reg OutTrigger0b;
	reg OutTrigger1b;
	reg OutTrigger2b;
	reg HoldSignal;
	reg [3:0] AdcStartDelay;
	reg [7:0] AdcDataNumber;
	reg [11:0] ADC_DATA;
	reg ADC_OTR;
	wire ADC_CLK;
  reg TriggerClk;

	// Outputs
	wire [15:0] OutTestData;
	wire OutTestDataEnable;
	wire MicrorocConfigurationParameterLoad;
	wire [63:0] MicrorocCTestChannel;
	wire [191:0] MicrorocChannelDiscriminatorMask;
	wire [9:0] OutMicrorocVth0Dac;
	wire [9:0] OutMicrorocVth1Dac;
	wire [9:0] OutMicrorocVth2Dac;
	wire MicrorocSlowControlOrReadScopeSelect;
	wire ForceExternalRaz;
	wire OutUsbStartStop;
	wire TestDone;

	// Instantiate the Unit Under Test (UUT)
	AcquisitionControl uut (
		.Clk(Clk), 
		.Clk5M(Clk5M), 
		.reset_n(reset_n), 
		.ModeSelect(ModeSelect), 
		.MicrorocAcquisitionData(MicrorocAcquisitionData), 
		.MicrorocAcquisitionDataEnable(MicrorocAcquisitionDataEnable), 
		.ExternalFifoFull(ExternalFifoFull), 
		.OutTestData(OutTestData), 
		.OutTestDataEnable(OutTestDataEnable), 
		.CommandMicrorocConfigurationParameterLoad(CommandMicrorocConfigurationParameterLoad), 
		.MicrorocConfigurationParameterLoad(MicrorocConfigurationParameterLoad), 
		.MicrorocConfigurationDone(MicrorocConfigurationDone), 
		.CommandMicrorocCTestChannel(CommandMicrorocCTestChannel), 
		.MicrorocCTestChannel(MicrorocCTestChannel), 
		.CommandMicrorocChannelDiscriminatorMask(CommandMicrorocChannelDiscriminatorMask), 
		.MicrorocChannelDiscriminatorMask(MicrorocChannelDiscriminatorMask), 
		.CommandMicrorocVth0Dac(CommandMicrorocVth0Dac), 
		.CommandMicrorocVth1Dac(CommandMicrorocVth1Dac), 
		.CommandMicrorocVth2Dac(CommandMicrorocVth2Dac), 
		.OutMicrorocVth0Dac(OutMicrorocVth0Dac), 
		.OutMicrorocVth1Dac(OutMicrorocVth1Dac), 
		.OutMicrorocVth2Dac(OutMicrorocVth2Dac), 
		.CommandMicrorocSlowControlOrReadScopeSelect(CommandMicrorocSlowControlOrReadScopeSelect), 
		.MicrorocSlowControlOrReadScopeSelect(MicrorocSlowControlOrReadScopeSelect), 
		.ForceExternalRaz(ForceExternalRaz), 
		.CommandMicrorocAcquisitionStartStop(CommandMicrorocAcquisitionStartStop), 
		.CommandSCurveTestStartStop(CommandSCurveTestStartStop), 
		.CommandAdcStartStop(CommandAdcStartStop), 
		.OutUsbStartStop(OutUsbStartStop), 
		.nPKTEND(nPKTEND), 
		.TestDone(TestDone), 
		.TriggerEfficiencyOrCountEfficiency(TriggerEfficiencyOrCountEfficiency), 
		.SingleTestChannel(SingleTestChannel), 
		.SingleOr64Channel(SingleOr64Channel), 
		.CTestOrInput(CTestOrInput), 
		.TriggerCountMax(TriggerCountMax), 
		.CounterMax(CounterMax), 
		.StartDac(StartDac), 
		.EndDac(EndDac), 
		.DacStep(DacStep), 
		.TriggerDelay(TriggerDelay), 
		.AsicNumber(AsicNumber), 
		.TestAsicNumber(TestAsicNumber), 
		.UnmaskAllChannel(UnmaskAllChannel), 
		.SynchronousSignalIn(SynchronousSignalIn), 
		.OutTrigger0b(OutTrigger0b), 
		.OutTrigger1b(OutTrigger1b), 
		.OutTrigger2b(OutTrigger2b), 
		.HoldSignal(HoldSignal), 
		.AdcStartDelay(AdcStartDelay), 
		.AdcDataNumber(AdcDataNumber), 
		.ADC_DATA(ADC_DATA), 
		.ADC_OTR(ADC_OTR), 
		.ADC_CLK(ADC_CLK)
	);

	initial begin
		// Initialize Inputs
		Clk =1'b0;
		Clk5M = 1'b0;
		reset_n = 1'b0;
    TriggerClk = 1'b0;
		ModeSelect = 4'b0;
		ExternalFifoFull = 1'b00;
		CommandMicrorocConfigurationParameterLoad = 0;
		CommandMicrorocCTestChannel = 64'h8;
		CommandMicrorocChannelDiscriminatorMask = 192'hFFF;
		CommandMicrorocVth0Dac = 10'd50;
		CommandMicrorocVth1Dac = 10'd150;
		CommandMicrorocVth2Dac = 10'd300;
		CommandMicrorocSlowControlOrReadScopeSelect = 1'b1;
		CommandMicrorocAcquisitionStartStop = 0;
		CommandSCurveTestStartStop = 0;
		CommandAdcStartStop = 0;
		nPKTEND = 1'b1;
		TriggerEfficiencyOrCountEfficiency = 1'b1;
		SingleTestChannel = 6'd15;
		SingleOr64Channel = 0;
		CTestOrInput = 0;
		TriggerCountMax = 16'd20;
		CounterMax = 16'd20;
    StartDac = 10'd50;
		EndDac = 10'd100;
		DacStep = 10'd1;
		TriggerDelay = 4'd1;
		AsicNumber = 3'd4;
		TestAsicNumber = 3'd1;
		UnmaskAllChannel = 0;
		SynchronousSignalIn = 0;
		HoldSignal = 0;
		AdcStartDelay = 4'b1;
		AdcDataNumber = 8'd2;
		ADC_OTR = 0;

		// Wait 100 ns for global reset to finish
		#100;
    reset_n = 1'b1;
        
		// Add stimulus here
    #10000;
    CommandMicrorocAcquisitionStartStop = 1'b1;
    #10000;
    CommandMicrorocAcquisitionStartStop = 1'b0;
    // ModeSelect = 4'd1;
    ModeSelect = 4'd2;
    #2000;
    //CommandSCurveTestStartStop = 1'b1;
    CommandAdcStartStop = 1'b1;
	end
  localparam LOW = 13;
  localparam HIGH = 12;
  localparam PEROID = 200;
  localparam SYNC_CLK_PEROID = 1000;

  always begin
    #(LOW) Clk = ~Clk;
    #(HIGH) Clk = ~Clk;
  end
  always #(PEROID/2) Clk5M = ~Clk5M;
  always #(SYNC_CLK_PEROID/2) SynchronousSignalIn = ~SynchronousSignalIn;
  
  localparam TRIGGER_CLK_PEROID = 27;
  always #(TRIGGER_CLK_PEROID) TriggerClk = ~TriggerClk;
  reg [6:0] Trigger0Count;
  reg [7:0] Trigger1Count;
  reg [8:0] Trigger2Count;
  always @ (posedge TriggerClk or negedge reset_n) begin
    if(~reset_n) begin
      Trigger0Count <= 7'b0;
      OutTrigger0b <= 1'b1;
    end
    else if(Trigger0Count == 7'h7F) begin
      Trigger0Count <= 7'b0;
      OutTrigger0b <= 1'b0;
    end
    else begin
      Trigger0Count <= Trigger0Count + 1'b1;
      OutTrigger0b <= 1'b1;
    end
  end
  always @ (posedge TriggerClk or negedge reset_n) begin
    if(~reset_n) begin
      Trigger1Count <= 8'b0;
      OutTrigger1b <= 1'b1;
    end
    else if(Trigger1Count == 8'hFF) begin
      Trigger1Count <= 8'b0;
      OutTrigger1b <= 1'b0;
    end
    else begin
      Trigger1Count <= Trigger1Count + 1'b1;
      OutTrigger1b <= 1'b1;
    end
  end
  always @ (posedge TriggerClk or negedge reset_n) begin
    if(~reset_n) begin
      Trigger2Count <= 9'b0;
      OutTrigger2b <= 1'b1;
    end
    else if(Trigger2Count == 9'h1FF) begin
      Trigger2Count <= 9'b0;
      OutTrigger2b <= 1'b0;
    end
    else begin
      Trigger2Count <= Trigger2Count + 1'b1;
      OutTrigger2b <= 1'b1;
    end
  end
  reg [2:0] SC_Load_Cnt;
  always @(posedge Clk or negedge reset_n)begin
    if(~reset_n)begin
      SC_Load_Cnt <= 3'b0;
      MicrorocConfigurationDone <= 1'b0;
    end
    else if(MicrorocConfigurationParameterLoad ||(SC_Load_Cnt != 3'd0 && SC_Load_Cnt <= 3'd7))begin
      SC_Load_Cnt <= SC_Load_Cnt + 1'b1;
      MicrorocConfigurationDone <= (SC_Load_Cnt == 3'd7);
    end
    else begin
      SC_Load_Cnt <= 3'd0;
      MicrorocConfigurationDone <= 1'b0;
    end
  end
  reg [3:0] DataCount;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      MicrorocAcquisitionData <= 16'b0;
      MicrorocAcquisitionDataEnable <= 1'b0;
      DataCount <= 4'b0;
    end
    else if(~CommandMicrorocAcquisitionStartStop) begin
      MicrorocAcquisitionData <= 16'b0;
      MicrorocAcquisitionDataEnable <= 1'b0;
      DataCount <= 4'b0;
    end
    else if(DataCount == 4'd15) begin
      MicrorocAcquisitionData <= MicrorocAcquisitionData + 1'b1;
      MicrorocAcquisitionDataEnable <= 1'b1;
      DataCount <= DataCount + 1'b1;
    end
    else begin
      MicrorocAcquisitionData <= MicrorocAcquisitionData;
      MicrorocAcquisitionDataEnable <= 1'b0;
      DataCount <= DataCount + 1'b1;
    end
  end
  
  reg [3:0] PKTEND_COUNT;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      nPKTEND <= 1'b1;
      PKTEND_COUNT <= 4'b0;
    end
    else if(TestDone || (PKTEND_COUNT != 4'b0 && PKTEND_COUNT <= 4'd15)) begin
      nPKTEND <= 1'b0;
      PKTEND_COUNT <= PKTEND_COUNT + 1'b1;
    end
    else begin
      nPKTEND <= 1'b1;
      PKTEND_COUNT <= 4'b0;
    end
  end

  always @ (posedge ADC_CLK or negedge reset_n) begin
    if(~reset_n) begin
      ADC_DATA <= 12'b0;
    end
    else if(CommandAdcStartStop)
      ADC_DATA <= ADC_DATA + 2'b10;
    else
      ADC_DATA <= ADC_DATA;
  end

  reg [15:0] HoldCount;
  reg HoldSet;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      HoldCount <= 16'b0;
      HoldSet <= 1'b0;
    end
    else if(HoldCount == 16'hFFFF) begin
      HoldSet <= 1'b1;
      HoldCount <= HoldCount + 1'b1;
    end
    else begin
      HoldSet <= 1'b0;
      HoldCount <= HoldCount + 1'b1;
    end
  end
  reg [5:0] HoldEnableCount;
  always @ (posedge Clk or negedge reset_n) begin 
    if(~reset_n) begin
      HoldSignal <= 1'b0;
      HoldEnableCount <= 6'b0;
    end
    else if(HoldSet || (HoldEnableCount != 0 && HoldEnableCount <= 6'h3F)) begin
      HoldEnableCount <= HoldEnableCount + 1'b1;
      HoldSignal <= 1'b1;
    end
    else begin
      HoldSignal <= 1'b0;
      HoldEnableCount <= 6'b0;
    end
  end
endmodule

