library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dc0112_pkg.all;

entity BV5 is

   port( clk_i : in std_ulogic;
      clk24_i   : in  std_ulogic;
      A0_H_o    : out std_ulogic_vector(14 downto 0);
      DO_0_i    : in std_ulogic_vector(7 downto 0);
      LBA_i     : in std_ulogic_vector(7 downto 0);
      BV4_SC_H_i : in std_ulogic_vector(4 downto 0);
      BV4_WRITE_LB_L_i : in std_ulogic;
      BV4_HOLD_REQ_H_i : in std_ulogic;
      BV4_CHAR_CLK_H_i : in std_ulogic;
      BV4_ADDR_LD_L_i : in std_ulogic;
      BV4_ADDR_CNT_H_i : in std_ulogic;
      BV4_DMA_ENA_L_i : in std_ulogic;
      BV1_ALT_CHAR_SEL_L_i : in std_ulogic;
      BV4_DOT_CLK_H_i: in std_ulogic;
      BV4_VSR_LOAD_H_i: in std_ulogic;
      BV5_SERIAL_VIDEO_H_o: out std_ulogic;
      BV4_HORIZ_BLK_H_i: in std_ulogic;
      BV4_VERT_RESET_H_i: in std_ulogic;
      BV5_RV_H_o: out  std_ulogic;
      BV5_DV_H_o: out  std_ulogic;
      BV5_DW_H_o: out  std_ulogic;
      BV5_TERM_L_o: out  std_ulogic
      );


end BV5;
architecture rtl of BV5 is
	signal A0_H: std_ulogic_vector(14 downto 0);
	signal DO_0: std_ulogic_vector(7 downto 0);
begin
  A0_H_o <= A0_H;
  DO_0 <= DO_0_i;
    
end rtl;
