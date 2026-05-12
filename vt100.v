`timescale 1ns/1ps
module vt100(
    input           clk24_i,
    input           clk100_i,
    input           n_reset_i,
    output          TXD0,
    input           RXD0,
    output [3:0]    videoR_o,
    output [3:0]    videoG_o,
    output [3:0]    videoB_o,
    output          hSync_o,
    output          vSync_o,
    output [7:0]    dataout_o);


    wire[15:0]      a_o;
    wire[7:0]       d_i;
    wire[7:0]       d_o;
    wire            hlda,wait80,inte,n_stsb;

    i8xxx I8XXXX(
    .clk_i(clk100_i),
    .clk24_i(clk24_i),
    .a_o(a_o),
    .d_i(d_i),
    .d_o(d_o),
    .hold_i(1'b0),
    .hlda_o(hlda),
    .ready_i(1'b1),
    .wait_o(wait80),
    .int_i(1'b0),
    .inte_o(inte),
    .dbin_o(),
    .n_wr_o(),
    .n_reset_i(n_reset_i),
    .n_stsb_o(n_stsb));
endmodule
