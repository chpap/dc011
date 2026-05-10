// i8080 + i8224 
`timescale 1ns/1ps


module i8xxx(
    input          clk_i,       // global module clock (no in original 8080)
    input          clk24_i,       // global module clock (no in original 8080)
    input          reset,     // module reset
    output[15:0]   pin_a,         // address bus outputs
    inout [7:0]    pin_d,         // data bus inouts
    input          pin_hold,      //
    output         pin_hlda,      //
    input          pin_ready,     //
    output         pin_wait,      //
    input          pin_int,       //
    output         pin_inte,      //
    output         pin_dbin,      //
    output         pin_wr_n,
    input          n_reset_i,
    output         n_stsb_o,
    output         reset_o,
    output         ready_o);


    wire[7:0]      d_i;
    wire[7:0]      d_o;
    wire[7:0]      db_i=8'b0;
    wire[7:0]      db_o;
    wire           clk_f1, clk_f2, ready, reset_int, reset_int2, n_strobe;
    wire 	   rdyin, sync, hlda, dbin, n_wr, aena, dena, sync2;

    vm80a_core I8080_INST (
    .pin_clk(clk_i),       // global module clock (no in original 8080)
    .pin_f1(clk_f1),        // clock phase 1 (used as clock enable)
    .pin_f2(clk_f2),        // clock phase 2 (used as clock enable)
    .pin_reset(reset_int),     // module reset
    .pin_a(pin_a),         // address bus outputs
    .pin_din(d_i),      //
    .pin_dbin(dbin),
    .pin_dout(d_o),      //
    .pin_hold(1'b0),      //
    .pin_hlda(hlda),      //
    .pin_ready(ready),     //
    .pin_wait(pin_wait),      //
    .pin_int(1'b0),       //
    .pin_inte(pin_inte),      //
    .pin_sync(sync),      //
    .pin_aena(aena),      //
    .pin_dena(dena),      //
    .pin_wr_n(n_wr)
    );

    i8224 I8224_INST(
    .sync_i(sync),
    .n_resin_i(~reset),
    .rdyin_i(1'b1),
    .clk_i(clk24_i),
    .clk_f1_o(clk_f1),
    .clk_f2_o(clk_f2),
    .n_stsb_o(n_strobe),
    .reset_o(reset_int),
    .ready_o(ready)
    );

i8228 I8228_INST(
    .dbin_i(dbin),
    .n_wr_i(n_wr),
    .n_stsb_i(n_strobe),
    .hlda_i(hlda),
    .d_i(d_o),
    .db_i(db_i),
    .d_o(d_i),
    .db_o(db_o),
    .n_busen_i(0)
    );

//    output[7:0]     d_o = 0,
//    output[7:0]     db_o = 0,
//    output reg      n_memr_o = 0,
//    output reg      n_memw_o = 0,
//    output          n_ior_o ,
//    output          n_iow_o ,
//    output reg      n_inta_o = 0)

endmodule
