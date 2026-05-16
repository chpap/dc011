`timescale 1ps/1ps
module PLLE2_ADV_WRAPPER #(

	/* not implemented */
	parameter BANDWIDTH 			= "OPTIMIZED",

	parameter CLKFBOUT_MULT 		= 5,
	parameter CLKFBOUT_PHASE 		= 0.0,

	/* are ignored, but need to be set */
	parameter CLKIN1_PERIOD			= 0.0,
	parameter CLKIN2_PERIOD			= 0.0,

	parameter CLKOUT0_DIVIDE		= 1,
	parameter CLKOUT1_DIVIDE		= 1,
	parameter CLKOUT2_DIVIDE		= 1,
	parameter CLKOUT3_DIVIDE		= 1,
	parameter CLKOUT4_DIVIDE		= 1,
	parameter CLKOUT5_DIVIDE		= 1,

	parameter CLKOUT0_DUTY_CYCLE	= 0.5,
	parameter CLKOUT1_DUTY_CYCLE	= 0.5,
	parameter CLKOUT2_DUTY_CYCLE	= 0.5,
	parameter CLKOUT3_DUTY_CYCLE	= 0.5,
	parameter CLKOUT4_DUTY_CYCLE	= 0.5,
	parameter CLKOUT5_DUTY_CYCLE	= 0.5,

	parameter CLKOUT0_PHASE			= 0.0,
	parameter CLKOUT1_PHASE			= 0.0,
	parameter CLKOUT2_PHASE			= 0.0,
	parameter CLKOUT3_PHASE			= 0.0,
	parameter CLKOUT4_PHASE			= 0.0,
	parameter CLKOUT5_PHASE			= 0.0,

	parameter DIVCLK_DIVIDE			= 1,

	/* not implemented */
	parameter REF_JITTER1			= 0.010,
	parameter REF_JITTER2			= 0.010,
	parameter STARTUP_WAIT			= "FALSE",
	parameter COMPENSATION			= "ZHOLD",

	/* Setting the FPGA model and speed grade allows a more realistic
	 * simulation. Default values are the most restrictive */
	parameter FPGA_TYPE				= "ARTIX",
	parameter SPEED_GRADE 			= "-1")(
	output 	CLKOUT0,
	output 	CLKOUT1,
	output 	CLKOUT2,
	output 	CLKOUT3,
	output 	CLKOUT4,
	output 	CLKOUT5,
	/* PLL feedback output. */
	input 	CLKFBIN,
	output 	CLKFBOUT,

	output	LOCKED,
	input 	CLKIN1,
	input 	CLKIN2,
	/* Select input clk. 1 for CLKIN1, 0 for CLKIN2 */
	input 	CLKINSEL);


  wire        clk_out0_unbuffered;
  wire        clk_out1_unbuffered;
  wire        clk_out2_unbuffered;
  wire        clk_out3_unbuffered;
  wire clkfbout;

  PLLE2_ADV
  #(.BANDWIDTH            ("OPTIMIZED"),
    .COMPENSATION         ("INTERNAL"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT        (8), // 100 MHz * 8 = 800 MHz
    .CLKFBOUT_PHASE       (0.000),
    .CLKOUT0_DIVIDE       (8), // 800 MHz / 10 = 100 MHz
    .CLKOUT1_DIVIDE       (32), //25
    .CLKOUT2_DIVIDE       (33), // 24.24
    .CLKOUT3_DIVIDE       (128), //6.25
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKIN1_PERIOD        (10.000) // 100 MHz input
  )
  plle2_adv_inst
   (
    .CLKFBOUT            (clkfbout),
    .CLKOUT0             (clk_out0_unbuffered),
    .CLKOUT1             (clk_out1_unbuffered),
    .CLKOUT2             (clk_out2_unbuffered),
    .CLKOUT3             (clk_out3_unbuffered),
    .CLKFBIN             (clkfbout),
    .CLKIN1              (clk_in1),
    .LOCKED              (locked),
    .RST                 (reset)
  );
  assign clkou0_buf = clk_out0_unbuffered;
  assign clkou1_buf = clk_out1_unbuffered;
  assign clkou2_buf = clk_out2_unbuffered;
  assign clkou3_buf = clk_out3_unbuffered;
//  BUFG clkout0_buf
//   (.O   (CLKOUT0),
//    .I   (clk_out0_unbuffered));
//  BUFG clkout1_buf
//   (.O   (CLKOUT1),
//    .I   (clk_out1_unbuffered));
//  BUFG clkout2_buf
//   (.O   (CLKOUT2),
//    .I   (clk_out2_unbuffered));
//  BUFG clkout3_buf
//   (.O   (CLKOUT3),
//    .I   (clk_out3_unbuffered));
endmodule
