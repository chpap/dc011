`timescale 1ns/1ps
module top_vt100(
    input           clk100_i,
    input           clk24_i,
    input           n_reset_i,
    output          TXD0,
    input           RXD0,
    output [3:0]    videoR_o,
    output [3:0]    videoG_o,
    output [3:0]    videoB_o,
    output          hSync_o,
    output          vSync_o,
    output [7:0]    LED);


    wire            clk_100,clk_24_07,clk_24_88,clk_6_25;

    assign clk_24_88 = clk24_i;

    vt100 VT100_INST(
    .clk24_i(clk_24_88),
    .clk100_i(clk100_i),
    .n_reset_i(n_reset_i),
    .TXD0(TXD0),
    .RXD0(RXD0),
    .videoR_o(videoR_o),
    .videoG_o(videoG_o),
    .videoB_o(videoB_o),
    .hSync_o,
    .vSync_o,
    .dataout_o(LED) );
endmodule
