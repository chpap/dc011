library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dc0112_pkg.all;

entity BV2 is

   port( clk_i : in std_ulogic;
      clk24_i    : in  std_ulogic;
      DO_0_i     : in std_ulogic_vector(7 downto 0);
      DB_0_i     : in std_ulogic_vector(7 downto 0);
      DB_0_o     : in std_ulogic_vector(7 downto 0);
      A0_H_i : in std_ulogic_vector(14 downto 0);
      BV6_RESET_L_i  : in std_ulogic;
      BV2_NVR_WR_L_i  : in std_ulogic;
      BV6_IO_RD_L_i : in std_ulogic;
      BV6_IO_WR_L_i : in std_ulogic;
      BV6_MEM_WR_L_i: in std_ulogic;
      BV6_MEM_RD_L_i: in std_ulogic;
      BV1_MEM_DISABLE_L_i: in std_ulogic;
      n_BV2_SPDS_o  : out  std_ulogic;
      BV2_NVR_DATA_H_o: out  std_ulogic;
      BV2_KBD_RD_L_o: out std_ulogic;
      BV2_FLAG_RD_L_o: out std_ulogic;
      BV2_MODEM_RD_L_o: out std_ulogic;
      BV2_GRAPHIC_WR_L_o: out std_ulogic;
      BV2_VID_WR_1L_o: out std_ulogic;
      BV2_VID_WR_2L_o: out std_ulogic;
      BV2_NVR_WR_L_o: out std_ulogic;
      BV2_DA_WR_L_o: out std_ulogic;
      BV2_WRITE_BAUD_H_o: out std_ulogic;
      BV2_SEL_8_12K_H_o: out std_ulogic;
      BV2_SEL_ATT_RAM_L_o: out std_ulogic);


end BV2;
architecture rtl of BV2 is
	signal A0_H: std_ulogic_vector(14 downto 0);
	signal DO_0: std_ulogic_vector(7 downto 0);
begin
  A0_H <= A0_H_i;
  DO_0 <= DO_0_i;
    
  SRAM_INST: sram port map (
      addr_i => A0_H(9 downto 0),
      clk => clk_i,
      data_i => DO_0,
      wren_i => '1',
      data_o => open
	);
end rtl;
