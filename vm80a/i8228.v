`timescale 1ns/1ps
module delay #(
    parameter DELAY_CYCLES = 2  // Number of clock cycles to delay (must be >= 1)
)(
    input  wire clk,            // System clock
    input  wire rst_n,          // Asynchronous active-low reset
    input  wire sig_in,         // 1-bit input signal to be delayed
    output wire sig_out         // 1-bit delayed output signal
);

    // If delay is 1, we just need a single flip-flop.
    // For larger delays, we create a shift register chain.
    reg [DELAY_CYCLES-1:0] shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= {DELAY_CYCLES{1'b0}}; // Clear register on reset
        end else begin
            // Concatenate the input with the shifted older bits
            shift_reg <= {shift_reg[DELAY_CYCLES-2:0], sig_in};
        end
    end

    // The output is the oldest bit in the shift register
    assign sig_out = shift_reg[DELAY_CYCLES-1];

endmodule


module i8228(
    input           clk_i,
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

    wire      reset_out; // reset output to 1
    wire      write_out; // enable output
    wire[7:0] d_o_int;
    wire[7:0] d_o_buf;
    wire[7:0] db_o_buf;
    reg [7:0] statusb = 8'b0;
    reg [7:0] db_i_int_hold = 8'b0; //input buffer latches
    reg       n_memw_int, n_memr_int, n_ior_int, n_iow_int, n_inta_int = 1'b1;
    reg       held_flag, hold_flag = 1'b0;
    reg       held_db_flag, db_flag = 1'b0;

    assign db_o_buf = ~(n_busen_i | dbin_i | ~write_out) ? d_i: 8'bZ;
    assign reset_out = (hold_flag ^ held_flag);
    assign write_out = (db_flag ^ held_db_flag) & ~(n_memw_o & n_iow_o);

    assign d_o_int = (hlda_i) ? db_i_int_hold : db_i;
    assign d_o_buf = (dbin_i) ? d_o_int: 8'bZ;

    assign n_memw_o = reset_out | n_wr_i | n_memw_int;
    assign n_iow_o = reset_out | n_wr_i | n_iow_int;

    assign n_memr_o = reset_out | n_memr_int;
    assign n_ior_o = reset_out | n_ior_int;
    assign n_inta_o = reset_out | n_inta_int;
    delay DELAY_INST(
    .clk(clk_i),
    .rst_n(1),
    .sig_in(db_o_buf),
    .sig_out(db_o)
    );
    delay DELAY_INST2(
    .clk(clk_i),
    .rst_n(1),
    .sig_in(d_o_buf),
    .sig_out(d_o)
    );
    //assign db_o = db_o_buf;

    always @(posedge hlda_i) begin
	    db_i_int_hold = db_i;
	    hold_flag = ~hold_flag;
    end
    always @(negedge dbin_i) begin
	    hold_flag = ~hold_flag;
    end

//latch status byte
    always @(negedge n_stsb_i) begin
	statusb <= d_i;
    end
    always @(posedge n_stsb_i) begin
	    db_flag = ~db_flag;
    end
//Status word decoder
    always @(statusb) begin
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
     held_db_flag <= db_flag;
     held_flag <= hold_flag;
     n_memr_int <= (~statusb[7]) & statusb[1]; // read and not write
     n_memw_int <= statusb[1] | statusb[7]; //write and read
     n_ior_int <= ~(statusb[6] & statusb[1]);
     n_iow_int <= (~statusb[4]) | statusb[1];
     n_inta_int <= ~statusb[0];
     //if ( ~(n_memr_o & n_ior_o) )
     //	db_i_int <= d_i;
  end
     
endmodule
