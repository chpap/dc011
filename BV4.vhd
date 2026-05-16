library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dc0112_pkg.all;

entity BV4 is
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
      BV4_VIDEO_OUT_2_H_o: out std_ulogic
      );

end BV4;
architecture rtl of BV4 is
     signal LBA: std_ulogic_vector(7 downto 0);
     signal BV4_HORIZ_DRIVE_L: std_ulogic;
     signal BV4_VERT_DRIVE_H: std_ulogic;
     signal DW: std_ulogic;
begin
  DC011_INT: dc011 port map(
     clk24_i => clk24_i,
     n_rst_i => '1',
     d0_i => DO_0_i(4),
     d1_i => DO_0_i(5),
     n_vid_wr_i => BV2_VID_WR_1_L_i,
     dw_i => DW,
     hold_req_i => BV4_HOLD_REQ_H_i,
     LBA_o => LBA_o,
     dot_clock_o => BV4_DOT_CLK_H_o,
     char_clk_o => BV4_CHAR_CLK_H_o,
     n_write_lb => BV4_WRITE_LB_L_o,
     vsr_ld => BV4_VSR_LOAD_H_o,
     n_addr_ld => BV4_ADDR_LD_L_o,
     n_hdrive => BV4_HORIZ_DRIVE_L,
     hblank  => BV4_HORIZ_BLK_H_o,
     vrst  => BV4_VERT_RESET_H_o,
     vdrive => BV4_VERT_DRIVE_H,
     n_vblank  => BV4_VERT_BLANK_L_o,
     comp_sync => BV4_COMP_SYNC_L_o,
     addr_count => BV4_ADDR_CNT_H_o
    );
    
    D_FF_1: D_FF
      port map(
       n_clk_i => not BV4_VERT_DRIVE_H,
       D => BV4_HORIZ_DRIVE_L,
       Q => BV4_EVEN_FIELD_L_o
      );
    BV4_VERT_DRIVE_L_o <= not BV4_VERT_DRIVE_H;
    DW <= BV5_DW_L_i nand BV5_DH_L_i;
end rtl;
