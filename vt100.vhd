library ieee;
use ieee.std_logic_unsigned.all;
use work.dc0112_pkg.all;
use work.vt100_pkg.all;

architecture rtl of vt100 is

  signal n_vid_wr: std_ulogic := '1';
  signal DO_0 :std_ulogic_vector(7 downto 0);
  signal DB_0: std_ulogic_vector(7 downto 0);
  signal A0_H :std_ulogic_vector(15 downto 0);

  signal LBA:   std_ulogic_vector (7 downto 0);
  signal dot_clock:   std_ulogic;
  signal char_clk:   std_ulogic;
  signal n_write_lb:   std_ulogic;
  signal vsr_ld:   std_ulogic;
  signal n_addr_ld:   std_ulogic;
  signal dw:   std_ulogic;
  signal hold_req:   std_ulogic;
  signal n_hdrive: std_ulogic;
  signal hblank : std_ulogic;
  signal vrst : std_ulogic;
  signal vdrive: std_ulogic;
  signal n_vblank : std_ulogic;
  signal comp_sync: std_ulogic;
  signal addr_count: std_ulogic;

  signal data:  std_ulogic_vector(3 downto 0);
  signal n_vid_w2:  std_ulogic;
  signal vf_intr:   std_ulogic;
  signal revvid:  std_ulogic;
  signal d_h:   std_ulogic;
  signal d_l:   std_ulogic;
  signal scan_cnt:  std_ulogic_vector(3 downto 0);
  signal vid1out:  std_ulogic;
  signal vid2out:  std_ulogic;
  signal term: std_ulogic;
  signal n_underline: std_ulogic;
  signal n_blink: std_ulogic;
  signal n_bold: std_ulogic;
  signal vid_in: std_ulogic;
  signal rxd0: std_ulogic;

  signal n_wr_o: std_ulogic;

  signal clk_f1: std_ulogic;
  signal clk_f2: std_ulogic;
  signal BV1_BLINK_L : std_ulogic;
  signal BV1_UNDERLINE_L : std_ulogic;
  signal BV1_BOLD_L : std_ulogic;
  signal BV1_ALT_CHAR_SEL_L : std_ulogic := '0';
  signal BV6_RESET_L  : std_ulogic;
  signal BV6_IO_RD_L : std_ulogic;
  signal BV6_IO_WR_L : std_ulogic;
  signal BV6_MEM_WR_L: std_ulogic;
  signal BV6_MEM_RD_L: std_ulogic;
  signal BV6_HLDA_H: std_ulogic;
  signal BV1_MEM_DISABLE_L: std_ulogic := '1';
  signal BV2_NVR_DATA_H: std_ulogic;
  signal BV2_KBD_RD_L: std_ulogic;
  signal BV2_FLAG_RD_L: std_ulogic;
  signal BV2_MODEM_RD_L: std_ulogic;
  signal BV2_GRAPHIC_WR_L: std_ulogic;
  signal BV1_GRAPHIC_1_IN_L: std_ulogic;
  signal BV1_GRAPHIC_2_IN_L: std_ulogic;
  signal BV2_VID_WR_1L: std_ulogic;
  signal BV2_VID_WR_2L: std_ulogic;
  signal BV2_NVR_WR_L: std_ulogic;
  signal BV2_DA_WR_L: std_ulogic;
  signal BV2_WRITE_BAUD_H: std_ulogic;
  signal BV2_SEL_8_12K_L: std_ulogic;
  signal BV2_SEL_ATT_RAM_L: std_ulogic;
  signal BV2_KBD_WR_L: std_ulogic := '0';
  signal BV3_XMIT_FLAG_H: std_ulogic := '0';
  signal BV3_REC_FLAG_H: std_ulogic := '0';
  signal BV3_OPTION_PRESENT_H: std_ulogic := '0';
  signal BV4_T_HOLD_REQ_H: std_ulogic;
  signal BV4_HS_CLK_H: std_ulogic;
  signal BV4_SC_H : std_ulogic_vector(4 downto 0);
  signal BV4_WRITE_LB_L : std_ulogic;
  signal BV4_HOLD_REQ_H : std_ulogic;
  signal BV4_CHAR_CLK_H : std_ulogic;
  signal BV4_ADDR_LD_L : std_ulogic;
  signal BV4_ADDR_CNT_H : std_ulogic;
  signal BV4_DMA_ENA_L : std_ulogic;
  signal BV4_DOT_CLK_H: std_ulogic;
  signal BV4_VSR_LOAD_H: std_ulogic;
  signal BV4_HORIZ_DRIVE_H: std_ulogic;
  signal BV4_VERT_DRIVE_L: std_ulogic;
  signal BV5_SERIAL_VIDEO_H: std_ulogic;
  signal BV4_HORIZ_BLK_H: std_ulogic;
  signal BV4_VERT_BLANK_L: std_ulogic;
  signal BV4_VERT_RESET_H: std_ulogic;
  signal BV4_COMP_SYNC_L: std_ulogic;
  signal BV4_INIT_H: std_ulogic;
  signal BV4_EVEN_FIELD_L: std_ulogic;
  signal BV4_VERT_FREQ_INT_L: std_ulogic;
  signal BV4_VIDEO_OUT_1_H: std_ulogic;
  signal BV4_VIDEO_OUT_2_H: std_ulogic;
  signal BV5_RV_H_o:  std_ulogic;
  signal BV5_TERM_L:  std_ulogic;
  signal BV5_DW_H: std_ulogic;
  signal BV5_DV_H: std_ulogic;
  signal BV5_DH_H: std_ulogic;
  signal BV6_KBD_DATA_AVAIL_H: std_ulogic := '0';
  signal debug_bv5: std_ulogic_vector(31 downto 0);
  signal debug_bv6: std_ulogic_vector(31 downto 0);

begin

   BV2_INST: BV2 port map (
      clk_i => clk100_i,
      clk24_i => clk24_88_i,
      DO_0_i  => DO_0,
      DB_0_o  => DB_0,
      A0_H_i  => A0_H,
      LBA_i => LBA,
      BV6_RESET_L_i => BV6_RESET_L  ,
      BV2_NVR_WR_L_i => BV2_NVR_WR_L  ,
      BV6_IO_RD_L_i => BV6_IO_RD_L ,
      BV6_IO_WR_L_i => BV6_IO_WR_L ,
      BV6_MEM_WR_L_i => BV6_MEM_WR_L,
      BV6_MEM_RD_L_i => BV6_MEM_RD_L,
      BV1_MEM_DISABLE_L_i => BV1_MEM_DISABLE_L,
      BV2_n_SPDS_o   => open,
      BV2_NVR_DATA_H_o => BV2_NVR_DATA_H,
      BV2_KBD_RD_L_o => BV2_KBD_RD_L,
      BV2_FLAG_RD_L_o => BV2_FLAG_RD_L,
      BV2_MODEM_RD_L_o => BV2_MODEM_RD_L,
      BV2_GRAPHIC_WR_L_o => BV2_GRAPHIC_WR_L,
      BV2_VID_WR_1L_o => BV2_VID_WR_1L,
      BV2_VID_WR_2L_o => BV2_VID_WR_2L,
      BV2_NVR_WR_L_o => BV2_NVR_WR_L,
      BV2_DA_WR_L_o => BV2_DA_WR_L,
      BV2_WRITE_BAUD_H_o => BV2_WRITE_BAUD_H,
      BV2_SEL_8_12K_L_o => BV2_SEL_8_12K_L,
      BV2_SEL_ATT_RAM_L_o => BV2_SEL_ATT_RAM_L
      );

   BV4_INST :BV4 port map( 
      clk_i => clk100_i,
      clk24_i => clk24_07_i,
      DO_0_i => DO_0,
      LBA_o => LBA,
      BV4_COMP_SYNC_L_o => BV4_COMP_SYNC_L,
      BV1_GRAPHIC_1_IN_L_i => BV1_GRAPHIC_1_IN_L,
      BV4_VERT_BLANK_L_o => BV4_VERT_BLANK_L,
      BV1_GRAPHIC_2_IN_L_i => BV1_GRAPHIC_2_IN_L,
      BV2_DA_WR_L_i => BV2_DA_WR_L,
      BV4_INIT_H_o => BV4_INIT_H,
      BV4_HOLD_REQ_H_i => BV4_HOLD_REQ_H,
      BV4_T_HOLD_REQ_H_o => BV4_T_HOLD_REQ_H,
      BV4_HS_CLK_H_o => BV4_HS_CLK_H,
      BV6_HLDA_H_i => BV6_HLDA_H,
      BV4_DMA_ENA_H_o => open,
      BV4_DMA_ENA_L_o => BV4_DMA_ENA_L,
      BV5_DW_L_i => not BV5_DW_H,
      BV5_DH_L_i => not BV5_DH_H,
      BV5_TERM_L_i => BV5_TERM_L,
      BV5_SERIAL_VIDEO_H_i => BV5_SERIAL_VIDEO_H,
      BV1_BLINK_L_i => BV1_BLINK_L,
      BV1_UNDERLINE_L_i => BV1_UNDERLINE_L,
      BV1_BOLD_L_i => BV1_BOLD_L,
      BV2_VID_WR_1_L_i => BV2_VID_WR_1L,
      BV4_HORIZ_BLK_H_o => BV4_HORIZ_BLK_H,
      BV4_VERT_RESET_H_o => BV4_VERT_RESET_H,
      BV4_CHAR_CLK_H_o => BV4_CHAR_CLK_H,
      BV4_ADDR_LD_L_o => BV4_ADDR_LD_L,
      BV4_DOT_CLK_H_o => BV4_DOT_CLK_H,
      BV4_ADDR_CNT_H_o => BV4_ADDR_CNT_H,
      BV4_VSR_LOAD_H_o => BV4_VSR_LOAD_H,
      BV4_WRITE_LB_L_o => BV4_WRITE_LB_L,
      BV4_HORIZ_DRIVE_H_o => BV4_HORIZ_DRIVE_H,
      BV4_VERT_DRIVE_L_o => BV4_VERT_DRIVE_L,
      BV4_EVEN_FIELD_L_o => BV4_EVEN_FIELD_L,
      BV4_VERT_FREQ_INT_L_o => BV4_VERT_FREQ_INT_L,
      BV4_SC_H_o => BV4_SC_H,
      BV4_VIDEO_OUT_1_H_o => BV4_VIDEO_OUT_1_H,
      BV4_VIDEO_OUT_2_H_o => BV4_VIDEO_OUT_2_H);

   BV5_INST: BV5 port map (
      clk_i => clk100_i,
      clk24_i => clk24_07_i,
      DO_0_i  => DO_0,
      A0_H_o => open,
      LBA_i => LBA,
      BV4_SC_H_i  =>  BV4_SC_H ,
      BV4_WRITE_LB_L_i  => BV4_WRITE_LB_L ,
      BV4_HOLD_REQ_H_i  => BV4_HOLD_REQ_H ,
      BV4_CHAR_CLK_H_i  => BV4_CHAR_CLK_H ,
      BV4_ADDR_LD_L_i  =>  BV4_ADDR_LD_L ,
      BV4_ADDR_CNT_H_i  => BV4_ADDR_CNT_H ,
      BV4_DMA_ENA_L_i  =>  BV4_DMA_ENA_L ,
      BV1_ALT_CHAR_SEL_L_i  =>  BV1_ALT_CHAR_SEL_L ,
      BV4_DOT_CLK_H_i => BV4_DOT_CLK_H,
      BV4_VSR_LOAD_H_i =>  BV4_VSR_LOAD_H,
      BV5_SERIAL_VIDEO_H_o => BV5_SERIAL_VIDEO_H,
      BV4_HORIZ_BLK_H_i => BV4_HORIZ_BLK_H,
      BV4_VERT_RESET_H_i => BV4_VERT_RESET_H,
      BV5_RV_H_o => BV5_RV_H_o,
      BV5_DV_H_o => BV5_DV_H,
      BV5_DW_H_o => BV5_DW_H,
      BV5_TERM_L_o => BV5_TERM_L,
      DEBUG => debug_bv5
      );

   BV6_INST: BV6 port map( 
      clk_i => clk100_i,
      clk24_i => clk24_88_i,
      n_reset_i => not reset_i,
      A0_H_o => A0_H,
      DB_0_i => DB_0,
      DO_0_o => DO_0,
      LBA_i => LBA,
      BV6_INTR_H_i => '0',
      BV6_HLDA_H_o => BV6_HLDA_H,
      BV4_T_HOLD_REQ_H_i => BV4_T_HOLD_REQ_H,
      BV3_XMIT_FLAG_H_i => BV3_XMIT_FLAG_H,
      BV3_REC_FLAG_H_i => BV3_REC_FLAG_H,
      BV6_KBD_DATA_AVAIL_H_i => BV6_KBD_DATA_AVAIL_H,
      BV2_KBD_WR_L_i => BV2_KBD_WR_L,
      BV4_EVEN_FIELD_L_i => BV4_EVEN_FIELD_L,
      BV3_OPTION_PRESENT_H_i => BV3_OPTION_PRESENT_H,
      BV2_NVR_DATA_H_i => BV2_NVR_DATA_H,
      BV2_FLAG_RD_L_i => BV2_FLAG_RD_L,
      BV6_MEM_RD_L_o => BV6_MEM_RD_L,
      BV6_MEM_WR_L_o => BV6_MEM_WR_L,
      DEBUG => debug_bv6
     );
   led_o(0) <= not BV4_CHAR_CLK_H;
   --led_o(0) <= not BV4_VERT_RESET_H;
   --led_o(1) <= A0_H(3);
   --led_o(7 downto 1) <= debug(7 downto 1);
   --debug_o(15 downto 8) <= DO_0;
   --debug_o(7 downto 0) <= DB_0;
   --debug_o(31 downto 16)<= A0_H;
   debug_o(15 downto 0) <= debug_bv5(15 downto 0);
   debug_o(31 downto 16) <= debug_bv6(15 downto 0);
   videor_o <= (others => '0');
   videog_o <= (others => '0');
   videob_o <= (others => '0');
   hsync_o <= '0';
   vsync_o <= '0';
   rxd0 <= rxd0_i;
   txd0_o <= '0';
end;
