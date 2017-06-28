`timescale 1ns / 1ns
module SlaveDaq_tb;
    reg Clk;
    reg reset_n;
    reg ModuleStart;
    reg AcqStart;
    reg EndReadout;
    reg CHIPSATB;
    reg [15:0] AcquisitionTime;
    reg [15:0] EndHoldTime;
    wire RESET_B;
    wire START_ACQ;
    wire StartReadout;
    wire PWR_ON_A;
    wire PWR_ON_D;
    wire PWR_ON_ADC;
    wire PWR_ON_DAC;
    wire OnceEnd;
    // Instantiation uut
    SlaveDaq uut(
      .Clk(Clk),
      .reset_n(reset_n),
      .ModuleStart(ModuleStart),
      .AcqStart(AcqStart),
      .EndReadout(EndReadout),
      .CHIPSATB(CHIPSATB),
      .AcquisitionTime(AcquisitionTime),
      .EndHoldTime(EndHoldTime),
      .RESET_B(RESET_B),
      .START_ACQ(START_ACQ),
      .StartReadout(StartReadout),
      .PWR_ON_A(PWR_ON_A),
      .PWR_ON_D(PWR_ON_D),
      .PWR_ON_ADC(PWR_ON_ADC),
      .PWR_ON_DAC(PWR_ON_DAC),
      .OnceEnd(OnceEnd)
    );
    // initial the module
    initial begin
      Clk = 1'b0;
      reset_n = 1'b0;
      ModuleStart = 1'b0;
      AcqStart = 1'b0;
      //EndReadout = 1'b0;
      //CHIPSATB = 1'b1;
      AcquisitionTime = 16'd63;
      EndHoldTime = 16'd20;
      #(100);
      reset_n = 1'b1;      
      #34;
      AcqStart = 1'b1;
      #50;
      AcqStart = 1'b0;
      #100;
      ModuleStart = 1'b1;
      #1633;
      AcqStart = 1'b1;
      #45;
      AcqStart = 1'b0;
      #10000;
      ModuleStart <= 1'b0;
    end
    reg [5:0] StartCount;
    reg [1:0] StartState;
    localparam [1:0] IDLE = 2'b00,
                     START = 2'b01,
                     CHIP_FULL = 2'b10;
                     //DONE = 2'b11;
    always @(posedge Clk or negedge reset_n) begin
      if(~reset_n) begin
        CHIPSATB <= 1'b1;
        StartCount <= 6'b0;
        StartState <= IDLE;
      end
      else begin
        case(StartState)
          IDLE:begin
            if(START_ACQ) begin
              StartState <= START;
            end
            else
              StartState <= IDLE;
          end
          START:begin
            if(StartCount < 6'd60 && START_ACQ) begin
              StartCount <= StartCount + 1'b1;
              StartState <= START;
            end
            else begin
              StartState <= CHIP_FULL;
              StartCount <= 6'b0;
              CHIPSATB <= 1'b0;
            end
          end
          CHIP_FULL:begin
            if(StartCount < 6'd10) begin
              StartCount <= StartCount + 1'b1;
              StartState <= CHIP_FULL;
            end
            else begin
              CHIPSATB <= 1'b1;
              StartCount <= 6'b0;
              StartState <= IDLE;
            end
          end
          default:StartState <= IDLE;
        endcase
      end
    end
    reg [5:0] ReadCount;
    always @(posedge Clk or negedge reset_n) begin
      if(~reset_n) begin
        EndReadout <= 1'b0;
        ReadCount <= 6'b0;
      end
      else if(ReadCount == 6'd60) begin
        ReadCount <= 6'b0;
        EndReadout <= 1'b1;
      end
      else if(StartReadout || (ReadCount != 0 && ReadCount < 6'd60)) begin
        ReadCount <= ReadCount + 1'b1;
        EndReadout <= 1'b0;
      end
      else begin
        ReadCount <= 6'b0;
        EndReadout <= 1'b0;
      end
    end
    //*** Generate the Clock
    localparam HighTime = 12;
    localparam LowTime = 13;
    always begin
      #(HighTime) Clk = ~Clk;
      #(LowTime) Clk = ~Clk;
    end
endmodule
