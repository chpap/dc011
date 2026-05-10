
module i8224(
    input           sync_i,
    input           n_resin_i,
    input           en_rdyn_i,
    input           clk_i,
    output          clk_f1_o,
    output          clk_f2_o,
    output          n_stsb_0,
    output          reset_o,
    output          ready_o);

    assign clk_f1_o  = ~clk_i;

//`ifdef COCOTB_SIM
//initial begin
//    $dumpfile("dump.vcd");
//    $dumpvars(1, i8224);
//end
//`endif

endmodule
