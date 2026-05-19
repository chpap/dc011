// i8080 + i8224 
`timescale 1ns/1ps


module i8xxx(
    input          clk_i,       // global module clock (no in original 8080)
    input          clk24_i,       // global module clock (no in original 8080)
    input          n_reset_i,
    output         f2_ttl_o,      //
    output[15:0]   a_o,         // address bus outputs
    input [7:0]    d_i,         // data bus inouts
    output[7:0]    d_o,         // data bus inouts
    input          hold_i,      //
    output         hlda_o,      //
    input          ready_i,     //
    output         wait_o,      //
    input          int_i,       //
    output         inte_o,      //
    output         dbin_o,      //
    output         n_wr_o,
    output         reset_o,
    output         n_stsb_o,
    output         n_memr_o,
    output         n_memw_o,
    output         n_ior_o,
    output         n_iow_o,
    output         n_inta_o);

    wire[7:0]      dc_i_int;
    wire[7:0]      dc_o_int;
    wire           clk_f1, clk_f2, ready, reset_int, n_stsb;
    wire 	   rdyin, sync, dbin, n_wr, aena, dena,  inte, hlda;
    reg            f1_core,f2_core;

    assign         rdyin = 1'b1;
    assign         hlda_o = hlda;
    assign         dbin_o = dbin;
    assign         n_stsb_o = n_stsb;
    assign         reset_o = reset_int;
always @(posedge clk_i)
begin
   f1_core <= clk_f1;
   f2_core <= clk_f2;
end

    vm80a_core I8080_INST (
    .pin_clk(clk_i),       // global module clock (no in original 8080)
    .pin_f1(f1_core),        // clock phase 1 (used as clock enable)
    .pin_f2(f2_core),        // clock phase 2 (used as clock enable)
    .pin_reset(reset_int),     // module reset
    .pin_a(a_o),         // address bus outputs
    .pin_din(dc_i_int),      //
    .pin_dbin(dbin),
    .pin_dout(dc_o_int),      //
    .pin_hold(hold_i),      //
    .pin_hlda(hlda),      //
    .pin_ready(ready),     //
    .pin_wait(wait_o),      //
    .pin_int(int_i),       //
    .pin_inte(inte_o),      //
    .pin_sync(sync),      //
    .pin_aena(aena),      //
    .pin_dena(dena),      //
    .pin_wr_n(n_wr)
    );


    i8224 I8224_INST(
    .sync_i(sync),
    .n_resin_i(n_reset_i),
    .rdyin_i(rdyin),
    .clk_i(clk24_i),
    .clk_f1_o(clk_f1),
    .clk_f2_o(clk_f2),
    .n_stsb_o(n_stsb),
    .reset_o(reset_int),
    .ready_o(ready)
    );

i8228 I8228_INST(
    .clk_i(clk_i),
    .dbin_i(dbin),
    .n_wr_i(n_wr),
    .n_stsb_i(n_stsb),
    .hlda_i(hlda),
    .d_i(dc_o_int),
    .db_i(d_i),
    .d_o(dc_i_int),
    .db_o(d_o),
    .n_busen_i(hlda),
    .n_memr_o(n_memr_o),
    .n_memw_o(n_memw_o),
    .n_ior_o(n_ior_o),
    .n_iow_o(n_iow_o),
    .n_inta_o(n_inta_o)
    );

assign f2_ttl_o = f2_core;


endmodule
