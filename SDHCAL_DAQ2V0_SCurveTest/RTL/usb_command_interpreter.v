`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Science and Technology of China
// Engineer: Junbin Zhang
// 
// Create Date:    00:08:40 07/09/2015 
// Design Name:    SDHCAL_DAQ2V0
// Module Name:    usb_command_interpreter 
// Project Name: 
// Target Devices: XC7A100TFGG484
// Tool versions:  Vivado 2016.3
// Description:    command interpreter
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module usb_command_interpreter(
      input IFCLK,
      input clk,
      input reset_n,
      //--- USB interface ---//
      input in_from_usb_Ctr_rd_en,
      input [15:0] in_from_usb_ControlWord,
      output reg Microroc_Acq_Start_Stop,
      //--- clear usb fifo ---//
      output reg out_to_rst_usb_data_fifo, //asynchronized reset
      //--- Microroc parameter ---//
      output reg Microroc_sc_or_read,
      output reg Microroc_param_load,
      output reg [2:0] Microroc_param_asic_num,
      output reg [9:0] Microroc_param_DAC0_Vth,
      output reg [9:0] Microroc_param_DAC1_Vth,
      output reg [9:0] Microroc_param_DAC2_Vth,
      output reg [63:0] Microroc_param_Ctest,
      output reg [63:0] Microroc_param_Read_reg,
      output reg Microroc_powerpulsing_en,
      output reg Microroc_sel_readout_chn,
      output reg [1:0] MicrorocTrigCoincid,
      output reg MicrorocHold_en,
      output reg [7:0] MicrorocHoldDelay,
      output reg [15:0] MicrorocHoldTime,
      output reg Microroc_rst_cntb,
      //output reg Microroc_raz_en,
      output reg Microroc_trig_en,
      //output reg [1:0] Microroc_raz_mode,
      output reg [7:0] Microroc_param_header,
      output reg [15:0] Microroc_AcqStart_time,
      output reg [1:0] Microroc_sw_hg,//sw_hg<1:0> default 10
      output reg [1:0] Microroc_sw_lg,//sw_lg<1:0> default 10
      output [255:0] Microroc_4Bit_DAC,
      output reg Microroc_HG_or_LG_shaper_output,
      output reg Microroc_OTAQ_en,
      //
      output reg [1:0] ADG804_Addr,
      output reg ADG819_Addr,
      output [1:0]TP,
      //new add by wyu 20170308, external & internal raz_chn enable
      output reg Microroc_Internal_or_External_raz_chn,
      output reg [1:0] Microroc_Internal_RAZ_Mode,
      output reg [1:0] Microroc_External_RAZ_Mode,
      output reg [3:0] MicrorocExternalRazDelayTime,
      //new add by wyu 20170308, SC parameter 336  Select latched (RS : 1) or direct output (trigger : 0)
      output reg Microroc_RS_or_Discri,
      //new add by wyu 20170308, SC parameter 575  Select Channel Trigger selected by Read Register (0) or NOR64 output (1)
      output reg Microroc_NOR64_or_Disc,
      //*** Channel and Discri Mask
      // Add by wyu 20170504
      output reg [191:0] MicrorocChannelMask,

      //--- Sweep Test Port ---//
      // Mode Select
      output reg [1:0] ModeSelect,
      output reg [1:0] DacSelect,
      // Test Dac
      output reg [9:0] StartDac,
      output reg [9:0] EndDac,
      //*** S Curve Test Port
      output reg Single_or_64Chn,
      output reg CTest_or_Input,
      output reg [5:0] SingleTest_Chn,
      output reg [15:0] CPT_MAX,
      output reg SweepTestStartStop,
      // Count Efficirncy
      output reg TrigEffi_or_CountEffi,
      output reg [15:0] CounterMax,
      input SweepTestDone,
      input USB_FIFO_Empty,
      //*** Sweep Acq
      output reg [15:0] MaxPackageNumber,
      //*** Reset Microroc AutoAcq and ReadRam module
      output reg ForceMicrorocAcqReset,
      //*** ADC Control
      output reg AdcStartAcq,
      output reg [3:0] AdcStartDelayTime,
      output reg [7:0] AdcDataNumber,
      //--- LED ---//
      output reg [3:0] LED
    );
wire [15:0] USB_COMMAND;
reg fifo_rden;
wire fifo_empty;
assign TP[1] = fifo_rden;
assign TP[0] = fifo_empty;
//wire fifo_full;
usb_cmd_fifo usbcmdfifo_16depth (
  .rst(!reset_n),
  .wr_clk(~IFCLK),
  .wr_en(in_from_usb_Ctr_rd_en),
  .din(in_from_usb_ControlWord),
  .full(),

  .rd_clk(~clk),
  .rd_en(fifo_rden),
  .dout(USB_COMMAND),
  .empty(fifo_empty)
);
//read process
localparam Idle = 1'b0;
localparam READ = 1'b1;
reg State;
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n) begin
    fifo_rden <= 1'b0;
    State <= Idle;
  end
  else begin
    case(State)
      Idle:begin
        if(fifo_empty)
          State <= Idle;
        else begin
          fifo_rden <= 1'b1;
          State <= READ;
        end
      end
      READ:begin
        fifo_rden <= 1'b0;
        State <= Idle;
      end
      default:State <= Idle;
    endcase
  end
end
//command process
//acq start or stop f0f0,f0f1
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    Microroc_Acq_Start_Stop <= 1'b0;
  else if(fifo_rden && USB_COMMAND == 16'hf0f0)
    Microroc_Acq_Start_Stop <= 1'b1;
  else if(fifo_rden && USB_COMMAND == 16'hf0f1)
    Microroc_Acq_Start_Stop <= 1'b0;
  else
    Microroc_Acq_Start_Stop <= Microroc_Acq_Start_Stop;
end
//clear usb data fifo a0f0
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    out_to_rst_usb_data_fifo <= 1'b0;
  else if(fifo_rden && USB_COMMAND == 16'hf0fa)
    out_to_rst_usb_data_fifo <= 1'b1;
  else
    out_to_rst_usb_data_fifo <= 1'b0;
end
// Reset Microroc AutoAcq and ReadRam Module
always @(posedge clk or negedge reset_n ) begin
  if(~reset_n)
    ForceMicrorocAcqReset <= 1'b0;
  else if(fifo_rden && USB_COMMAND == 16'hF0F2)
    ForceMicrorocAcqReset <= 1'b1;
  else
    ForceMicrorocAcqReset <= 1'b0;
end
//MICROROC command A type
always @(posedge clk or negedge reset_n) begin
  if (~reset_n)
    Microroc_sc_or_read <= 1'b0; //0--sc; 1--read register level
  else if (fifo_rden && USB_COMMAND == 16'hA0A0)
    Microroc_sc_or_read <= 1'b0;
  else if (fifo_rden && USB_COMMAND == 16'hA0A1)
    Microroc_sc_or_read <= 1'b1;
  else
    Microroc_sc_or_read <= Microroc_sc_or_read;
end

always @(posedge clk or negedge reset_n) begin
  if (~reset_n) 
    Microroc_param_asic_num <= 3'b001;
  else if (fifo_rden && USB_COMMAND[15:4] == 12'hA0B)
    Microroc_param_asic_num <= USB_COMMAND[2:0];
  else
    Microroc_param_asic_num <= Microroc_param_asic_num;
end
//Microroc_HG_or_LG_shaper_output
//Select the output of pin 128 out_fsb.If 0, high gain shaper;else low gain
//shaper
always @ (posedge clk or negedge reset_n) begin
  if(~reset_n)
    Microroc_HG_or_LG_shaper_output <= 1'b0;
  else if(fifo_rden && USB_COMMAND == 16'hA0C0)
    Microroc_HG_or_LG_shaper_output <= 1'b0;
  else if(fifo_rden && USB_COMMAND == 16'hA0C1)
    Microroc_HG_or_LG_shaper_output <= 1'b1;
  else
    Microroc_HG_or_LG_shaper_output <= Microroc_HG_or_LG_shaper_output;
end
//Microroc_OTAQ_en
//Enable selected Shaper output OTA;default 0
always @ (posedge clk or negedge reset_n)begin
  if(~reset_n)
    Microroc_OTAQ_en <= 1'b0;
  else if(fifo_rden && USB_COMMAND == 16'hA0D0)
    Microroc_OTAQ_en <= 1'b0;
  else if(fifo_rden && USB_COMMAND == 16'hA0D1)
    Microroc_OTAQ_en <= 1'b1;
  else
    Microroc_OTAQ_en <= Microroc_OTAQ_en;
end
//Ctest
always @(posedge clk or negedge reset_n) begin
  if (~reset_n) 
    Microroc_param_Ctest <= 64'b0;
  else if (fifo_rden && USB_COMMAND[15:8]==8'hA1) begin
    case(USB_COMMAND[7:0])
      8'd0: Microroc_param_Ctest <= 64'h0000_0000_0000_0000;
      8'd1: Microroc_param_Ctest <= 64'h0000_0000_0000_0001;
      8'd2: Microroc_param_Ctest <= 64'h0000_0000_0000_0002;
      8'd3: Microroc_param_Ctest <= 64'h0000_0000_0000_0004;
      8'd4: Microroc_param_Ctest <= 64'h0000_0000_0000_0008;
      8'd5: Microroc_param_Ctest <= 64'h0000_0000_0000_0010;
      8'd6: Microroc_param_Ctest <= 64'h0000_0000_0000_0020;
      8'd7: Microroc_param_Ctest <= 64'h0000_0000_0000_0040;
      8'd8: Microroc_param_Ctest <= 64'h0000_0000_0000_0080;
      8'd9: Microroc_param_Ctest <= 64'h0000_0000_0000_0100;
      8'd10:Microroc_param_Ctest <= 64'h0000_0000_0000_0200;
      8'd11:Microroc_param_Ctest <= 64'h0000_0000_0000_0400;
      8'd12:Microroc_param_Ctest <= 64'h0000_0000_0000_0800;
      8'd13:Microroc_param_Ctest <= 64'h0000_0000_0000_1000;
      8'd14:Microroc_param_Ctest <= 64'h0000_0000_0000_2000;
      8'd15:Microroc_param_Ctest <= 64'h0000_0000_0000_4000;
      8'd16:Microroc_param_Ctest <= 64'h0000_0000_0000_8000;
      8'd17:Microroc_param_Ctest <= 64'h0000_0000_0001_0000;
      8'd18:Microroc_param_Ctest <= 64'h0000_0000_0002_0000;
      8'd19:Microroc_param_Ctest <= 64'h0000_0000_0004_0000;
      8'd20:Microroc_param_Ctest <= 64'h0000_0000_0008_0000;
      8'd21:Microroc_param_Ctest <= 64'h0000_0000_0010_0000;
      8'd22:Microroc_param_Ctest <= 64'h0000_0000_0020_0000;
      8'd23:Microroc_param_Ctest <= 64'h0000_0000_0040_0000;
      8'd24:Microroc_param_Ctest <= 64'h0000_0000_0080_0000;
      8'd25:Microroc_param_Ctest <= 64'h0000_0000_0100_0000;
      8'd26:Microroc_param_Ctest <= 64'h0000_0000_0200_0000;
      8'd27:Microroc_param_Ctest <= 64'h0000_0000_0400_0000;
      8'd28:Microroc_param_Ctest <= 64'h0000_0000_0800_0000;
      8'd29:Microroc_param_Ctest <= 64'h0000_0000_1000_0000;
      8'd30:Microroc_param_Ctest <= 64'h0000_0000_2000_0000;
      8'd31:Microroc_param_Ctest <= 64'h0000_0000_4000_0000;
      8'd32:Microroc_param_Ctest <= 64'h0000_0000_8000_0000;
      8'd33:Microroc_param_Ctest <= 64'h0000_0001_0000_0000;
      8'd34:Microroc_param_Ctest <= 64'h0000_0002_0000_0000;
      8'd35:Microroc_param_Ctest <= 64'h0000_0004_0000_0000;
      8'd36:Microroc_param_Ctest <= 64'h0000_0008_0000_0000;
      8'd37:Microroc_param_Ctest <= 64'h0000_0010_0000_0000;
      8'd38:Microroc_param_Ctest <= 64'h0000_0020_0000_0000;
      8'd39:Microroc_param_Ctest <= 64'h0000_0040_0000_0000;
      8'd40:Microroc_param_Ctest <= 64'h0000_0080_0000_0000;
      8'd41:Microroc_param_Ctest <= 64'h0000_0100_0000_0000;
      8'd42:Microroc_param_Ctest <= 64'h0000_0200_0000_0000;
      8'd43:Microroc_param_Ctest <= 64'h0000_0400_0000_0000;
      8'd44:Microroc_param_Ctest <= 64'h0000_0800_0000_0000;
      8'd45:Microroc_param_Ctest <= 64'h0000_1000_0000_0000;
      8'd46:Microroc_param_Ctest <= 64'h0000_2000_0000_0000;
      8'd47:Microroc_param_Ctest <= 64'h0000_4000_0000_0000;
      8'd48:Microroc_param_Ctest <= 64'h0000_8000_0000_0000;
      8'd49:Microroc_param_Ctest <= 64'h0001_0000_0000_0000;
      8'd50:Microroc_param_Ctest <= 64'h0002_0000_0000_0000;
      8'd51:Microroc_param_Ctest <= 64'h0004_0000_0000_0000;
      8'd52:Microroc_param_Ctest <= 64'h0008_0000_0000_0000;
      8'd53:Microroc_param_Ctest <= 64'h0010_0000_0000_0000;
      8'd54:Microroc_param_Ctest <= 64'h0020_0000_0000_0000;
      8'd55:Microroc_param_Ctest <= 64'h0040_0000_0000_0000;
      8'd56:Microroc_param_Ctest <= 64'h0080_0000_0000_0000;
      8'd57:Microroc_param_Ctest <= 64'h0100_0000_0000_0000;
      8'd58:Microroc_param_Ctest <= 64'h0200_0000_0000_0000;
      8'd59:Microroc_param_Ctest <= 64'h0400_0000_0000_0000;
      8'd60:Microroc_param_Ctest <= 64'h0800_0000_0000_0000;
      8'd61:Microroc_param_Ctest <= 64'h1000_0000_0000_0000;
      8'd62:Microroc_param_Ctest <= 64'h2000_0000_0000_0000;
      8'd63:Microroc_param_Ctest <= 64'h4000_0000_0000_0000;
      8'd64:Microroc_param_Ctest <= 64'h8000_0000_0000_0000;
      8'd255:Microroc_param_Ctest <= 64'hFFFF_FFFF_FFFF_FFFF;
      default:Microroc_param_Ctest <= 64'h0000_0000_0000_0000;
    endcase
  end
  else 
    Microroc_param_Ctest <= Microroc_param_Ctest;
end
//Microroc_param_Read_reg
always @(posedge clk or negedge reset_n) begin
  if (~reset_n)
    Microroc_param_Read_reg <= 64'b0;
  else if (fifo_rden && USB_COMMAND[15:8] == 8'hA2) begin
    case(USB_COMMAND[7:0])
      8'd0: Microroc_param_Read_reg <= 64'h0000_0000_0000_0000;
      8'd1: Microroc_param_Read_reg <= 64'h0000_0000_0000_0001;
      8'd2: Microroc_param_Read_reg <= 64'h0000_0000_0000_0002;
      8'd3: Microroc_param_Read_reg <= 64'h0000_0000_0000_0004;
      8'd4: Microroc_param_Read_reg <= 64'h0000_0000_0000_0008;
      8'd5: Microroc_param_Read_reg <= 64'h0000_0000_0000_0010;
      8'd6: Microroc_param_Read_reg <= 64'h0000_0000_0000_0020;
      8'd7: Microroc_param_Read_reg <= 64'h0000_0000_0000_0040;
      8'd8: Microroc_param_Read_reg <= 64'h0000_0000_0000_0080;
      8'd9: Microroc_param_Read_reg <= 64'h0000_0000_0000_0100;
      8'd10:Microroc_param_Read_reg <= 64'h0000_0000_0000_0200;
      8'd11:Microroc_param_Read_reg <= 64'h0000_0000_0000_0400;
      8'd12:Microroc_param_Read_reg <= 64'h0000_0000_0000_0800;
      8'd13:Microroc_param_Read_reg <= 64'h0000_0000_0000_1000;
      8'd14:Microroc_param_Read_reg <= 64'h0000_0000_0000_2000;
      8'd15:Microroc_param_Read_reg <= 64'h0000_0000_0000_4000;
      8'd16:Microroc_param_Read_reg <= 64'h0000_0000_0000_8000;
      8'd17:Microroc_param_Read_reg <= 64'h0000_0000_0001_0000;
      8'd18:Microroc_param_Read_reg <= 64'h0000_0000_0002_0000;
      8'd19:Microroc_param_Read_reg <= 64'h0000_0000_0004_0000;
      8'd20:Microroc_param_Read_reg <= 64'h0000_0000_0008_0000;
      8'd21:Microroc_param_Read_reg <= 64'h0000_0000_0010_0000;
      8'd22:Microroc_param_Read_reg <= 64'h0000_0000_0020_0000;
      8'd23:Microroc_param_Read_reg <= 64'h0000_0000_0040_0000;
      8'd24:Microroc_param_Read_reg <= 64'h0000_0000_0080_0000;
      8'd25:Microroc_param_Read_reg <= 64'h0000_0000_0100_0000;
      8'd26:Microroc_param_Read_reg <= 64'h0000_0000_0200_0000;
      8'd27:Microroc_param_Read_reg <= 64'h0000_0000_0400_0000;
      8'd28:Microroc_param_Read_reg <= 64'h0000_0000_0800_0000;
      8'd29:Microroc_param_Read_reg <= 64'h0000_0000_1000_0000;
      8'd30:Microroc_param_Read_reg <= 64'h0000_0000_2000_0000;
      8'd31:Microroc_param_Read_reg <= 64'h0000_0000_4000_0000;
      8'd32:Microroc_param_Read_reg <= 64'h0000_0000_8000_0000;
      8'd33:Microroc_param_Read_reg <= 64'h0000_0001_0000_0000;
      8'd34:Microroc_param_Read_reg <= 64'h0000_0002_0000_0000;
      8'd35:Microroc_param_Read_reg <= 64'h0000_0004_0000_0000;
      8'd36:Microroc_param_Read_reg <= 64'h0000_0008_0000_0000;
      8'd37:Microroc_param_Read_reg <= 64'h0000_0010_0000_0000;
      8'd38:Microroc_param_Read_reg <= 64'h0000_0020_0000_0000;
      8'd39:Microroc_param_Read_reg <= 64'h0000_0040_0000_0000;
      8'd40:Microroc_param_Read_reg <= 64'h0000_0080_0000_0000;
      8'd41:Microroc_param_Read_reg <= 64'h0000_0100_0000_0000;
      8'd42:Microroc_param_Read_reg <= 64'h0000_0200_0000_0000;
      8'd43:Microroc_param_Read_reg <= 64'h0000_0400_0000_0000;
      8'd44:Microroc_param_Read_reg <= 64'h0000_0800_0000_0000;
      8'd45:Microroc_param_Read_reg <= 64'h0000_1000_0000_0000;
      8'd46:Microroc_param_Read_reg <= 64'h0000_2000_0000_0000;
      8'd47:Microroc_param_Read_reg <= 64'h0000_4000_0000_0000;
      8'd48:Microroc_param_Read_reg <= 64'h0000_8000_0000_0000;
      8'd49:Microroc_param_Read_reg <= 64'h0001_0000_0000_0000;
      8'd50:Microroc_param_Read_reg <= 64'h0002_0000_0000_0000;
      8'd51:Microroc_param_Read_reg <= 64'h0004_0000_0000_0000;
      8'd52:Microroc_param_Read_reg <= 64'h0008_0000_0000_0000;
      8'd53:Microroc_param_Read_reg <= 64'h0010_0000_0000_0000;
      8'd54:Microroc_param_Read_reg <= 64'h0020_0000_0000_0000;
      8'd55:Microroc_param_Read_reg <= 64'h0040_0000_0000_0000;
      8'd56:Microroc_param_Read_reg <= 64'h0080_0000_0000_0000;
      8'd57:Microroc_param_Read_reg <= 64'h0100_0000_0000_0000;
      8'd58:Microroc_param_Read_reg <= 64'h0200_0000_0000_0000;
      8'd59:Microroc_param_Read_reg <= 64'h0400_0000_0000_0000;
      8'd60:Microroc_param_Read_reg <= 64'h0800_0000_0000_0000;
      8'd61:Microroc_param_Read_reg <= 64'h1000_0000_0000_0000;
      8'd62:Microroc_param_Read_reg <= 64'h2000_0000_0000_0000;
      8'd63:Microroc_param_Read_reg <= 64'h4000_0000_0000_0000;
      8'd64:Microroc_param_Read_reg <= 64'h8000_0000_0000_0000;
      default:Microroc_param_Read_reg <= 64'h0000_0000_0000_0000;
    endcase
  end
  else 
    Microroc_param_Read_reg <= Microroc_param_Read_reg;
end
//Microroc_powerpulsing_en
always @(posedge clk or negedge reset_n) begin
  if (~reset_n)
    Microroc_powerpulsing_en <= 1'b0;
  else if (fifo_rden && USB_COMMAND == 16'hA3A0)
    Microroc_powerpulsing_en <= 1'b0;
  else if (fifo_rden && USB_COMMAND == 16'hA3A1)
    Microroc_powerpulsing_en <= 1'b1;
  else 
    Microroc_powerpulsing_en <= Microroc_powerpulsing_en;
end
//Microroc_sel_readout_chn
always @(posedge clk or negedge reset_n) begin
  if (~reset_n) 
    Microroc_sel_readout_chn <= 1'b0;
  else if (fifo_rden && USB_COMMAND == 16'hA4A0)
    Microroc_sel_readout_chn <= 1'b0;
  else if (fifo_rden && USB_COMMAND == 16'hA4A1)
    Microroc_sel_readout_chn <= 1'b1;
  else 
    Microroc_sel_readout_chn <= Microroc_sel_readout_chn;
end
//Microroc_Trig_Coincid
always @(posedge clk or negedge reset_n) begin
  if (~reset_n)
    MicrorocTrigCoincid <= 2'b00;
  else if (fifo_rden && USB_COMMAND[15:4] == 12'hA5A)
    MicrorocTrigCoincid <= USB_COMMAND[1:0];
  else 
    MicrorocTrigCoincid <= MicrorocTrigCoincid;
end
// *** Microroc hold enbale
always @(posedge clk or negedge reset_n) begin
  if(~reset_n)
    MicrorocHold_en <= 1'b0;
  else if(fifo_rden && USB_COMMAND == 16'hA5B0)
    MicrorocHold_en <= 1'b0;
  else if(fifo_rden && USB_COMMAND == 16'hA5B1)
    MicrorocHold_en <= 1'b1;
  else
    MicrorocHold_en <= MicrorocHold_en;
end
//Microroc_Hold_Delay
always @(posedge clk or negedge reset_n) begin
  if (~reset_n) 
    MicrorocHoldDelay <= 8'b0;
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hA60) 
    MicrorocHoldDelay[3:0] <= USB_COMMAND[3:0];
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hA61)
    MicrorocHoldDelay[7:4] <= USB_COMMAND[3:0];
  else 
    MicrorocHoldDelay <= MicrorocHoldDelay;
end
// Hold Time
always @(posedge clk or negedge reset_n) begin
  if(~reset_n)
    MicrorocHoldTime <= 16'b0;
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hA64)
    MicrorocHoldTime[3:0] <= USB_COMMAND[3:0];
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hA65)
    MicrorocHoldTime[7:4] <= USB_COMMAND[3:0];
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hA66)
    MicrorocHoldTime[11:8] <= USB_COMMAND[3:0];
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hA67)
    MicrorocHoldTime[15:12] <= USB_COMMAND[3:0];
  else
    MicrorocHoldTime <= MicrorocHoldTime;
end
//Microroc_rst_cntb
always @(posedge clk or negedge reset_n) begin
  if (~reset_n) 
    Microroc_rst_cntb <= 1'b0;
  else if (fifo_rden && USB_COMMAND == 16'hA7A1)
    Microroc_rst_cntb <= 1'b1;
  else 
    Microroc_rst_cntb <= 1'b0;
end
/*//Microroc_raz_en
always @(posedge clk or negedge reset_n) begin
  if (~reset_n) 
    Microroc_raz_en <= 1'b0;
  else if (fifo_rden && USB_COMMAND == 16'hA8A0) 
    Microroc_raz_en <= 1'b0;
  else if (fifo_rden && USB_COMMAND == 16'hA8A1)
    Microroc_raz_en <= 1'b1;
  else 
    Microroc_raz_en <= Microroc_raz_en;
end*/
// Add new command to set external & internal raz_chn enable in SC parameter,
// 20170308
always @(posedge clk or negedge reset_n) begin
  if(~reset_n)
    Microroc_Internal_or_External_raz_chn <= 1'b1;//default Internal RAZ Channel
  else if(fifo_rden && USB_COMMAND == 16'hA8A0)
    Microroc_Internal_or_External_raz_chn <= 1'b1;
  else if(fifo_rden && USB_COMMAND == 16'hA8A1)
    Microroc_Internal_or_External_raz_chn <= 1'b0;
  else
    Microroc_Internal_or_External_raz_chn <= Microroc_Internal_or_External_raz_chn;
end
//Internal raz mode select, this should be set in the SC parameter/Added by
//wyu 20170309
always @(posedge clk or negedge reset_n) begin
  if(~reset_n)
    Microroc_Internal_RAZ_Mode <= 2'b11;//default value from datasheet
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hA8B)
    Microroc_Internal_RAZ_Mode <= USB_COMMAND[1:0];
  else
    Microroc_Internal_RAZ_Mode <= Microroc_Internal_RAZ_Mode;
end
//External raz mode select, this parameter is sent to the Trig_Gen module to
//generate RAZ_CHNN&P/Added by wyu 20170309
always @(posedge clk or negedge reset_n) begin
  if(~reset_n)
    Microroc_External_RAZ_Mode <= 2'b11;//We set the external raz_chn length at 1us, just as internal
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hA8C)
    Microroc_External_RAZ_Mode <= USB_COMMAND[1:0];
  else
    Microroc_External_RAZ_Mode <= Microroc_External_RAZ_Mode;
end
//External RAZ_CHNN&P delay time. when there is an trigger out, we should set
//raz_chn to reset the trigger, the delay time is to decide which time the raz_chn is enable
always @(posedge clk or negedge reset_n) begin
  if(~reset_n)
    MicrorocExternalRazDelayTime <= 4'd4;
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hA8D)
    MicrorocExternalRazDelayTime[3:0] <= USB_COMMAND[3:0];
  else
    MicrorocExternalRazDelayTime <= MicrorocExternalRazDelayTime;
end
//Microroc_trig_en
always @ (posedge clk or negedge reset_n) begin
  if(~reset_n)
    Microroc_trig_en <= 1'b0;
  else if(fifo_rden && USB_COMMAND == 16'hA9A0)
    Microroc_trig_en <= 1'b0;
  else if(fifo_rden && USB_COMMAND == 16'hA9A1)
    Microroc_trig_en <= 1'b1;
  else 
    Microroc_trig_en <= Microroc_trig_en;
end
/*//Microroc_raz_mode
always @ (posedge clk or negedge reset_n) begin
  if(~reset_n)
    Microroc_raz_mode <= 2'b00;
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hAAA)
    Microroc_raz_mode <= USB_COMMAND[1:0];
  else 
    Microroc_raz_mode <= Microroc_raz_mode;
end*/
//Microroc_param_header,the header is 8 bits
always @ (posedge clk or negedge reset_n) begin
  if(~reset_n)
    Microroc_param_header <= 8'h55;
  else if(fifo_rden && USB_COMMAND[15:8] == 8'hAB)
    //Microroc_param_header <= USB_COMMAND[7:0];
    Microroc_param_header <={USB_COMMAND[0], USB_COMMAND[1], USB_COMMAND[2], USB_COMMAND[3], USB_COMMAND[4], USB_COMMAND[5], USB_COMMAND[6], USB_COMMAND[7]};
  else
    Microroc_param_header <= Microroc_param_header;
end
//Microroc SC parameter 336 => Select latched (RS : 1) or direct output (trigger : 0)
always @(posedge clk or negedge reset_n) begin
  if(~reset_n)
    Microroc_RS_or_Discri <= 1'b1;
  else if(fifo_rden && USB_COMMAND == 16'hACA0)
    Microroc_RS_or_Discri <= 1'b1;
  else if(fifo_rden && USB_COMMAND == 16'hACA1)
    Microroc_RS_or_Discri <= 1'b0;
  else 
    Microroc_RS_or_Discri <= Microroc_RS_or_Discri;
end
//Microroc SC parameter 575 =>  Select Channel Trigger selected by Read Register (0) or NOR64 output (1)
always @(posedge clk or negedge reset_n) begin
  if(~reset_n)
    Microroc_NOR64_or_Disc <= 1'b1;
  else if(fifo_rden && USB_COMMAND == 16'hACB0)
    Microroc_NOR64_or_Disc <= 1'b0;
  else if(fifo_rden && USB_COMMAND == 16'hACB1)
    Microroc_NOR64_or_Disc <= 1'b1;
  else
    Microroc_NOR64_or_Disc <= Microroc_NOR64_or_Disc;
end
// ADXX && AE0X
// Channel and Discriminator mask
//*** DiscriMask
reg [2:0] DiscriMask;
always @ (posedge clk or negedge reset_n) begin
  if(~reset_n)
    DiscriMask <= 3'b1;
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hAE0) begin
    case(USB_COMMAND[3:0])
      4'd0:DiscriMask <= 3'b111;
      4'd1:DiscriMask <= 3'b110;
      4'd2:DiscriMask <= 3'b101;
      4'd3:DiscriMask <= 3'b100;
      4'd4:DiscriMask <= 3'b011;
      4'd5:DiscriMask <= 3'b010;
      4'd6:DiscriMask <= 3'b001;
      4'd7:DiscriMask <= 3'b000;
      default:DiscriMask <= 3'b111;
    endcase
  end
  else
    DiscriMask <= DiscriMask;
end
//*** Channel Mask
reg [7:0] MaskShift;
always @(posedge clk or negedge reset_n)begin
  if(~reset_n)
    MaskShift <= 8'b0;
  else if(fifo_rden && USB_COMMAND[15:8] == 8'hAD) begin
    MaskShift <= USB_COMMAND[5:0] + USB_COMMAND[5:0] + USB_COMMAND[5:0];
  end
  else
    MaskShift <= MaskShift;
end
//*** Load mask or Unmask
reg [191:0] SingleChannelMask;
reg [1:0] MaskState;
localparam [1:0] IDLE = 2'b00,
                 MASK = 2'b01,
                 UNMASK = 2'b10;
always @(posedge clk or negedge reset_n) begin
  if(~reset_n) begin
    MaskState <= 2'b0;
    SingleChannelMask <= {192{1'b1}};
    MicrorocChannelMask <= {192{1'b1}};
  end
  else begin
    case(MaskState)
      IDLE:begin
        if(fifo_rden && USB_COMMAND == 16'hAE10)begin
          MicrorocChannelMask <= {192{1'b1}};
          MaskState <= IDLE;
        end
        else if(fifo_rden && USB_COMMAND == 16'hAE11) begin
          SingleChannelMask <= {{189{1'b1}},DiscriMask} << MaskShift | {DiscriMask,{189{1'b1}}} >> (192- MaskShift - 3);
          MaskState <= MASK;
        end
        else if(fifo_rden && USB_COMMAND == 16'hAE12) begin
          SingleChannelMask <= {189'b0, 3'b111} << MaskShift;
          MaskState <= UNMASK;
        end
        else begin
          MicrorocChannelMask <= MicrorocChannelMask;
          MaskState <= IDLE;
        end
      end
      MASK:begin
        MicrorocChannelMask <= MicrorocChannelMask & SingleChannelMask;
        MaskState <= IDLE;
      end
      UNMASK:begin
        MicrorocChannelMask <= MicrorocChannelMask | SingleChannelMask;
        MaskState <= IDLE;
      end
      default:begin
        MicrorocChannelMask <= MicrorocChannelMask;
        MaskState <= IDLE;
      end
    endcase
  end
end
// B type command
//led interface
always @ (posedge clk , negedge reset_n) begin
  if(~reset_n)
    LED <= 4'b1111;
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hB00)
    LED <= USB_COMMAND[3:0];
  else
    LED <= LED;
end
//Microroc Acq_Start effective time, make the default time 200ns that is
//8 period
//The lower 8 bits start with B1
always @ (posedge clk, negedge reset_n) begin
  if(~reset_n)
    Microroc_AcqStart_time[7:0] <= 8'd8;
  else if(fifo_rden && USB_COMMAND[15:8] == 8'hB1)
    Microroc_AcqStart_time[7:0] <= USB_COMMAND[7:0];
  else
    Microroc_AcqStart_time[7:0] <= Microroc_AcqStart_time[7:0];
end
//The higher 8bit start with B2
always @ (posedge clk, negedge reset_n) begin
  if(~reset_n)
    Microroc_AcqStart_time[15:8] <= 8'd0;
  else if(fifo_rden && USB_COMMAND[15:8] == 8'hB2)
    Microroc_AcqStart_time[15:8] <= USB_COMMAND[7:0];
  else
    Microroc_AcqStart_time[15:8] <= Microroc_AcqStart_time[15:8];
end
//Microroc_sw_hg Microroc_sw_lg, High gain capacitor switch and low gain
//capacitor switch, The defaule value is 10, but in the SC parameter,sw_hg<0>
//out first
always @ (posedge clk, negedge reset_n) begin
  if(~reset_n)begin
    Microroc_sw_hg <= 2'b01;
    Microroc_sw_lg <= 2'b01;
  end
  else if(fifo_rden && USB_COMMAND[15:8] == 8'hB3) begin
    Microroc_sw_hg <= {USB_COMMAND[4], USB_COMMAND[5]};
    Microroc_sw_lg <= {USB_COMMAND[0], USB_COMMAND[1]};
  end
  else begin
    Microroc_sw_hg <= Microroc_sw_hg;
    Microroc_sw_lg <= Microroc_sw_lg;
  end
end
//In fact this is C type
//DAC0 voltage threshold C000~C3FF
always @(posedge clk or negedge reset_n) begin
  if (~reset_n)
    Microroc_param_DAC0_Vth <= 10'b1;
  else if (fifo_rden && USB_COMMAND[15:10]==6'h30)
    //Microroc_param_DAC0_Vth <= USB_COMMAND[9:0];
    Microroc_param_DAC0_Vth <= Invert_10bit(USB_COMMAND[9:0]);
  else 
    Microroc_param_DAC0_Vth <= Microroc_param_DAC0_Vth;
end
//DAC1 voltage threshold C400~C7FF
always @(posedge clk or negedge reset_n) begin
  if (~reset_n)
    Microroc_param_DAC1_Vth <= 10'b1;
  else if (fifo_rden && USB_COMMAND[15:10] == 6'h31)
    //Microroc_param_DAC1_Vth <= USB_COMMAND[9:0];
    Microroc_param_DAC1_Vth <= Invert_10bit(USB_COMMAND[9:0]);
  else 
    Microroc_param_DAC1_Vth <= Microroc_param_DAC1_Vth;
end
//DAC2 voltage threshold C800~CBFF
always @(posedge clk or negedge reset_n) begin
  if (~reset_n)
    Microroc_param_DAC2_Vth <= 10'b1;
  else if (fifo_rden && USB_COMMAND[15:10] == 6'h32)
    //Microroc_param_DAC2_Vth <= USB_COMMAND[9:0];
    Microroc_param_DAC2_Vth <= Invert_10bit(USB_COMMAND[9:0]);
  else 
    Microroc_param_DAC2_Vth <= Microroc_param_DAC2_Vth;
end
//4-bit DAC set. 4-bit DAC is used to adjust the Vref_hg, 
//Vref_hg = Vref+sh - 728*DAC_Code(uV), while Vref_sh = 2.2V
//The MSB of the 4-bit DAC burst out first
reg [3:0] Microroc_4Bit_DAC_chn[0:63];
always @ (posedge clk or negedge reset_n)begin
  if(~reset_n) begin
    Microroc_4Bit_DAC_chn[0] <= 4'b0;
    Microroc_4Bit_DAC_chn[1] <= 4'b0;
    Microroc_4Bit_DAC_chn[2] <= 4'b0;
    Microroc_4Bit_DAC_chn[3] <= 4'b0;
    Microroc_4Bit_DAC_chn[4] <= 4'b0;
    Microroc_4Bit_DAC_chn[5] <= 4'b0;
    Microroc_4Bit_DAC_chn[6] <= 4'b0;
    Microroc_4Bit_DAC_chn[7] <= 4'b0;
    Microroc_4Bit_DAC_chn[8] <= 4'b0;
    Microroc_4Bit_DAC_chn[9] <= 4'b0;
    Microroc_4Bit_DAC_chn[10] <= 4'b0;
    Microroc_4Bit_DAC_chn[11] <= 4'b0;
    Microroc_4Bit_DAC_chn[12] <= 4'b0;
    Microroc_4Bit_DAC_chn[13] <= 4'b0;
    Microroc_4Bit_DAC_chn[14] <= 4'b0;
    Microroc_4Bit_DAC_chn[15] <= 4'b0;
    Microroc_4Bit_DAC_chn[16] <= 4'b0;
    Microroc_4Bit_DAC_chn[17] <= 4'b0;
    Microroc_4Bit_DAC_chn[18] <= 4'b0;
    Microroc_4Bit_DAC_chn[19] <= 4'b0;
    Microroc_4Bit_DAC_chn[20] <= 4'b0;
    Microroc_4Bit_DAC_chn[21] <= 4'b0;
    Microroc_4Bit_DAC_chn[22] <= 4'b0;
    Microroc_4Bit_DAC_chn[23] <= 4'b0;
    Microroc_4Bit_DAC_chn[24] <= 4'b0;
    Microroc_4Bit_DAC_chn[25] <= 4'b0;
    Microroc_4Bit_DAC_chn[26] <= 4'b0;
    Microroc_4Bit_DAC_chn[27] <= 4'b0;
    Microroc_4Bit_DAC_chn[28] <= 4'b0;
    Microroc_4Bit_DAC_chn[29] <= 4'b0;
    Microroc_4Bit_DAC_chn[30] <= 4'b0;
    Microroc_4Bit_DAC_chn[31] <= 4'b0;
    Microroc_4Bit_DAC_chn[32] <= 4'b0;
    Microroc_4Bit_DAC_chn[33] <= 4'b0;
    Microroc_4Bit_DAC_chn[34] <= 4'b0;
    Microroc_4Bit_DAC_chn[35] <= 4'b0;
    Microroc_4Bit_DAC_chn[36] <= 4'b0;
    Microroc_4Bit_DAC_chn[37] <= 4'b0;
    Microroc_4Bit_DAC_chn[38] <= 4'b0;
    Microroc_4Bit_DAC_chn[39] <= 4'b0;
    Microroc_4Bit_DAC_chn[40] <= 4'b0;
    Microroc_4Bit_DAC_chn[41] <= 4'b0;
    Microroc_4Bit_DAC_chn[42] <= 4'b0;
    Microroc_4Bit_DAC_chn[43] <= 4'b0;
    Microroc_4Bit_DAC_chn[44] <= 4'b0;
    Microroc_4Bit_DAC_chn[45] <= 4'b0;
    Microroc_4Bit_DAC_chn[46] <= 4'b0;
    Microroc_4Bit_DAC_chn[47] <= 4'b0;
    Microroc_4Bit_DAC_chn[48] <= 4'b0;
    Microroc_4Bit_DAC_chn[49] <= 4'b0;
    Microroc_4Bit_DAC_chn[50] <= 4'b0;
    Microroc_4Bit_DAC_chn[51] <= 4'b0;
    Microroc_4Bit_DAC_chn[52] <= 4'b0;
    Microroc_4Bit_DAC_chn[53] <= 4'b0;
    Microroc_4Bit_DAC_chn[54] <= 4'b0;
    Microroc_4Bit_DAC_chn[55] <= 4'b0;
    Microroc_4Bit_DAC_chn[56] <= 4'b0;
    Microroc_4Bit_DAC_chn[57] <= 4'b0;
    Microroc_4Bit_DAC_chn[58] <= 4'b0;
    Microroc_4Bit_DAC_chn[59] <= 4'b0;
    Microroc_4Bit_DAC_chn[60] <= 4'b0;
    Microroc_4Bit_DAC_chn[61] <= 4'b0;
    Microroc_4Bit_DAC_chn[62] <= 4'b0;
    Microroc_4Bit_DAC_chn[63] <= 4'b0;
  end
  else if(fifo_rden && (USB_COMMAND[15:8] == 8'hCC || USB_COMMAND[15:8] == 8'hCD || USB_COMMAND[15:8] == 8'hCE || USB_COMMAND[15:8] == 8'hCF)) begin
    Microroc_4Bit_DAC_chn[USB_COMMAND[11:4] - 8'd192] <= USB_COMMAND[3:0];
  end
  else begin
    Microroc_4Bit_DAC_chn[0] <= Microroc_4Bit_DAC_chn[0];
    Microroc_4Bit_DAC_chn[1] <= Microroc_4Bit_DAC_chn[1];
    Microroc_4Bit_DAC_chn[2] <= Microroc_4Bit_DAC_chn[2];
    Microroc_4Bit_DAC_chn[3] <= Microroc_4Bit_DAC_chn[3];
    Microroc_4Bit_DAC_chn[4] <= Microroc_4Bit_DAC_chn[4];
    Microroc_4Bit_DAC_chn[5] <= Microroc_4Bit_DAC_chn[5];
    Microroc_4Bit_DAC_chn[6] <= Microroc_4Bit_DAC_chn[6];
    Microroc_4Bit_DAC_chn[7] <= Microroc_4Bit_DAC_chn[7];
    Microroc_4Bit_DAC_chn[8] <= Microroc_4Bit_DAC_chn[8];
    Microroc_4Bit_DAC_chn[9] <= Microroc_4Bit_DAC_chn[9];
    Microroc_4Bit_DAC_chn[10] <= Microroc_4Bit_DAC_chn[10];
    Microroc_4Bit_DAC_chn[11] <= Microroc_4Bit_DAC_chn[11];
    Microroc_4Bit_DAC_chn[12] <= Microroc_4Bit_DAC_chn[12];
    Microroc_4Bit_DAC_chn[13] <= Microroc_4Bit_DAC_chn[13];
    Microroc_4Bit_DAC_chn[14] <= Microroc_4Bit_DAC_chn[14];
    Microroc_4Bit_DAC_chn[15] <= Microroc_4Bit_DAC_chn[15];
    Microroc_4Bit_DAC_chn[16] <= Microroc_4Bit_DAC_chn[16];
    Microroc_4Bit_DAC_chn[17] <= Microroc_4Bit_DAC_chn[17];
    Microroc_4Bit_DAC_chn[18] <= Microroc_4Bit_DAC_chn[18];
    Microroc_4Bit_DAC_chn[19] <= Microroc_4Bit_DAC_chn[19];
    Microroc_4Bit_DAC_chn[20] <= Microroc_4Bit_DAC_chn[20];
    Microroc_4Bit_DAC_chn[21] <= Microroc_4Bit_DAC_chn[21];
    Microroc_4Bit_DAC_chn[22] <= Microroc_4Bit_DAC_chn[22];
    Microroc_4Bit_DAC_chn[23] <= Microroc_4Bit_DAC_chn[23];
    Microroc_4Bit_DAC_chn[24] <= Microroc_4Bit_DAC_chn[24];
    Microroc_4Bit_DAC_chn[25] <= Microroc_4Bit_DAC_chn[25];
    Microroc_4Bit_DAC_chn[26] <= Microroc_4Bit_DAC_chn[26];
    Microroc_4Bit_DAC_chn[27] <= Microroc_4Bit_DAC_chn[27];
    Microroc_4Bit_DAC_chn[28] <= Microroc_4Bit_DAC_chn[28];
    Microroc_4Bit_DAC_chn[29] <= Microroc_4Bit_DAC_chn[29];
    Microroc_4Bit_DAC_chn[30] <= Microroc_4Bit_DAC_chn[30];
    Microroc_4Bit_DAC_chn[31] <= Microroc_4Bit_DAC_chn[31];
    Microroc_4Bit_DAC_chn[32] <= Microroc_4Bit_DAC_chn[32];
    Microroc_4Bit_DAC_chn[33] <= Microroc_4Bit_DAC_chn[33];
    Microroc_4Bit_DAC_chn[34] <= Microroc_4Bit_DAC_chn[34];
    Microroc_4Bit_DAC_chn[35] <= Microroc_4Bit_DAC_chn[35];
    Microroc_4Bit_DAC_chn[36] <= Microroc_4Bit_DAC_chn[36];
    Microroc_4Bit_DAC_chn[37] <= Microroc_4Bit_DAC_chn[37];
    Microroc_4Bit_DAC_chn[38] <= Microroc_4Bit_DAC_chn[38];
    Microroc_4Bit_DAC_chn[39] <= Microroc_4Bit_DAC_chn[39];
    Microroc_4Bit_DAC_chn[40] <= Microroc_4Bit_DAC_chn[40];
    Microroc_4Bit_DAC_chn[41] <= Microroc_4Bit_DAC_chn[41];
    Microroc_4Bit_DAC_chn[42] <= Microroc_4Bit_DAC_chn[42];
    Microroc_4Bit_DAC_chn[43] <= Microroc_4Bit_DAC_chn[43];
    Microroc_4Bit_DAC_chn[44] <= Microroc_4Bit_DAC_chn[44];
    Microroc_4Bit_DAC_chn[45] <= Microroc_4Bit_DAC_chn[45];
    Microroc_4Bit_DAC_chn[46] <= Microroc_4Bit_DAC_chn[46];
    Microroc_4Bit_DAC_chn[47] <= Microroc_4Bit_DAC_chn[47];
    Microroc_4Bit_DAC_chn[48] <= Microroc_4Bit_DAC_chn[48];
    Microroc_4Bit_DAC_chn[49] <= Microroc_4Bit_DAC_chn[49];
    Microroc_4Bit_DAC_chn[50] <= Microroc_4Bit_DAC_chn[50];
    Microroc_4Bit_DAC_chn[51] <= Microroc_4Bit_DAC_chn[51];
    Microroc_4Bit_DAC_chn[52] <= Microroc_4Bit_DAC_chn[52];
    Microroc_4Bit_DAC_chn[53] <= Microroc_4Bit_DAC_chn[53];
    Microroc_4Bit_DAC_chn[54] <= Microroc_4Bit_DAC_chn[54];
    Microroc_4Bit_DAC_chn[55] <= Microroc_4Bit_DAC_chn[55];
    Microroc_4Bit_DAC_chn[56] <= Microroc_4Bit_DAC_chn[56];
    Microroc_4Bit_DAC_chn[57] <= Microroc_4Bit_DAC_chn[57];
    Microroc_4Bit_DAC_chn[58] <= Microroc_4Bit_DAC_chn[58];
    Microroc_4Bit_DAC_chn[59] <= Microroc_4Bit_DAC_chn[59];
    Microroc_4Bit_DAC_chn[60] <= Microroc_4Bit_DAC_chn[60];
    Microroc_4Bit_DAC_chn[61] <= Microroc_4Bit_DAC_chn[61];
    Microroc_4Bit_DAC_chn[62] <= Microroc_4Bit_DAC_chn[62];
    Microroc_4Bit_DAC_chn[63] <= Microroc_4Bit_DAC_chn[63];
    //Microroc_4Bit_DAC_chn <= Microroc_4Bit_DAC_chn;
  end
end
assign Microroc_4Bit_DAC = {Microroc_4Bit_DAC_chn[63],
                            Microroc_4Bit_DAC_chn[62],
                            Microroc_4Bit_DAC_chn[61],
                            Microroc_4Bit_DAC_chn[60],
                            Microroc_4Bit_DAC_chn[59],
                            Microroc_4Bit_DAC_chn[58],
                            Microroc_4Bit_DAC_chn[57],
                            Microroc_4Bit_DAC_chn[56],
                            Microroc_4Bit_DAC_chn[55],
                            Microroc_4Bit_DAC_chn[54],
                            Microroc_4Bit_DAC_chn[53],
                            Microroc_4Bit_DAC_chn[52],
                            Microroc_4Bit_DAC_chn[51],
                            Microroc_4Bit_DAC_chn[50],
                            Microroc_4Bit_DAC_chn[49],
                            Microroc_4Bit_DAC_chn[48],
                            Microroc_4Bit_DAC_chn[47],
                            Microroc_4Bit_DAC_chn[46],
                            Microroc_4Bit_DAC_chn[45],
                            Microroc_4Bit_DAC_chn[44],
                            Microroc_4Bit_DAC_chn[43],
                            Microroc_4Bit_DAC_chn[42],
                            Microroc_4Bit_DAC_chn[41],
                            Microroc_4Bit_DAC_chn[40],
                            Microroc_4Bit_DAC_chn[39],
                            Microroc_4Bit_DAC_chn[38],
                            Microroc_4Bit_DAC_chn[37],
                            Microroc_4Bit_DAC_chn[36],
                            Microroc_4Bit_DAC_chn[35],
                            Microroc_4Bit_DAC_chn[34],
                            Microroc_4Bit_DAC_chn[33],
                            Microroc_4Bit_DAC_chn[32],
                            Microroc_4Bit_DAC_chn[31],
                            Microroc_4Bit_DAC_chn[30],
                            Microroc_4Bit_DAC_chn[29],
                            Microroc_4Bit_DAC_chn[28],
                            Microroc_4Bit_DAC_chn[27],
                            Microroc_4Bit_DAC_chn[26],
                            Microroc_4Bit_DAC_chn[25],
                            Microroc_4Bit_DAC_chn[24],
                            Microroc_4Bit_DAC_chn[23],
                            Microroc_4Bit_DAC_chn[22],
                            Microroc_4Bit_DAC_chn[21],
                            Microroc_4Bit_DAC_chn[20],
                            Microroc_4Bit_DAC_chn[19],
                            Microroc_4Bit_DAC_chn[18],
                            Microroc_4Bit_DAC_chn[17],
                            Microroc_4Bit_DAC_chn[16],
                            Microroc_4Bit_DAC_chn[15],
                            Microroc_4Bit_DAC_chn[14],
                            Microroc_4Bit_DAC_chn[13],
                            Microroc_4Bit_DAC_chn[12],
                            Microroc_4Bit_DAC_chn[11],
                            Microroc_4Bit_DAC_chn[10],
                            Microroc_4Bit_DAC_chn[9],
                            Microroc_4Bit_DAC_chn[8],
                            Microroc_4Bit_DAC_chn[7],
                            Microroc_4Bit_DAC_chn[6],
                            Microroc_4Bit_DAC_chn[5],
                            Microroc_4Bit_DAC_chn[4],
                            Microroc_4Bit_DAC_chn[3],
                            Microroc_4Bit_DAC_chn[2],
                            Microroc_4Bit_DAC_chn[1],
                            Microroc_4Bit_DAC_chn[0]
                            };
// pulse Command D type
always @(posedge clk or negedge reset_n) begin
  if (~reset_n)
    Microroc_param_load <= 1'b0;
  else if (fifo_rden && USB_COMMAND == 16'hD0A2)
    Microroc_param_load <= 1'b1;
  else 
    Microroc_param_load <= 1'b0;
end
//Choose which ASIC's out_T&H output.  'D1Bx'
always @(posedge clk or negedge reset_n) begin
  if (~reset_n)
    ADG804_Addr <= 2'b00;
  else if (fifo_rden && USB_COMMAND[15:4] == 12'hD1B)
    ADG804_Addr <= USB_COMMAND[1:0];
  else
    ADG804_Addr <= ADG804_Addr;
end
//Choose whether out_T&H or power comsumption connected to ADC. 'D2F0':0 'D2F1':1
always @(posedge clk or negedge reset_n) begin
  if (~reset_n)
    ADG819_Addr <= 1'b0; //default:out_T&H 
  else if (fifo_rden && USB_COMMAND == 16'hD2F0)
    ADG819_Addr <= 1'b0;
  else if (fifo_rden && USB_COMMAND == 16'hD2F1)
    ADG819_Addr <= 1'b1;
  else 
    ADG819_Addr <= ADG819_Addr;
end
//--- S Curve Test Command E type ---//
// Choose Mode
// 00: Normal Acq
// 01: S Curve test
// 10: Sweep ACQ
always @(posedge clk or negedge reset_n)begin
  if(~reset_n)
    ModeSelect <= 2'b00;//default ACQ
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hE0A)
    ModeSelect <= USB_COMMAND[1:0];
  else
    ModeSelect <= ModeSelect;
end
// Choose Single channel test or 64 channel test
always @(posedge clk or negedge reset_n)begin
  if(~reset_n)
    Single_or_64Chn <= 1'b1;//Default Single Channel Test
  else if(fifo_rden && USB_COMMAND == 16'hE0B0)
    Single_or_64Chn <= 1'b1;
  else if(fifo_rden && USB_COMMAND == 16'hE0B1)
    Single_or_64Chn <= 1'b0;
  else
    Single_or_64Chn <= Single_or_64Chn;
end
// When Single Channel test, Choose the charge input from Ctest pin or input
// pin. Note that when choose 64 channel test, this parameter is shield
always @(posedge clk or negedge reset_n)begin
  if(~reset_n)
    CTest_or_Input <= 1'b1;//default CTest Pin
  else if(fifo_rden && USB_COMMAND == 16'hE0C0)
    CTest_or_Input <= 1'b1;
  else if(fifo_rden && USB_COMMAND ==16'hE0C1)
    CTest_or_Input <= 1'b0;
  else
    CTest_or_Input <= CTest_or_Input;
end
// Select Trigger Efficiency test or Counter Efficiency test
always @(posedge clk or negedge reset_n) begin
  if(~reset_n)
    TrigEffi_or_CountEffi <= 1'b1;
  else if(fifo_rden && USB_COMMAND == 16'hE0D0)
    TrigEffi_or_CountEffi <= 1'b1;
  else if(fifo_rden && USB_COMMAND == 16'hE0D1)
    TrigEffi_or_CountEffi <= 1'b0;
  else
    TrigEffi_or_CountEffi <= TrigEffi_or_CountEffi;
end

//S Curve test Start Stop Signl
always @(posedge clk or negedge reset_n) begin
  if(~reset_n)
    SweepTestStartStop <= 1'b0;
  else if(fifo_rden && USB_COMMAND == 16'hE0F0)
    SweepTestStartStop <= 1'b1;
  else if(fifo_rden && USB_COMMAND == 16'hE0F1)
    SweepTestStartStop <= 1'b0;
  else if(USB_FIFO_Empty & SweepTestDone)
    SweepTestStartStop <= 1'b0;
  else
    SweepTestStartStop <= SweepTestStartStop;
end
// Choose Sweep Acq Dac
always @(posedge clk or negedge reset_n)begin
  if(~reset_n)
    DacSelect <= 2'b0;
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hE00)
    DacSelect <= USB_COMMAND[1:0];
  else
    DacSelect <= DacSelect;
end
// When single channel test, Choose which channel are selected. Note that when choose 64 channel test, this parameter is shield
always @(posedge clk or negedge reset_n)begin
  if(~reset_n)
    SingleTest_Chn <= 6'b0;
  else if(fifo_rden && USB_COMMAND[15:8] == 8'hE1)
    SingleTest_Chn <= USB_COMMAND[5:0];
  else
    SingleTest_Chn <= SingleTest_Chn;
end
// Choose the max count number
localparam [7:0] CPT_MAX_200 = 8'h00,
                  CPT_MAX_1000 = 8'h01,
                  CPT_MAX_2000 = 8'h02,
                  CPT_MAX_5000 = 8'h03,
                  CPT_MAX_10000 = 8'h04,
                  CPT_MAX_20000 = 8'h05,
                  CPT_MAX_40000 = 8'h06,
                  CPT_MAX_50000 = 8'h07;
always @(posedge clk or negedge reset_n)begin
  if(~reset_n)
    CPT_MAX <= 16'd10000;
  else if(fifo_rden && USB_COMMAND[15:8] == 8'hE2)begin
    case(USB_COMMAND[7:0])
      CPT_MAX_200:  CPT_MAX <= 16'd200;
      CPT_MAX_1000: CPT_MAX <= 16'd1000;
      CPT_MAX_2000: CPT_MAX <= 16'd2000;
      CPT_MAX_5000: CPT_MAX <= 16'd5000;
      CPT_MAX_10000:CPT_MAX <= 16'd10000;
      CPT_MAX_20000:CPT_MAX <= 16'd20000;
      CPT_MAX_40000:CPT_MAX <= 16'd40000;
      CPT_MAX_50000:CPT_MAX <= 16'd50000;
      default:CPT_MAX <= 16'd10000;
    endcase
  end
  else
      CPT_MAX <= CPT_MAX;
end
// Select Counter efficiency test time
// Lower 8-bits is start with E3
always @ (posedge clk or negedge reset_n)begin
  if(~reset_n)
    CounterMax[7:0] <= 8'd0; 
  else if(fifo_rden && USB_COMMAND[15:8] == 8'hE3)
    CounterMax[7:0] <= USB_COMMAND[7:0];
  else
    CounterMax[7:0] <= CounterMax[7:0];
end
// Higher 8-bits is start with E4
always @ (posedge clk or negedge reset_n) begin
  if(~reset_n)
    CounterMax[15:8] <= 8'd0;
  else if(fifo_rden && USB_COMMAND[15:8] == 8'hE4)
    CounterMax[15:8] <= USB_COMMAND[7:0];
  else
    CounterMax[15:8] <= CounterMax[15:8];
end
/*localparam [7:0] Counter_MAX_0_1s = 8'h00,
                  Counter_MAX_1s = 8'h01,
                  Counter_MAX_2s = 8'h02,
                  Counter_MAX_4s = 8'h03,
                  Counter_MAX_5s = 8'h04,
                  Counter_MAX_6s = 8'h05,
                  Counter_MAX_8s = 8'h06,
                  Counter_MAX_10s = 8'h07;
always @(posedge clk or negedge reset_n) begin
  if(~reset_n)
    Counter_MAX <= 16'd1000;//Defaut 1s
  else if(fifo_rden && USB_COMMAND[15:8] == 8'hE3) begin
    case(USB_COMMAND[7:0])
      Counter_MAX_0_1s: Counter_MAX <= 16'd100;
      Counter_MAX_1s:   Counter_MAX <= 16'd1000;
      Counter_MAX_2s:   Counter_MAX <= 16'd2000;
      Counter_MAX_4s:   Counter_MAX <= 16'd4000;
      Counter_MAX_5s:   Counter_MAX <= 16'd5000;
      Counter_MAX_6s:   Counter_MAX <= 16'd6000;
      Counter_MAX_8s:   Counter_MAX <= 16'd8000;
      Counter_MAX_10s:  Counter_MAX <= 16'd10000;
      default: Counter_MAX <= 16'd1000;
    endcase
  end
  else
    Counter_MAX <= Counter_MAX;
end*/

//*** StartDac and EndDac
// E50X, E51Y, E52Z: {Z, Y, X} --> Start DAC
always @(posedge clk or negedge reset_n) begin
  if(~reset_n)
    StartDac <= 10'b0;
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hE50)
    StartDac[3:0] <= USB_COMMAND[3:0];
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hE51)
    StartDac[7:4] <= USB_COMMAND[3:0];
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hE52)
    StartDac[9:8] <= USB_COMMAND[1:0];
  else
    StartDac <= StartDac;
end
// E53X, E54Y, E55Z: {Z, Y, X} --> End DAC
always @(posedge clk or negedge reset_n) begin
  if(~reset_n)
    EndDac <= 10'd1023;
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hE53)
    EndDac[3:0] <= USB_COMMAND[3:0];
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hE54)
    EndDac[7:4] <= USB_COMMAND[3:0];
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hE55)
    EndDac[9:8] <= USB_COMMAND[1:0];
  else
    EndDac <= EndDac;
end
//*** Package Number
// Lower 8-bits of package number is started with E6
always @(posedge clk or negedge reset_n) begin
  if(~reset_n)
    MaxPackageNumber[7:0] <= 8'b0;
  else if(fifo_rden && USB_COMMAND[15:8] == 8'hE6)
    MaxPackageNumber[7:0] <= USB_COMMAND[7:0];
  else
    MaxPackageNumber[7:0] <= MaxPackageNumber[7:0];
end
// Higher 8-bits of package number is started with E7
always @(posedge clk or negedge reset_n) begin
  if(~reset_n)
    MaxPackageNumber[15:8] <= 8'b0;
  else if(fifo_rden && USB_COMMAND[15:8] == 8'hE7)
    MaxPackageNumber[15:8] <= USB_COMMAND[7:0];
  else
    MaxPackageNumber[15:8] <= MaxPackageNumber[15:8];
end
// Adc Start Command 
// E0F2:Start
// E0F3:Stop
always @(posedge clk or negedge reset_n) begin
  if(~reset_n)
    AdcStartAcq <= 1'b0;
  else if(fifo_rden && USB_COMMAND == 16'hE0F2)
    AdcStartAcq <= 1'b1;
  else if(fifo_rden && USB_COMMAND == 16'hE0F3)
    AdcStartAcq <= 1'b0;
  else
    AdcStartAcq <= AdcStartAcq;
end
// Adc Start Delay Time
// E80X:
always @(posedge clk or negedge reset_n) begin
  if(~reset_n)
    AdcStartDelayTime <= 4'b0;
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hE80)
    AdcStartDelayTime <= USB_COMMAND[3:0];
  else
    AdcStartDelayTime <=  AdcStartDelayTime;
end
// Adc data number
// + E81X:AdcDataNumber[3:0]
// + E82X:AdcDataNumber[7:4]
always @(posedge clk or negedge reset_n) begin
  if(~reset_n)
    AdcDataNumber <= 8'b0;
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hE81)
    AdcDataNumber[3:0] <= USB_COMMAND[3:0];
  else if(fifo_rden && USB_COMMAND[15:4] == 12'hE82)
    AdcDataNumber[7:4] <= USB_COMMAND[3:0];
  else
    AdcDataNumber <= AdcDataNumber;
end
//Swap the LSB and MSB
  function [9:0] Invert_10bit(input [9:0] num);
    begin
      Invert_10bit = {num[0], num[1], num[2], num[3], num[4], num[5], num[6], num[7], num[8], num[9]};
    end
  endfunction
endmodule
