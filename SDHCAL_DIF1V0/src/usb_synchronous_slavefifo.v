`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////

// Company: University of Science and Technology of China
// Engineer:  JunbinZhang
// 
// Create Date:    12:32:05 07/08/2015 
// Design Name: 
// Module Name:    usb_synchronous_slavefifo 
// Project Name: 
// Target Devices: XC7A100TFGG484-2
// Tool versions: 
// Description:    the new usb slavefifo control logic, written by Junbin
// Zhang
//
// Dependencies:   All signals in IFCLK clock domain 
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments: 
//

//////////////////////////////////////////////////////////////////////////////////

module usb_synchronous_slavefifo(

    input IFCLK,
    input FLAGA,//EP6 Empty flag
    input FLAGB,//EP6 full flag
    input FLAGC, //EP2 Empty flag
    output nSLCS, //Chip select
    output reg nSLOE,//READ
    output reg nSLRD,//READ
    output reg nSLWR,    //WRITE
    output reg nPKTEND,  //WRITE
    output [1:0] FIFOADR,
    inout [15:0] FD_BUS,
    /*----interface with control---*/
    input Acq_Start_Stop, //maybe from other Clock domain
    output reg Ctr_rd_en,
    output reg [15:0] ControlWord,
    /*----interface with external fifo---*/
    input [15:0] in_from_ext_fifo_dout,
    input in_from_ext_fifo_empty,
    output reg out_to_ext_fifo_rd_en
    );
    /*--------Chip select---------------*/
    assign nSLCS = 1'b0;
    /*--------EP address define---------*/
    localparam EP6_ADDR = 2'b10;
    localparam EP2_ADDR = 2'b00;
    
    /*
    localparam [1:0] READ_IDLE = 2'b00,
                     READ_CHECK= 2'b01,
                     READ_START = 2'b10,
                     READ_PROCESS = 2'b11;
    reg [1:0] READ_State = READ_IDLE;
    always @ (posedge IFCLK) begin
      case(READ_State)
        READ_IDLE:begin
          ControlWord <= 16'b0;
          Ctr_rd_en <= 1'b0;
          nSLOE <= 1'b1;
          nSLRD <= 1'b1;
          READ_State <= READ_CHECK;
        end
        READ_CHECK:begin
          Ctr_rd_en <= 1'b0;
          if(!FLAGC) begin //wait for EP2 address settle
            READ_State <= READ_START;
          end
          else
            READ_State <= READ_CHECK;
        end
        READ_START:begin
          nSLOE <= 1'b0;
          nSLRD <= 1'b0;
          READ_State <= READ_PROCESS;
        end
        READ_PROCESS:begin
          Ctr_rd_en <= 1'b1;
          ControlWord <= FD_BUS;
          nSLOE <= 1'b1;
          nSLRD <= 1'b1;
          READ_State <= READ_CHECK;
        end
        default:
          READ_State <= READ_IDLE;
      endcase
    end
    */
    /*
    reg Acq_Start_Stop_sync1 = 1'b0;
    reg Acq_Start_Stop_sync2 = 1'b0;
    always @ (posedge IFCLK) begin
      Acq_Start_Stop_sync1 <= Acq_Start_Stop;
      Acq_Start_Stop_sync2 <= Acq_Start_Stop_sync1;
    end
    localparam [2:0] WR_IDLE = 3'd0,
                     WR_STATE = 3'd1,
                     WR_STEP1 = 3'd2,
                     WR_STEP2 = 3'd3,
                     WR_PKTEND = 3'd4;
    reg [2:0] WRITE_State = WR_IDLE;
    reg [15:0] FD_BUS_OUT = 16'b0;
    always @ (posedge IFCLK) begin
      case(WRITE_State)
        WR_IDLE:begin
          nSLWR <= 1'b1;
          nPKTEND <= 1'b1;
          out_to_ext_fifo_rd_en <= 1'b0;
         // if(Acq_Start_Stop_sync2 && FLAGC && in_from_ext_fifo_rd_data_count >= 12'd256) //make sure usb is not in read mode and Acq start
          if(Acq_Start_Stop_sync2 && FLAGC) //make sure usb is not in read mode and Acq start
            WRITE_State <= WR_STATE;
          else
            WRITE_State <= WR_IDLE;
        end
        WR_STATE:begin
          if(!Acq_Start_Stop_sync2)begin //when write operation is terminated
            if(!FLAGA & !FLAGB)    //if EP6 is not empty either not full,remain data in EP6 should be upload
              WRITE_State <= WR_PKTEND;
            else if(FLAGA) //if EP6 is empty return to idle
              WRITE_State <= WR_IDLE;
            else           //if EP6 is full,drive data on the bus,then turn to pktend
              WRITE_State <= WR_IDLE;
          end
          else begin //normal acq is running
            if(!in_from_ext_fifo_empty && !FLAGB) begin//external fifo is not empty and EP6 is not full
              WRITE_State <= WR_STEP1;
              out_to_ext_fifo_rd_en <= 1'b1;         //read the external fifo
            end
            else
              WRITE_State <= WR_STATE;
          end
        end
        WR_STEP1:begin //drive data on the bus
          out_to_ext_fifo_rd_en <= 1'b0;
          //FD_BUS_OUT <= in_from_ext_fifo_dout;
          FD_BUS_OUT <= Swap(in_from_ext_fifo_dout);
          //FD_BUS_OUT <= {in_from_ext_fifo_dout[7:0],in_from_ext_fifo_dout[15:8]};
          nSLWR  <= 1'b0;//assert SLWR
          WRITE_State <= WR_STEP2;
        end
        WR_STEP2:begin //deassert SLWR,if more data to write turn to WR_STATE
          nSLWR <= 1'b1; 
          WRITE_State <= WR_STATE;
        end
        WR_PKTEND:begin
          nPKTEND <= 1'b0;
          WRITE_State <= WR_IDLE;
        end
        default:WRITE_State <= WR_IDLE;
      endcase
    end
    assign FIFOADR = FLAGC ? EP6_ADDR : EP2_ADDR;
    assign FD_BUS = FLAGC ? FD_BUS_OUT : 16'bz;
    function [15:0] Swap(input [15:0] num);//swap high byte and low byte
      begin:swap
        Swap = {num[7:0],num[15:8]};
      end
    endfunction
    */
    reg Acq_Start_Stop_sync1 = 1'b0;
    reg Acq_Start_Stop_sync2 = 1'b0;
    always @ (posedge IFCLK) begin
      Acq_Start_Stop_sync1 <= Acq_Start_Stop;
      Acq_Start_Stop_sync2 <= Acq_Start_Stop_sync1;
    end    
    localparam [2:0] Idle = 3'd0,
                     READ = 3'd1,
                     READ_PROCESS = 3'd2,
                     WRITE = 3'd3,
                     WRITE_PROCESS = 3'd4,
                     PKTEND = 3'd5;
    reg [2:0] State = Idle;
    reg [15:0] FD_BUS_OUT = 16'b0;
    always @ (posedge IFCLK) begin
      case (State)
        Idle:begin
          if(!FLAGC) //read usb data is the priority
            State <= READ;
          else if(Acq_Start_Stop_sync2) begin //usb not in read mode and Acquisition start
            if(!in_from_ext_fifo_empty) //as long as ext fifo is not empty turn to write operation
              State <= WRITE;
            else 
              State <= Idle; //acquisition started but EXT fifo is empty stay Idle and wait
          end
          else if(!FLAGA & !FLAGB) //usb not in read mode and Acquisition cancelled, if EP6 is not full nor empty, the remain data should be upload.
           State <= PKTEND;               
          else      //usb not in read mode nor write mode stay Idle.
            State <= Idle;
        end

        READ:begin
          State <= READ_PROCESS;
          ControlWord <= FD_BUS;
        end

        READ_PROCESS:begin
          State <= Idle;
        end

        WRITE:begin
          if(!FLAGB) begin //aquisition is running EP6 is not full,get ext fifo data then write in to EP6
            FD_BUS_OUT <= Swap(in_from_ext_fifo_dout);
            State <= WRITE_PROCESS;
          end
          else
            State <= WRITE;
        end

        WRITE_PROCESS:begin
          State <= Idle;  //assert SLWR, turn to Idle
        end

        PKTEND:begin
          State <= Idle;  //assert PKTEND, turn to Idle
        end
        default:State <= Idle;
      endcase
    end
    always @ (*) begin
      if(State == READ) begin
         nSLOE = 1'b0; //assert
         nSLRD = 1'b0; //assert
      end
      else begin
        nSLOE = 1'b1; //deassert
        nSLRD = 1'b1; //deassert
      end
    end
    always @ (*) begin
      if(State == READ_PROCESS)
        Ctr_rd_en = 1'b1; //assert
      else
        Ctr_rd_en = 1'b0;
    end
    always @ (*) begin
      if(State == WRITE)
        out_to_ext_fifo_rd_en = 1'b1; //assert
      else
        out_to_ext_fifo_rd_en = 1'b0;
    end
    always @ (*) begin
      if(State == WRITE_PROCESS)
        nSLWR = 1'b0;  //assert
      else
        nSLWR = 1'b1;
    end
    always @ (*) begin
      if(State == PKTEND)
        nPKTEND = 1'b0;  //assert
      else
        nPKTEND = 1'b1;
    end

    assign FIFOADR = FLAGC ? EP6_ADDR : EP2_ADDR;
    assign FD_BUS = FLAGC ? FD_BUS_OUT : 16'bz;
    //swap high byte and low byte
    function [15:0] Swap(input [15:0] num);
      begin:swap
        Swap = {num[7:0],num[15:8]};
      end
    endfunction

//Debug part
/*(*mark_debug = "true"*)wire [16:0] FD_BUS_OUT_debug;
(*mark_debug = "true"*)wire nSLWR_debug;
assign FD_BUS_OUT_debug = FD_BUS_OUT;
assign nSLWR_debug = nSLWR;*/
endmodule

