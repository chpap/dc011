library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dc0112_pkg.all;

entity BV3 is

   port( clk_i : in std_ulogic;
      clk24_i   : in  std_ulogic;
      A0_H_i    : in std_ulogic_vector(15 downto 0);
      DB_0_o    : out std_ulogic_vector(7 downto 0);
      DB_0_i    : in std_ulogic_vector(7 downto 0);
      DO_0_i    : in std_ulogic_vector(7 downto 0);
      LBA_i     : in std_ulogic_vector(7 downto 0);

      BV6_IO_WR_L_i: in std_ulogic;
      BV6_IO_RD_L_i: in std_ulogic;
      BV6_RESET_H_i: in std_ulogic;
      BV6_F2_TTL_i: in std_ulogic;
      BV3_XMIT_FLAG_H_o: out std_ulogic;
      BV3_REC_FLAG_H_o: out std_ulogic;
      BV2_WRITE_BAUD_H_i: in std_ulogic;
      BV3_OPTION_PRESENT_H_o: out std_ulogic;
      BV2_n_SPDS_i: in std_ulogic;
      BV2_MODEM_RD_L_i: in std_ulogic;
      DSR_i : in std_ulogic;
      DTR_o: out std_ulogic;
      RTS_o: out std_ulogic;
      TXD_o: out std_ulogic;
      SPD_SEL_o: out std_ulogic;
      RXD_i: in std_ulogic;
      CTS_i: in std_ulogic;
      SPDI_i: in std_ulogic;
      RI_i: in std_ulogic;
      DEBUG     : out std_ulogic_vector(31 downto 0));
end BV3;

architecture rtl of BV3 is

begin
debug_proc: process(clk_i)
begin
  if(rising_edge(clk_i)) then
    DEBUG(15 downto 0) <= A0_H_i;
    DEBUG(31 downto 16) <= (others => '0');
  end if;
end process debug_proc;
   BV3_OPTION_PRESENT_H_o <= '0';
   BV3_REC_FLAG_H_o <= '0';
   BV3_XMIT_FLAG_H_o <= '0';
    
end rtl;
