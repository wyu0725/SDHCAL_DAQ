`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/12 17:16:50
// Design Name: 
// Module Name: TriggerSwitcher
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


module TriggerSwitcher(
  input SyncClk,
  input reset_n,
  input [3:0] TriggerSelect,
  input OutTrigger0b,
  input OutTrigger1b,
  input OutTrigger2b,
  input TriggerExt,
  output Trigger,
  output TriggerAnd,
  output TriggerOr,
  output ExternalTriggerSyncOut,
  input ExternalSyncSignalIn,
  output SyncSignalOut
    );
  reg InternalTrigger0;
  reg InternalTrigger1;
  reg InternalTrigger2;
  reg TriggerExternal;
  always @ (posedge SyncClk or negedge reset_n) begin
    if(~reset_n) begin
      InternalTrigger0 <= 1'b0;
      InternalTrigger1 <= 1'b0;
      InternalTrigger2 <= 1'b0;
      TriggerExternal <= 1'b0;
    end
    else begin
      InternalTrigger0 <= ~OutTrigger0b;
      InternalTrigger1 <= ~OutTrigger1b;
      InternalTrigger2 <= ~OutTrigger2b;
      TriggerExternal <= TriggerExt;
    end
  end
  reg TriggerSelected;
  always @(*) begin
    case(TriggerSelect)
      4'b0000:TriggerSelected = InternalTrigger0;
      4'b0001:TriggerSelected = InternalTrigger1;
      4'b0010:TriggerSelected = InternalTrigger2;
      4'b1000:TriggerSelected = TriggerExternal;
      default:TriggerSelected = InternalTrigger0;
    endcase
  end
  BUFG BUFG_TRIGGER (
      .O(Trigger), // 1-bit output: Clock output
      .I(TriggerSelected)  // 1-bit input: Clock input
   );
  wire TriggerAndInternal;
  assign TriggerAndInternal = InternalTrigger0 && InternalTrigger1 && InternalTrigger2;
  BUFG BUFG_TRIGGER_AND (
      .O(TriggerAnd), // 1-bit output: Clock output
      .I(TriggerAndInternal)  // 1-bit input: Clock input
   );
  wire TriggerOrInternal;
  assign TriggerOrInternal = InternalTrigger0 || InternalTrigger1 || InternalTrigger2;
  BUFG BUFG_TRIGGER_OR (
      .O(TriggerOr), // 1-bit output: Clock output
      .I(TriggerOrInternal)  // 1-bit input: Clock input
   );
  BUFG BUFG_TRIGGER_EXT (
      .O(ExternalTriggerSyncOut), // 1-bit output: Clock output
      .I(TriggerExternal)  // 1-bit input: Clock input
   );

  BUFG BUFG_SYNC_SIGNAL (
      .O(SyncSignalOut), // 1-bit output: Clock output
      .I(ExternalSyncSignalIn)  // 1-bit input: Clock input
   );
endmodule
