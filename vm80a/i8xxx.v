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
    output         clk_f1,       // 
    output         clk_f2,       // 
    input          n_reset_i,
    output         f2_ttl_o,      //
    input [7:0]    d_i,         // data bus inouts
    output[7:0]    d_o,         // data bus inouts
    input          hold_i,      //
    input         hlda_i,      //
    input         dbin_i,      //
    output         reset_o,
    output         n_stsb_o,
    output         n_memr_o,
    output         n_memw_o,
    output         n_ior_o,
    output         n_iow_o,
    output         n_inta_o,
    input[7:0]     d80_i,
    output[7:0]      d80_o,
    output[31:0]    debug_o);

    wire[15:0]     a_o_int;
    wire           ready, reset_int,  n_reset_pulsed, n_stsb;
    wire 	   rdyin, sync,  n_wr, aena, dena,  inte, hlda;
    reg            clk_f1_core,clk_f2_core;
    reg           clk_f1_int,clk_f2_int;

    assign         rdyin = 1'b1;
    assign         n_stsb_o = n_stsb;
    assign         reset_o = reset_int;
    assign         clk_f1 = clk_f1_int;
    assign         clk_f2 = clk_f2_int;
always @(posedge clk_i)
begin
   clk_f1_int <= clk_f1_core;
   clk_f2_int <= clk_f2_core;
end


    i8224 I8224_INST(
    .sync_i(sync),
    .n_resin_i(n_reset_pulsed),
    .rdyin_i(rdyin),
    .clk_i(clk24_i),
    .clk_f1_o(clk_f1_core),
    .clk_f2_o(clk_f2_core),
    .n_stsb_o(n_stsb),
    .reset_o(reset_int),
    .ready_o(ready)
    );

i8228 I8228_INST(
    .dbin_i(dbin_i),
    .n_wr_i(n_wr),
    .n_stsb_i(n_stsb),
    .hlda_i(hlda_i),
    .d_i(d80_i),
    .db_i(d_i),
    .d_o(d80_o),
    .db_o(d_o),
    .n_busen_i(hlda),
    .n_memr_o(n_memr_o),
    .n_memw_o(n_memw_o),
    .n_ior_o(n_ior_o),
    .n_iow_o(n_iow_o),
    .n_inta_o(n_inta_o)
    );

  pulse_n_sig DELAY_SIG_INST(
    .clk_i(clk24_i),
    .n_sig_i(n_reset_i),
    .n_sig_dly_o(n_reset_pulsed)
   );
   //assign n_reset_pulsed = n_reset_i;

assign f2_ttl_o = clk_f2_core;
//assign debug_o[7:0] = dc_o_int;
//assign debug_o[15:8] = dc_i_int;
assign debug_o[16] = n_stsb;
assign debug_o[17] = n_wr;
assign debug_o[31:18] = 14'b0;


endmodule
