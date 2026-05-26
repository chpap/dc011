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
    output [7:0]   db_o,// output to system bus
    output reg      n_memr_o = 1'b1,
    output          n_memw_o,
    output reg      n_ior_o = 1'b1,
    output          n_iow_o,
    output reg      n_inta_o = 1'b1);

    wire     hlda;
    reg      hlda_r1,hlda_r2,hlda_r3 = 1'b0;
    reg      n_stsb_r1, n_stsb_r2, n_stsb_r3  = 1'b0;
    reg      n_wr_r1, n_wr_r2, n_wr_r3  = 1'b0;
    reg      n_memw_next= 1'b0;
    reg      n_iow_next= 1'b0;
    wire [7:0]    db_o_int = 8'hff;
    wire     stsb_ne,hold_pe,n_wr_ne;

    assign d_o = n_busen_i ?  8'hff : db_i;
    assign db_o = (n_busen_i | n_wr_i) ?  8'h00 : d_i;
    // Falling Edge Detection)
    assign n_wr_ne = n_wr_r3 & ~n_wr_r2;
    assign stsb_ne = n_stsb_r3 & ~n_stsb_r2;
    // Ανίχνευση Ανερχόμενης Ακμής (Rising Edge Detection)
    assign hold_pe = hlda_r2 &  ~hlda_r3;
    assign hlda = hlda_i & dbin_i;

    // write is stable, latch data
    //assign db_o_int = n_wr_i ? 8'b0 : d_i;
    assign n_memw_o = n_wr_i ? 1'b1 : n_memw_next;
    assign n_iow_o = n_wr_i ? 1'b1 : n_iow_next;

    always @(posedge clk_i) begin
	hlda_r3 = hlda_r2;
	hlda_r2 = hlda_r1;
	hlda_r1 = hlda;
     	n_stsb_r3 = n_stsb_r2;
    	n_stsb_r2 = n_stsb_r1;
    	n_stsb_r1 = n_stsb_i;
     	n_wr_r3 = n_wr_r2;
    	n_wr_r2 = n_wr_r1;
    	n_wr_r1 = n_wr_i;

//     if (n_wr_ne) begin // write is stable, latch data
//          db_o_int = d_i;
//	  n_memw_o = n_memw_next;
//	  n_iow_o = n_iow_next;
//     end
     if(hold_pe) 
     begin
	n_memr_o <= 1'b1;
	n_memw_next <= 1'b1;
	n_ior_o <= 1'b1;
	n_iow_next <= 1'b1;
	n_inta_o <= 1'b1;
     end
    if(stsb_ne) begin
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
       8'b00000000  : n_memw_next <= 0;
       // Stack Write
       8'b00000100  : n_memw_next <= 0;
       default : n_memw_next <= 1;
     endcase
     case (d_i)
       // Input Read
       8'b01000010  : n_ior_o <= 0;
       default : n_ior_o <= 1;
     endcase
     case (d_i)
       // Output Write
       8'b00010000  : n_iow_next <= 0;
       default : n_iow_next <= 1;
     endcase
     case (d_i)
       // Interrupt Acknowledge
       8'b00100011  : n_inta_o <= 0;
       // Interrupt Acknowledge While Halt
       8'b00101011  : n_inta_o <= 0;
       default : n_inta_o <= 1;
     endcase
     //n_memr_o <= (~d_i[7]) & d_i[1]; // read and not write
     //n_memw <= d_i[1] | d_i[7]; //write and read
     //n_ior_o <= ~(d_i[6] & d_i[1]);
     //n_iow <= (~d_i[4]) | d_i[1];
     //n_inta_o <= ~d_i[0];
  end
end
     
endmodule
