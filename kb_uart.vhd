library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dc0112_pkg.all;

entity kb_uart is

   port( clk_i : in std_ulogic;
      DB_0_o    : out std_ulogic_vector(7 downto 0);
      DO_0_i    : in std_ulogic_vector(7 downto 0);
      LBA_i     : in std_ulogic_vector(7 downto 0);

      BV2_KBD_RD_L_i: in std_ulogic;
      BV2_KBD_WR_L_i: in std_ulogic;
      BV6_RESET_H_i : in std_ulogic;
      BV6_KBD_TBMT_H_o : out std_ulogic;
      BV6_KBD_DATA_AVAIL_H_o : out std_ulogic;
      ps2_clk	: inout std_ulogic;
      ps2_data  : inout std_ulogic;
      DEBUG     : out std_ulogic_vector(31 downto 0));
end kb_uart;

architecture rtl of kb_uart is

begin
     BV6_KBD_TBMT_H_o <= '0';
     BV6_KBD_DATA_AVAIL_H_o <= '0';
debug_proc: process(clk_i)
begin
  if(rising_edge(clk_i)) then
    DEBUG(7 downto 0) <= DO_0_i;
    DEBUG(31 downto 8) <= (others => '0');
  end if;
end process debug_proc;
    
end rtl;
