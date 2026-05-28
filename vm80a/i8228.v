`timescale 1ns/1ps
module i8228(
    input           dbin_i,
    input           n_wr_i,
    input           n_stsb_i,
    input           hlda_i,
    input           n_busen_i,
    input [7:0]     d_i, // input from 8080
    output [7:0]    d_o, // output to 8080
    input [7:0]     db_i,// input from system bus
    output [7:0]    db_o,// output to system bus
    output          n_memr_o,
    output          n_memw_o,
    output          n_ior_o,
    output          n_iow_o,
    output          n_inta_o);

    wire      reset_out;
    reg [7:0] statusb = 8'b0;
    reg [7:0] db_i_int_hold = 8'bZ; //input buffer latches
    reg       n_memw_int, n_memr_int, n_ior_int, n_iow_int, n_inta_int = 1'b1;
    reg       held_flag, hold_flag = 1'b0;

    assign db_o = ~(n_busen_i | n_wr_i) ? d_i: 8'bZ;
    assign reset_out = (hold_flag ^ held_flag);

    assign d_o = (hlda_i) ? db_i_int_hold : db_i;

    assign n_memw_o = reset_out | n_wr_i | n_memw_int;
    assign n_iow_o = reset_out | n_wr_i | n_iow_int;

    assign n_memr_o = reset_out | n_memr_int;
    assign n_ior_o = reset_out | n_ior_int;
    assign n_inta_o = reset_out | n_inta_int;

    always @(posedge hlda_i) begin
	    db_i_int_hold <= db_i;
	    hold_flag <= ~hold_flag;
    end

//latch status byte
    always @(negedge n_stsb_i) begin
	statusb <= d_i;
    end
//Status word decoder
    always @(statusb,hold_flag) begin
//     case (db_i_int)
//       // Instruction Fetch
//       8'b10100010  : n_memr_o <= 0;
//       // Memory Read
//       8'b10000010  : n_memr_o <= 0;
//       // Stack Read
//       8'b10000110  : n_memr_o <= 0;
//       default : n_memr_o <= 1;
//     endcase
//     case (d_i)
//       // Memory Write
//       8'b00000000  : n_memw_next <= 0;
//       // Stack Write
//       8'b00000100  : n_memw_next <= 0;
//       default : n_memw_next <= 1;
//     endcase
//     case (d_i)
//       // Input Read
//       8'b01000010  : n_ior_o <= 0;
//       default : n_ior_o <= 1;
//     endcase
//     case (d_i)
//       // Output Write
//       8'b00010000  : n_iow_next <= 0;
//       default : n_iow_next <= 1;
//     endcase
//     case (d_i)
//       // Interrupt Acknowledge
//       8'b00100011  : n_inta_o <= 0;
//       // Interrupt Acknowledge While Halt
//       8'b00101011  : n_inta_o <= 0;
//       default : n_inta_o <= 1;
//     endcase
     n_memr_int <= (~statusb[7]) & statusb[1]; // read and not write
     n_memw_int <= statusb[1] | statusb[7]; //write and read
     n_ior_int <= ~(statusb[6] & statusb[1]);
     n_iow_int <= (~statusb[4]) | statusb[1];
     n_inta_int <= ~statusb[0];
     held_flag <= hold_flag;
     //if ( ~(n_memr_o & n_ior_o) )
     //	db_i_int <= d_i;
  end
     
endmodule
