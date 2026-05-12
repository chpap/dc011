// i8080 + i8224 
`timescale 1ns/1ps


module i8xxx(
    input          clk_i,       // global module clock (no in original 8080)
    input          clk24_i,       // global module clock (no in original 8080)
    input          n_reset_i,
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
    output         n_stsb_o);


    wire[7:0]      db_i;
    wire[7:0]      db_o;
    wire[7:0]      dc_i;
    wire[7:0]      dc_o;
    wire           clk_f1, clk_f2, ready, reset_int, reset_int2, n_strobe;
    wire 	   rdyin, sync, dbin, n_wr, aena, dena, sync2, inte;
    reg            f1_core,f2_core;

    assign dc_i = d_i;
    assign d_o = dc_o;
always @(posedge clk_i)
begin
   f1_core <= clk_f1;
   f2_core <= clk_f2;
end

    vm80a_core I8080_INST (
    .pin_clk(clk_i),       // global module clock (no in original 8080)
    .pin_f1(clk_f1),        // clock phase 1 (used as clock enable)
    .pin_f2(clk_f2),        // clock phase 2 (used as clock enable)
    .pin_reset(reset_int),     // module reset
    .pin_a(a_o),         // address bus outputs
    .pin_din(dc_i),      //
    .pin_dbin(dbin),
    .pin_dout(dc_o),      //
    .pin_hold(hold_i),      //
    .pin_hlda(hlda_o),      //
    .pin_ready(ready),     //
    .pin_wait(wait_o),      //
    .pin_int(int_i),       //
    .pin_inte(inte_o),      //
    .pin_sync(sync),      //
    .pin_aena(aena),      //
    .pin_dena(dena),      //
    .pin_wr_n(n_wr)
    );

    
//    assign pin_inte = clk_f1;
//    assign pin_wait = clk_f2;
//always @(posedge clk_f1) begin
//    pin_inte <= clk_f1;
//end

    i8224 I8224_INST(
    .sync_i(sync),
    .n_resin_i(n_reset_i),
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
    .d_i(dc_o),
    .db_i(db_i),
    .d_o(dc_i),
    .db_o(db_o),
    .n_busen_i(1'b0)
    );

//    output[7:0]     d_o = 0,
//    output[7:0]     db_o = 0,
//    output reg      n_memr_o = 0,
//    output reg      n_memw_o = 0,
//    output          n_ior_o ,
//    output          n_iow_o ,
//    output reg      n_inta_o = 0)

endmodule
