library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
package vt100_pkg is
constant BOOTROM_DEPTH: positive :=  8192;
constant FONTROM_DEPTH: positive :=  8192;

type bootrom_type is array (0 to BOOTROM_DEPTH - 1)
  of std_logic_vector(7 downto 0);
impure function init_bootrom_hex(romfilename : in string) return bootrom_type; 
type fontrom_type is array (0 to FONTROM_DEPTH - 1)
  of std_logic_vector(7 downto 0);
impure function init_fontrom_hex(romfilename : in string) return fontrom_type; 

   component decod_component is
    port(
        clk        : in  std_logic; -- Clock signal
        A, B, C, D : in  std_logic_vector(3 downto 0); -- Input digits (4-bit each)
        E, F, G, H : in  std_logic_vector(3 downto 0); -- Input digits (4-bit each)
        sel_display: out std_logic_vector(7 downto 0); -- Output to select the display
        segment    : out std_logic_vector(7 downto 0)  -- Output to drive the 7-segment display
    );
   end component;
   component BV2 is
   port( clk_i : in std_ulogic;
      clk24_i    : in  std_ulogic;
      DO_0_i     : in std_ulogic_vector(7 downto 0);
      DB_0_o     : out std_ulogic_vector(7 downto 0);
      LBA_i     : in std_ulogic_vector(7 downto 0);
      A0_H_i : in std_ulogic_vector(15 downto 0);
      BV6_RESET_L_i  : in std_ulogic;
      BV2_NVR_WR_L_i  : in std_ulogic;
      BV6_IO_RD_L_i : in std_ulogic;
      BV6_IO_WR_L_i : in std_ulogic;
      BV6_MEM_WR_L_i: in std_ulogic;
      BV6_MEM_RD_L_i: in std_ulogic;
      BV1_MEM_DISABLE_L_i: in std_ulogic;
      BV2_n_SPDS_o  : out  std_ulogic;
      BV2_NVR_DATA_H_o: out  std_ulogic;
      BV2_KBD_RD_L_o: out std_ulogic;
      BV2_KBD_WR_L_o: out std_ulogic;
      BV2_FLAG_RD_L_o: out std_ulogic;
      BV2_MODEM_RD_L_o: out std_ulogic;
      BV2_GRAPHIC_WR_L_o: out std_ulogic;
      BV2_VID_WR_1L_o: out std_ulogic;
      BV2_VID_WR_2L_o: out std_ulogic;
      BV2_NVR_WR_L_o: out std_ulogic;
      BV2_DA_WR_L_o: out std_ulogic;
      BV2_WRITE_BAUD_H_o: out std_ulogic;
      BV2_SEL_8_12K_L_o: out std_ulogic;
      BV2_SEL_ATT_RAM_L_o: out std_ulogic);
   end component;
   component BV4 is
   port( clk_i : in std_ulogic;
      clk24_i   : in  std_ulogic;
      DO_0_i    : in std_ulogic_vector(7 downto 0);
      LBA_o     : out std_ulogic_vector(7 downto 0);
      BV4_COMP_SYNC_L_o : out std_ulogic;
      BV1_GRAPHIC_1_IN_L_i : in std_ulogic;
      BV4_VERT_BLANK_L_o : out std_ulogic;
      BV1_GRAPHIC_2_IN_L_i : in std_ulogic;
      BV2_DA_WR_L_i : in std_ulogic;
      BV4_INIT_H_o : out std_ulogic;
      BV4_HOLD_REQ_H_i : in std_ulogic;
      BV4_T_HOLD_REQ_H_o : out std_ulogic;
      BV4_HS_CLK_H_o : out std_ulogic;
      BV6_HLDA_H_i : in std_ulogic;
      BV4_DMA_ENA_H_o : out std_ulogic;
      BV4_DMA_ENA_L_o : out std_ulogic;
      BV5_DW_L_i: in  std_ulogic;
      BV5_DH_L_i: in  std_ulogic;
      BV5_TERM_L_i: in  std_ulogic;
      BV5_SERIAL_VIDEO_H_i: in  std_ulogic;
      BV1_BLINK_L_i : in std_ulogic;
      BV1_UNDERLINE_L_i : in std_ulogic;
      BV1_BOLD_L_i : in std_ulogic;
      BV2_VID_WR_1_L_i : in std_ulogic;
      BV4_HORIZ_BLK_H_o: out std_ulogic;
      BV4_VERT_RESET_H_o: out std_ulogic;
      BV4_CHAR_CLK_H_o : out std_ulogic;
      BV4_ADDR_LD_L_o : out std_ulogic;
      BV4_DOT_CLK_H_o: out std_ulogic;
      BV4_ADDR_CNT_H_o : out std_ulogic;
      BV4_VSR_LOAD_H_o: out std_ulogic;
      BV4_WRITE_LB_L_o : out std_ulogic;
      BV4_HORIZ_DRIVE_H_o : out std_ulogic;
      BV4_VERT_DRIVE_L_o : out std_ulogic;
      BV4_EVEN_FIELD_L_o : out std_ulogic;
      BV4_VERT_FREQ_INT_L_o : out std_ulogic;
      BV4_SC_H_o : out std_ulogic_vector(4 downto 0);
      BV4_VIDEO_OUT_1_H_o: out std_ulogic;
      BV4_VIDEO_OUT_2_H_o: out std_ulogic);
   end component;
   component BV5 is
   port( clk_i : in std_ulogic;
      clk24_i   : in  std_ulogic;
      A0_H_o    : out std_ulogic_vector(15 downto 0);
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
      BV5_TERM_L_o: out  std_ulogic;
      DEBUG: out std_ulogic_vector(31 downto 0)
      );
   end component;
   component BV6 is
   port( clk_i : in std_logic;
      clk24_i    : in  std_logic;
      n_reset_i : in std_logic;
      A0_H_o   : out std_logic_vector(15 downto 0);
      DB_0_i   : in std_logic_vector(7 downto 0);
      DO_0_o  : out std_ulogic_vector(7 downto 0);
      LBA_i  : in std_ulogic_vector(7 downto 0);
      BV6_HLDA_H_o  : out std_ulogic;
      BV6_RESET_H_o  :out std_logic;
      BV6_INTR_H_i : in std_ulogic;
      BV4_T_HOLD_REQ_H_i : in std_ulogic;
      BV6_INTA_L_o: out std_ulogic;
      BV6_IO_WR_L_o: out std_ulogic;
      BV6_IO_RD_L_o: out std_ulogic;
      BV6_MEM_WR_L_o: out std_ulogic;
      BV6_MEM_RD_L_o: out std_ulogic;
      BV3_XMIT_FLAG_H_i : in std_ulogic;
      BV3_REC_FLAG_H_i : in std_ulogic;
      BV6_KBD_DATA_AVAIL_H_i: in std_ulogic;
      BV2_KBD_WR_L_i: in std_ulogic;
      BV4_EVEN_FIELD_L_i: in std_ulogic;
      BV3_OPTION_PRESENT_H_i: in std_ulogic;
      BV2_NVR_DATA_H_i: in std_ulogic;
      BV2_FLAG_RD_L_i: in std_ulogic;
      DEBUG: out std_ulogic_vector(7 downto 0));
   end component;

end package vt100_pkg;
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

package body vt100_pkg is

impure function init_bootrom_hex(romfilename : in string) return bootrom_type is
  file text_file : text open read_mode is romfilename;
  variable text_line  : line;
  -- variable temp     : std_logic_vector((div_ceil(word_t'length, 4) * 4) - 1 downto 0);
  variable rom_content       : bootrom_type    := (others => (others => '0'));
begin
  for i in 0 to BOOTROM_DEPTH - 1 loop
     exit when endfile(text_file);
     readline(text_file, text_line);
     hread(text_line, rom_content(i));     
     -- rom_content(i) := resize(temp, word_t'length);
  end loop;
  
  return rom_content;
end function;
------------------------------------------------------------------------
impure function init_fontrom_hex(romfilename : in string) return fontrom_type is
  file text_file : text open read_mode is romfilename;
  variable text_line  : line;
  -- variable temp     : std_logic_vector((div_ceil(word_t'length, 4) * 4) - 1 downto 0);
  variable rom_content       : fontrom_type    := (others => (others => '0'));
begin
  for i in 0 to FONTROM_DEPTH - 1 loop
     exit when endfile(text_file);
     readline(text_file, text_line);
     hread(text_line, rom_content(i));     
     -- rom_content(i) := resize(temp, word_t'length);
  end loop;
  
  return rom_content;
end function;

end package body vt100_pkg;
