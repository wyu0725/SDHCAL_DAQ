`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:   17:14:13 07/11/2018
// Design Name:   MicrorocControl
// Module Name:   C:/WangYu/TestBenchInst/MicrorocControl_tb.v
// Project Name:  TestBenchInst
// Target Device:
// Tool versions:
// Description:
//
// Verilog Test Fixture created by ISE for module: MicrorocControl
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module MicrorocControl_tb;

  // Inputs
  reg Clk;
  reg reset_n;
  reg SlowClock;
  wire Clk5M;
  reg SyncClk;
  reg MicrorocReset;
  reg SlowControlOrReadScopeSelect;
  reg ParameterLoadStart;
  reg [1:0] DataoutChannelSelect;
  reg [1:0] TransmitOnChannelSelect;
  reg ChipSatbEnable;
  reg StartReadoutChannelSelect;
  reg EndReadoutChannelSelect;
  reg [1:0] NC;
  reg [1:0] InternalRazSignalLength;
  reg CkMux;
  reg LvdsReceiverPPEnable;
  reg ExternalRazSignalEnable;
  reg InternalRazSignalEnable;
  reg ExternalTriggerEnable;
  reg TriggerNor64OrDirectSelect;
  reg TriggerOutputEnable;
  reg [2:0] TriggerToWriteSelect;
  reg [9:0] Dac2Vth;
  reg [9:0] Dac1Vth;
  reg [9:0] Dac0Vth;
  reg DacEnable;
  reg DacPPEnable;
  reg BandGapEnable;
  reg BandGapPPEnable;
  reg [7:0] ChipID;
  reg [191:0] ChannelDiscriminatorMask;
  reg LatchedOrDirectOutput;
  reg Discriminator1PPEnable;
  reg Discriminator2PPEnable;
  reg Discriminator0PPEnable;
  reg OTAqPPEnable;
  reg OTAqEnable;
  reg Dac4bitPPEnable;
  reg [255:0] ChannelAdjust;
  reg [1:0] HighGainShaperFeedbackSelect;
  reg ShaperOutLowGainOrHighGain;
  reg WidlarPPEnable;
  reg [1:0] LowGainShaperFeedbackSelect;
  reg LowGainShaperPPEnable;
  reg HighGainShaperPPEnable;
  reg GainBoostEnable;
  reg PreAmplifierPPEnable;
  reg [63:0] CTestChannel;
  reg [63:0] ReadScopeChannel;
  reg PowerPulsingPinEnable;
  reg ReadoutChannelSelect;
  reg TimeStampReset;
  reg TriggerIn;
  reg [1:0] RazMode;
  reg SCurveForceExternalRaz;
  reg [3:0] ExternalRazDelayTime;
  reg nPKTEND;
  reg ExternalFifoFull;
  reg ExternalFifoEmpty;
  reg DaqSelect;
  reg AcqStart;
  reg [15:0] AcquisitionStartTime;
  reg [15:0] EndHoldTime;
  reg HoldEnable;
  reg [7:0] HoldDelay;
  reg [15:0] HoldTime;
  reg CHIPSATB;
  wire END_READOUT1;
  wire END_READOUT2;
  wire DOUT1B;
  wire DOUT2B;
  reg TRANSMITON1B;
  reg TRANSMITON2B;

  // Outputs
  wire ParameterLoadDone;
  wire [15:0] ExternalFifoData;
  wire ExternalFifoDataEnable;
  wire TestDone;
  wire UsbStartStop;
  wire SELECT;
  wire SR_RSTB;
  wire SR_CK;
  wire SR_IN;
  wire PWR_ON_D;
  wire PWR_ON_A;
  wire PWR_ON_DAC;
  wire PWR_ON_ADC;
  wire START_ACQ;
  wire RESET_B;
  wire START_READOUT1;
  wire START_READOUT2;
  wire HOLD;
  wire TRIG_EXT;
  wire RAZ_CHNP;
  wire RAZ_CHNN;
  wire VAL_EVTP;
  wire VAL_EVTN;
  wire RST_COUNTERB;
  wire CK_40P;
  wire CK_40N;
  wire CK_5P;
  wire CK_5N;

  // Instantiate the Unit Under Test (UUT)
  MicrorocControl uut (
    .Clk(Clk),
    .reset_n(reset_n),
    .SlowClock(SlowClock),
    .Clk5M(Clk5M),
    .SyncClk(SyncClk),
    .MicrorocReset_n(MicrorocReset),
    .SlowControlOrReadScopeSelect(SlowControlOrReadScopeSelect),
    .ParameterLoadStart(ParameterLoadStart),
    .ParameterLoadDone(ParameterLoadDone),
    .DataoutChannelSelect(DataoutChannelSelect),
    .TransmitOnChannelSelect(TransmitOnChannelSelect),
    .ChipSatbEnable(ChipSatbEnable),
    .StartReadoutChannelSelect(StartReadoutChannelSelect),
    .EndReadoutChannelSelect(EndReadoutChannelSelect),
    .NC(NC),
    .InternalRazSignalLength(InternalRazSignalLength),
    .CkMux(CkMux),
    .LvdsReceiverPPEnable(LvdsReceiverPPEnable),
    .ExternalRazSignalEnable(ExternalRazSignalEnable),
    .InternalRazSignalEnable(InternalRazSignalEnable),
    .ExternalTriggerEnable(ExternalTriggerEnable),
    .TriggerNor64OrDirectSelect(TriggerNor64OrDirectSelect),
    .TriggerOutputEnable(TriggerOutputEnable),
    .TriggerToWriteSelect(TriggerToWriteSelect),
    .Dac2Vth(Dac2Vth),
    .Dac1Vth(Dac1Vth),
    .Dac0Vth(Dac0Vth),
    .DacEnable(DacEnable),
    .DacPPEnable(DacPPEnable),
    .BandGapEnable(BandGapEnable),
    .BandGapPPEnable(BandGapPPEnable),
    .ChipID(ChipID),
    .ChannelDiscriminatorMask(ChannelDiscriminatorMask),
    .LatchedOrDirectOutput(LatchedOrDirectOutput),
    .Discriminator1PPEnable(Discriminator1PPEnable),
    .Discriminator2PPEnable(Discriminator2PPEnable),
    .Discriminator0PPEnable(Discriminator0PPEnable),
    .OTAqPPEnable(OTAqPPEnable),
    .OTAqEnable(OTAqEnable),
    .Dac4bitPPEnable(Dac4bitPPEnable),
    .ChannelAdjust(ChannelAdjust),
    .HighGainShaperFeedbackSelect(HighGainShaperFeedbackSelect),
    .ShaperOutLowGainOrHighGain(ShaperOutLowGainOrHighGain),
    .WidlarPPEnable(WidlarPPEnable),
    .LowGainShaperFeedbackSelect(LowGainShaperFeedbackSelect),
    .LowGainShaperPPEnable(LowGainShaperPPEnable),
    .HighGainShaperPPEnable(HighGainShaperPPEnable),
    .GainBoostEnable(GainBoostEnable),
    .PreAmplifierPPEnable(PreAmplifierPPEnable),
    .CTestChannel(CTestChannel),
    .ReadScopeChannel(ReadScopeChannel),
    .PowerPulsingPinEnable(PowerPulsingPinEnable),
    .ReadoutChannelSelect(ReadoutChannelSelect),
    .TimeStampReset(TimeStampReset),
    .TriggerIn(TriggerIn),
    .RazMode(RazMode),
    .SCurveForceExternalRaz(SCurveForceExternalRaz),
    .ExternalRazDelayTime(ExternalRazDelayTime),
    .ExternalFifoData(ExternalFifoData),
    .ExternalFifoDataEnable(ExternalFifoDataEnable),
    .TestDone(TestDone),
    .nPKTEND(nPKTEND),
    .ExternalFifoFull(ExternalFifoFull),
    .ExternalFifoEmpty(ExternalFifoEmpty),
    .DaqSelect(DaqSelect),
    .AcqStart(AcqStart),
    .UsbStartStop(UsbStartStop),
    .AcquisitionStartTime(AcquisitionStartTime),
    .EndHoldTime(EndHoldTime),
    .HoldEnable(HoldEnable),
    .HoldDelay(HoldDelay),
    .HoldTime(HoldTime),
    .SELECT(SELECT),
    .SR_RSTB(SR_RSTB),
    .SR_CK(SR_CK),
    .SR_IN(SR_IN),
    .PWR_ON_D(PWR_ON_D),
    .PWR_ON_A(PWR_ON_A),
    .PWR_ON_DAC(PWR_ON_DAC),
    .PWR_ON_ADC(PWR_ON_ADC),
    .START_ACQ(START_ACQ),
    .RESET_B(RESET_B),
    .CHIPSATB(CHIPSATB),
    .START_READOUT1(START_READOUT1),
    .START_READOUT2(START_READOUT2),
    .END_READOUT1(END_READOUT1),
    .END_READOUT2(END_READOUT2),
    .DOUT1B(DOUT1B),
    .DOUT2B(DOUT2B),
    .TRANSMITON1B(TRANSMITON1B),
    .TRANSMITON2B(TRANSMITON2B),
    .HOLD(HOLD),
    .TRIG_EXT(TRIG_EXT),
    .RAZ_CHNP(RAZ_CHNP),
    .RAZ_CHNN(RAZ_CHNN),
    .VAL_EVTP(VAL_EVTP),
    .VAL_EVTN(VAL_EVTN),
    .RST_COUNTERB(RST_COUNTERB),
    .CK_40P(CK_40P),
    .CK_40N(CK_40N),
    .CK_5P(CK_5P),
    .CK_5N(CK_5N)
    );

  initial begin
    Clk = 1'b0;
    reset_n = 1'b0;
    SlowClock = 1'b0;
    SyncClk = 1'b0;
    MicrorocReset = 1'b0;
    SlowControlOrReadScopeSelect = 1'b0;
    ParameterLoadStart = 1'b0;
    DataoutChannelSelect = 2'b01;
    TransmitOnChannelSelect = 2'b01;
    ChipSatbEnable = 1'b1;
    StartReadoutChannelSelect = 1'b0;
    EndReadoutChannelSelect = 1'b0;
    NC = 2'b11;
    InternalRazSignalLength = 2'b01;
    CkMux = 1'b1;
    LvdsReceiverPPEnable = 1'b0;
    ExternalRazSignalEnable = 1'b1;
    InternalRazSignalEnable = 1'b0;
    ExternalTriggerEnable = 1'b1;
    TriggerNor64OrDirectSelect = 1'b1;
    TriggerOutputEnable = 1'b1;
    TriggerToWriteSelect = 3'b111;
    Dac2Vth = 9'b0_1010_0101;
    Dac1Vth = 9'b0_0101_1010;
    Dac0Vth = 9'b1_1010_1100;
    DacEnable = 1'b1;;
    DacPPEnable = 1'b0;
    BandGapEnable = 1'b0;
    BandGapPPEnable = 1'b1;
    ChipID = 8'b0110_1010;
    ChannelDiscriminatorMask = {192{1'b1}};
    LatchedOrDirectOutput = 1'b0;
    Discriminator2PPEnable = 1'b1;
    Discriminator1PPEnable = 1'b0;
    Discriminator0PPEnable = 1'b1;
    OTAqPPEnable = 1'b0;
    OTAqEnable = 1'b1;
    Dac4bitPPEnable = 1'b1;
    ChannelAdjust = {128{2'b10}};
    HighGainShaperFeedbackSelect = 2'b11;
    ShaperOutLowGainOrHighGain = 2'b0;
    WidlarPPEnable = 1'b1;
    LowGainShaperFeedbackSelect = 2'b01;
    LowGainShaperPPEnable = 1'b0;
    HighGainShaperPPEnable = 1'b1;
    GainBoostEnable = 1'b1;
    PreAmplifierPPEnable = 1'b0;
    CTestChannel = {32{2'b10}};
    ReadScopeChannel = {32{2'b01}};
    PowerPulsingPinEnable = 1'b0;
    ReadoutChannelSelect = 1'b1;
    TimeStampReset = 1'b0;
    TriggerIn = 1'b0;
    RazMode = 1'b1;
    SCurveForceExternalRaz = 0;
    ExternalRazDelayTime = 4'd2;
    nPKTEND = 0;
    ExternalFifoFull = 0;
    ExternalFifoEmpty = 0;
    DaqSelect = 1'b1;
    AcqStart = 0;
    AcquisitionStartTime = 16'd60;
    EndHoldTime = 16'd50;
    HoldEnable = 0;
    HoldDelay = 8'd11;
    HoldTime = 16'd20;

    // Wait 100 ns for global reset to finish
    #100;
    reset_n = 1'b1;
    MicrorocReset <= 1'b1;
    #10000;
    ParameterLoadStart = 1'b1;
    #25;
    ParameterLoadStart = 1'b0;
    #600_000;
    SlowControlOrReadScopeSelect = 1'b1;
    #100;
    ParameterLoadStart = 1'b1;
    #25;
    ParameterLoadStart = 1'b0;
    #30000;
    AcqStart = 1'b1;
    #100000;
    PowerPulsingPinEnable = 1'b1;
    #100000;
    AcqStart = 1'b0;
    DaqSelect = 1'b0;
    #10000;
    AcqStart = 1'b1;
    #80000000;
    AcqStart = 1'b0;
    #10000;
    HoldEnable = 1'b1;
    #20000;
    TimeStampReset = 1'b1;
    #25;
    TimeStampReset = 1'b0;

    // Add stimulus here

  end

  reg [2:0] AcqState;
  reg [5:0] StartCount;
  reg [15:0] RandomData;
  reg [3:0] DataoutCount;
  reg [2:0] DataShiftCount;
  wire StartReadout;
  assign StartReadout = START_READOUT1 || START_READOUT2;
  reg EndReadout;
  assign END_READOUT1 = EndReadout;
  assign END_READOUT2 = EndReadout;
  localparam [2:0] IDLE = 3'd0,
                   START = 3'd1,
                   WAIT_ACQUISITION = 3'd2,
                   CHIP_FULL = 3'd3,
                   READ_DATA = 3'd4,
                   CHIP_EMPTY = 3'd5,
                   DATA_END = 3'd6;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      RandomData <= 16'b0;
      AcqState <= IDLE;
      StartCount <= 6'd0;
      CHIPSATB <= 1'b1;
      DataoutCount <= 4'd0;
      DataShiftCount <= 3'd0;
      EndReadout <= 1'b0;
      TRANSMITON1B <= 1'b1;
      TRANSMITON2B <= 1'b1;
    end
    else begin
      case(AcqState)
        IDLE:begin
          EndReadout <= 1'b0;
          if(START_ACQ) begin
            AcqState <= START;
          end
          else begin
            AcqState <= IDLE;
          end
        end
        START:begin
          if(StartCount < 6'd60 && START_ACQ) begin
            StartCount <= StartCount + 1'b1;
            AcqState <= START;
          end
          else begin
            StartCount <= 6'd0;
            CHIPSATB <= 1'b0;
            AcqState <= CHIP_FULL;
          end
        end
        CHIP_FULL:begin
          if(StartReadout) begin
            RandomData <= {$random};
            AcqState <= READ_DATA;
          end
          else begin
            CHIPSATB <= 1'b1;
            AcqState <= CHIP_FULL;
          end
        end
        READ_DATA:begin
          TRANSMITON1B <= 1'b0;
          TRANSMITON2B <= 1'b0;
          if(DataoutCount == 4'd15) begin
            AcqState <= CHIP_EMPTY;
            DataoutCount <= 4'd0;
            DataShiftCount <= 3'd0;
          end
          else if(DataShiftCount == 3'd7) begin
            AcqState <= READ_DATA;
            DataoutCount <= DataoutCount + 1'b1;
            DataShiftCount <= DataShiftCount + 1'b1;
            RandomData <= RandomData << 1'b1;
          end
          else begin
            AcqState <= READ_DATA;
            DataShiftCount <= DataShiftCount + 1'b1;
          end
        end
        CHIP_EMPTY: begin
          TRANSMITON1B <= 1'b1;
          TRANSMITON2B <= 1'b1;
          CHIPSATB <= 1'b1;
          AcqState <= DATA_END;
        end
        DATA_END:begin
          EndReadout <= 1'b1;
          AcqState <= IDLE;
        end
      endcase
    end
  end
  assign DOUT1B = RandomData[15];
  assign DOUT2B = RandomData[15];
  reg [15:0] RandomGenerator;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n)
      RandomGenerator <= 16'ha5a5;
    else if(StartReadout)
      RandomGenerator <= {$random};
    else
      RandomGenerator <= RandomGenerator;

  end
  reg [3:0] DelayCount;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      nPKTEND <= 1'b1;
      DelayCount <= 4'b0;
    end
    else if(TestDone && (DelayCount != 4'b0 || DelayCount <= 4'd15)) begin
      nPKTEND <= ~(DelayCount == 4'd15);
      DelayCount <= DelayCount + 1'b1;
    end
    else begin
      DelayCount <= 4'd0;
      nPKTEND <= 1'b1;
    end
  end
  reg [15:0] TriggerCount;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      TriggerCount <= 16'b0;
      TriggerIn <= 1'b0;
    end
    else if(TriggerCount == 16'h9C40) begin
      TriggerIn <= 1'b1;
      TriggerCount <= 16'b0;
    end
    else begin
      TriggerCount <= TriggerCount + 1'b1;
      TriggerIn <= 1'b0;
    end
  end
  localparam LOW = 13;
  localparam HIGH = 12;
  always begin
    #(LOW) Clk = ~Clk;
    #(HIGH) Clk = ~Clk;
  end
  localparam SLOW_CLK_PEROID = 200;
  always #(SLOW_CLK_PEROID/2) SlowClock = ~SlowClock;
  assign Clk5M = SlowClock;
  localparam SYNC_CLK_PEROID = 10;
  always #(SYNC_CLK_PEROID/2) SyncClk = ~SyncClk;
endmodule

