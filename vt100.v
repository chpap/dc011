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
    wire            hlda,wait80,inte,n_stsb,dbin,n_wr;
    wire            hold = 1'b0;
    wire            int80 = 1'b0;
    wire            ready = 1'b1;


    assign d_i = 8'b0;
    assign ready = 1'b1;
    assign int80 = 1'b0;
    i8xxx I8XXXX(
    .clk_i(clk100_i),
    .clk24_i(clk24_i),
    .a_o(a_o),
    .d_i(d_i),
    .d_o(d_o),
    .hold_i(hold),
    .hlda_o(hlda),
    .ready_i(ready),
    .wait_o(wait80),
    .int_i(int80),
    .inte_o(inte),
    .dbin_o(dbin),
    .n_wr_o(n_wr),
    .n_reset_i(n_reset_i),
    .n_stsb_o(n_stsb));
endmodule
