// i8080 + i8224 
`timescale 1ns/1ps
module pulse_n_sig(
  input      clk_i,
  input      n_sig_i,
  output reg n_sig_dly_o
);
  parameter pwidth = 1;

  reg [7:0]  n_sig_d = 8'h01; 
  reg        sig_zeros = 1'b1;
  integer i;

always @(posedge clk_i) begin
  sig_zeros = 1'b1; // Initialize count
  for (i = 0; i < pwidth; i = i + 1) begin
    //sig_ones = sig_ones + n_sig_d[i]; // Increment count for each 1
    sig_zeros = sig_zeros & n_sig_d[i]; // Increment count for each 0
  end
  n_sig_d = (n_sig_d << 1) | {7'b0 , n_sig_i};
  n_sig_dly_o =  sig_zeros  ? 1'b1 : 1'b0;
end

endmodule


module i8xxx(
    input          clk_i,       // global module clock (no in original 8080)
    input          clk24_i,       // global module clock (no in original 8080)
    input          n_reset_i,
    output         f2_ttl_o,      //
    input [7:0]    d_i,         // data bus inouts
    output[7:0]    d_o,         // data bus inouts
    input         hlda_i,      //
    input         dbin_i,      //
    input 	   n_stsb_i,
    output         n_memr_o,
    output         n_memw_o,
    output         n_ior_o,
    output         n_iow_o,
    output         n_inta_o,
    output[31:0]    debug_o);

    wire[7:0]      dc_i_int;
    wire[7:0]      dc_o_int;
    wire 	   n_wr, aena, dena,  inte ;



i8228 I8228_INST(
    .dbin_i(dbin_i),
    .n_wr_i(n_wr),
    .n_stsb_i(n_stsb_i),
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


assign f2_ttl_o = clk24_i;
assign debug_o[7:0] = dc_o_int;
assign debug_o[15:8] = dc_i_int;
assign debug_o[16] = n_stsb_i;
assign debug_o[17] = n_wr;
assign debug_o[31:18] = 14'b0;


endmodule
