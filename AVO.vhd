library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dc0112_pkg.all;

entity AVO is

   port( clk_i : in std_ulogic;
      clk24_i   : in  std_ulogic;
      A0_H_i    : in std_ulogic_vector(15 downto 0);
      DB_0_o    : out std_ulogic_vector(7 downto 0);
      LBA_i     : in std_ulogic_vector(7 downto 0);
      BV4_WRITE_LB_L_i : in std_ulogic;
      BV4_HOLD_REQ_H_i : in std_ulogic;
      BV4_CHAR_CLK_H_i : in std_ulogic;
      BV4_DMA_ENA_L_i : in std_ulogic;
      BV6_MEM_RD_L_i : in std_ulogic;
      BV6_MEM_WR_L_i : in std_ulogic;
      BV1_ADVANCED_VIDEO_L_o : out std_ulogic;
      BV1_MEM_DISABLE_L_o: out std_ulogic;
      BV2_SEL_ATT_RAM_L_i: in std_ulogic;   
      BV2_SEL_8_12K_L_i: in std_ulogic;
      BV1_ALT_CHAR_SEL_L_o: out std_ulogic;
      BV1_BLINK_L_o: out std_ulogic;
      BV1_BOLD_L_o: out std_ulogic;
      BV1_UNDERLINE_L_o: out std_ulogic;
      AVO_EN_PATCH_ROM_L_o: out std_ulogic;
      AVO_SW_E19_2_i: in std_ulogic;
      AVO_SW_E19_3_i: in std_ulogic;
      AVO_SW_E19_8_i: in std_ulogic;
      DEBUG: out  std_ulogic_vector(31 downto 0));

end AVO;

architecture rtl of AVO is

begin
   BV1_BLINK_L_o <= '1';
   BV1_BOLD_L_o <= '1';
   BV1_UNDERLINE_L_o <= '1';
   BV1_MEM_DISABLE_L_o <= '1';
   BV1_ALT_CHAR_SEL_L_o <= '1';
   BV1_ADVANCED_VIDEO_L_o <= '1';

   debug_proc: process(clk_i)
   begin
     if(rising_edge(clk_i)) then
        DEBUG(15 downto 0) <= A0_H_i;
	DEBUG(31 downto 16) <= (others => '0');
     end if;
   end process debug_proc;
    
end rtl;
