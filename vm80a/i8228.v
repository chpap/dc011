`timescale 1ns/1ps
module i8228(
    input           clk_i, //not in original design
    input           dbin_i,
    input           n_wr_i,
    input           n_stsb_i,
    input           hlda_i,
    input           n_busen_i,
    input [7:0]      d_i, // input from 8080
    output[7:0]     d_o, // output to 8080
    input [7:0]      db_i,// input from system bus
    output [7:0]    db_o,// output to system bus
    output reg      n_memr_o = 1'b1,
    output reg      n_memw_o = 1'b1,
    output reg      n_ior_o = 1'b1,
    output reg      n_iow_o = 1'b1,
    output reg      n_inta_o = 1'b1);

    wire     hlda;
    reg      hlda_r1 = 1'b0;
    reg      hlda_r2 = 1'b0;
    reg      hlda_r3 = 1'b0;
    reg      n_stsb_r1 = 1'b0;
    reg      n_stsb_r2 = 1'b0;
    reg      n_stsb_r3 = 1'b0;
    wire     stsb_pe, hold_pe;

    // assign d_o_int = dbin_int ? db_i : 8'hff;
    //assign db_o_int = n_wr_int ? d_i : 8'hff;
    //assign hlda = dbin_int & hlda_int;
    assign d_o = n_busen_i ?  8'hff : db_i;
    assign db_o = (n_busen_i | ~n_wr_i) ?  8'hff : d_i;
    assign stsb_pe = n_stsb_r2 & ~n_stsb_r3;
    // Ανίχνευση Ανερχόμενης Ακμής (Rising Edge Detection)
    assign hold_pe = hlda_r2 &  ~hlda_r3;
    assign hlda = hlda_i & dbin_i;


    //always @* begin //(posedge clk_i,d_i) begin
    always @(posedge clk_i,d_i) begin
	hlda_r3 = hlda_r2;
	hlda_r2 = hlda_r1;
	hlda_r1 = hlda;
	n_stsb_r3 = n_stsb_r2;
	n_stsb_r2 = n_stsb_r1;
	n_stsb_r1 = n_stsb_i;


     if(hold_pe) begin
	n_memr_o <= 1'b1;
	//n_memw_o <= 1'b1;
	n_ior_o <= 1'b1;
	// n_iow_o <= 1'b1;
	n_inta_o <= 1'b1;
     end
//always @(posedge n_stsb_i) begin
    // dbin_int <= dbin_i;
    if(stsb_pe) begin
    //n_dbusen_int <= n_busen_i | ~n_wr_int;

    case (d_i)
      // Instruction Fetch
      8'b10100010  : n_memr_o <= 0;
      // Memory Read
      8'b10000010  : n_memr_o <= 0;
      // Stack Read
      8'b10000110  : n_memr_o <= 0;
      default : n_memr_o <= 1;
    endcase
    case (d_i)
      // Memory Write
      8'b00000000  : n_memw_o <= 0;
      // Stack Write
      8'b00000100  : n_memw_o <= 0;
      default : n_memw_o <= 1;
    endcase
    case (d_i)
      // Input Read
      8'b01000010  : n_ior_o <= 0;
      default : n_ior_o <= 1;
    endcase
    case (d_i)
      // Output Write
      8'b00010000  : n_iow_o <= 0;
      default : n_iow_o <= 1;
    endcase
    case (d_i)
      // Interrupt Acknowledge
      8'b00100011  : n_inta_o <= 0;
      // Interrupt Acknowledge While Halt
      8'b00101011  : n_inta_o <= 0;
      default : n_inta_o <= 1;
    endcase
end
end
     
endmodule
