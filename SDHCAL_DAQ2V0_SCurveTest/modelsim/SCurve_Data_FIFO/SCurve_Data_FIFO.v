`timescale 1ns/1ns
module SCurve_Data_FIFO(
  input clk,
  input rst,
  input [15:0] din,
  input wr_en,
  input rd_en,
  output reg [15:0] dout,
  output reg full,
  output reg empty
);
reg [15:0] fifo_data[0:15];
localparam [15:0] fifo_initial = 16'd0;
wire rst_n = ~rst;
reg [3:0] fifo_bottom;
reg [3:0] fifo_top;
reg [1:0] State;
localparam [1:0] NONE = 2'b00,
                 READ = 2'b01,
                 WRITE = 2'b10,
                 READ_WRITE = 2'b11;
wire clk_n = ~clk;
always @(posedge clk_n or posedge rst_n)begin
  if(~rst_n)begin
    State <= NONE;    
  end
  else begin
    //State <= {(wr_en&!full),(rd_en&!empty)};
    State <= {wr_en, rd_en};
  end
end
always @(posedge clk or posedge rst_n)begin
  if(~rst_n)begin
    full <= 1'b0;
    empty <= 1'b1;
  end
  else if(fifo_bottom == fifo_top)begin
    full <= 1'b0;
    empty <= 1'b1;
  end
  else if((fifo_top - fifo_bottom) == 4'd15)begin
    full <= 1'b1;
    empty <= 1'b0;
  end
  else begin
    full <= 1'b0;
    empty <= 1'b0;
  end
end
localparam test = 5;

always @(posedge clk_n or negedge rst_n)begin
  if(~rst_n)begin
    fifo_bottom <= 4'b0;
    fifo_top <= 4'b0;
    fifo_data[0] <= fifo_initial;
    fifo_data[1] <= fifo_initial;
    fifo_data[2] <= fifo_initial;
    fifo_data[3] <= fifo_initial;
    fifo_data[4] <= fifo_initial;
    fifo_data[5] <= fifo_initial;
    fifo_data[6] <= fifo_initial;
    fifo_data[7] <= fifo_initial;
    fifo_data[8] <= fifo_initial;
    fifo_data[9] <= fifo_initial;
    fifo_data[10] <= fifo_initial;
    fifo_data[11] <= fifo_initial;
    fifo_data[12] <= fifo_initial;
    fifo_data[13] <= fifo_initial;
    fifo_data[14] <= fifo_initial;
    fifo_data[15] <= fifo_initial;
  end
  else begin
    case(State)
      NONE:begin
        fifo_data[0] <= fifo_data[0];
        fifo_data[1] <= fifo_data[1];
        fifo_data[2] <= fifo_data[2];
        fifo_data[3] <= fifo_data[3];
        fifo_data[4] <= fifo_data[4];
        fifo_data[5] <= fifo_data[5];
        fifo_data[6] <= fifo_data[6];
        fifo_data[7] <= fifo_data[7];
        fifo_data[8] <= fifo_data[8];
        fifo_data[9] <= fifo_data[9];
        fifo_data[10] <= fifo_data[10];
        fifo_data[11] <= fifo_data[11];
        fifo_data[12] <= fifo_data[12];
        fifo_data[13] <= fifo_data[13];
        fifo_data[14] <= fifo_data[14];
        fifo_data[15] <= fifo_data[15];
        fifo_bottom <= fifo_bottom;
        fifo_top <= fifo_top;
      end
      READ:begin
        dout <= fifo_data[fifo_bottom];
        fifo_bottom <= fifo_bottom + 1'b1;
      end
      WRITE:begin
        fifo_data[fifo_top] <= din;
        fifo_top <= fifo_top + 1'b1;
      end
      READ_WRITE:begin
        fifo_data[fifo_top] <= din;
        fifo_top <= fifo_top + 1'b1;
        dout <= fifo_data[fifo_bottom];
        fifo_bottom <= fifo_bottom + 1'b1;
      end
    endcase
  end
end


endmodule
