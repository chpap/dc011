module i8228(
    input           dbin_i,
    input           n_wr_i,
    input           n_stsb_i,
    input           hlda_i,
    input           n_busen_i,
    input[7:0]      d_i, // input from 8080
    output[7:0]     d_o, // output to 8080
    input[7:0]      db_i,// input from system bus 
    output[7:0]     db_o,// output to system bus
    output reg      n_memr_o = 0, 
    output reg      n_memw_o = 0,
    output reg      n_ior_o ,
    output reg      n_iow_o ,
    output reg      n_inta_o = 0);

    wire            din_z=1;
    wire            hlda;
    wire[7:0]       d_o_int;
    wire[7:0]       db_o_int; 

    assign d_o_int = dbin_i ? db_i : 8'b1;
    assign db_o_int = n_wr_i ? d_i : 8'b1;
    assign hlda = dbin_i & hlda_i;
    assign d_o = n_busen_i ?  8'b1 : d_o_int;
    assign db_o = n_busen_i ?  8'b1 : db_o_int;

always @(posedge hlda) begin
	n_memr_o <= 0;
	n_ior_o <= 0;
	n_inta_o <= 0;
end
always @(posedge n_stsb_i) begin
    case (d_i)
      // Instruction Fetch
      8'b10100010  : n_memr_o <= 1;
      // Memory Read
      8'b10000010  : n_memr_o <= 1;
      // Stack Read
      8'b10000110  : n_memr_o <= 1;
      default : n_memr_o <= 0; 
    endcase
    case (d_i)
      // Memory Write
      8'b00000000  : n_memw_o <= 1;
      // Stack Write
      8'b00000100  : n_memw_o <= 1;
      default : n_memw_o <= 0; 
    endcase
    case (d_i)
      // Input Read
      8'b01000010  : n_ior_o <= 1;
      default : n_ior_o <= 0; 
    endcase
    case (d_i)
      // Output Write
      8'b00010000  : n_iow_o <= 1;
      default : n_iow_o <= 0; 
    endcase
    case (d_i)
      // Interrupt Acknowledge
      8'b00100011  : n_inta_o <= 1;
      // Interrupt Acknowledge While Halt
      8'b00101011  : n_inta_o <= 1;
      default : n_inta_o <= 0; 
    endcase
end
     
endmodule
