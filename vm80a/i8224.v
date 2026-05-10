module i8224(
    input           sync_i,
    input           n_resin_i,
    input           rdyin_i,
    input           clk_i,
    output reg      clk_f1_o = 0,
    output reg      clk_f2_o = 0,
    output          n_stsb_o,
    output reg      reset_o = 0,
    output reg      ready_o = 0);

    reg [3:0] counter = 0;
    wire clk_f1_a; 
    wire clk_f2_d;

    //assign clk_f1_o  = ($countones(counter[3:1]) == 0);
    //assign clk_f2_o  = ~counter[3] & ~ clk_f1_o & ~ ($countones(counter[2:0]) == 3);
    assign clk_f1_a = clk_f1_o | counter[3];
    assign clk_f2_d = clk_f2_o & ~(counter == 4'b0010) ;
    assign n_stsb_o = ~((sync_i & clk_f1_a) | reset_o);


always @(posedge clk_i) begin
    case (counter)
      0  : clk_f1_o <= 1;
      8  : clk_f1_o <= 1;
      default : clk_f1_o <= 0; 
    endcase
    case (counter)
      1  : clk_f2_o <= 1;
      2  : clk_f2_o <= 1;
      3  : clk_f2_o <= 1;
      4  : clk_f2_o <= 1;
      5  : clk_f2_o <= 1;
      default : clk_f2_o <= 0; 
    endcase
    if (counter == 8)
      counter <= 4'd0;
    else
      counter <= counter + 1'b1;
end
    

always @(posedge clk_f2_d)
begin
 reset_o <= ~n_resin_i;
 ready_o <= rdyin_i;
end

endmodule
