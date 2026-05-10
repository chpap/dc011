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
    output         sync,      //
    output         pin_dbin,      //
    output         pin_wr_n,
    input          sync_i,
    input          n_resin_i,
    output         n_stsb_o,
    output         reset_o,
    output         ready_o);


    wire           clk_f1;
    wire           clk_f2;
    wire           ready;
    wire           reset_int;
    wire           n_strobe;
    wire           en_rdyn_i;



    //assign rco = ent & qd & qc & qb & qa;

    vm80a I8080_INST (
    .pin_clk(clk_i),       // global module clock (no in original 8080)
    .pin_f1(clk_f1),        // clock phase 1 (used as clock enable)
    .pin_f2(clk_f2),        // clock phase 2 (used as clock enable)
    .pin_reset(reset_int),     // module reset
    .pin_a(pin_a),         // address bus outputs
    .pin_d(pin_d),         // data bus inouts
    .pin_hold(pin_hold),      //
    .pin_hlda(pin_hlda),      //
    .pin_ready(ready),     //
    .pin_wait(pin_wait),      //
    .pin_int(pin_int),       //
    .pin_inte(pin_inte),      //
    .pin_sync(sync),      //
    .pin_dbin(pin_dbin),      //
    .pin_wr_n(pin_wr_n)
    );

    i8224 I8224_INST(
    .sync_i(sync),
    .n_resin_i(reset),
    .en_rdyn_i(en_rdyn_i),
    .clk_i(clk24_i),
    .clk_f1_o(clk_f1),
    .clk_f2_o(clk_f2),
    .n_stsb_0(n_strobe),
    .reset_o(reset_int),
    .ready_o(ready)
);
//`ifdef COCOTB_SIM
//initial begin
//    $dumpfile("i8xxx.vcd");
//    $dumpvars(0, i8xxx);
//end
//`endif

endmodule
