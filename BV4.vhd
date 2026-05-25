library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity AD_LUT_32x10 is
	port (address : in  std_ulogic_vector (4 downto 0); 
-- switch position where on = 0
	      data_out: out std_ulogic_vector (9 downto 0)  -- 10-bit quantized headroom voltage
      );
end AD_LUT_32x10;
architecture rtl of AD_LUT_32x10 is
begin
process(address)
begin
	case address is
		when "00000" => data_out <= "0000000000"; -- 0.000 V (index 31 original table)
		when "00001" => data_out <= "0000001011"; -- 0.045 V
		when "00010" => data_out <= "0000010111"; -- 0.091 V
		when "00011" => data_out <= "0000100011"; -- 0.139 V
		when "00100" => data_out <= "0000111011"; -- 0.189 V
		when "00101" => data_out <= "0001001100"; -- 0.242 V
		when "00110" => data_out <= "0001011010"; -- 0.297 V
		when "00111" => data_out <= "0010010010"; -- 0.355 V
		when "01000" => data_out <= "0010100110"; -- 0.415 V
		when "01001" => data_out <= "0100011110"; -- 0.479 V
		when "01010" => data_out <= "0100010010"; -- 0.546 V
		when "01011" => data_out <= "0101001101"; -- 0.616 V
		when "01100" => data_out <= "0101010111"; -- 0.691 V
		when "01101" => data_out <= "0111000000"; -- 0.769 V
		when "01110" => data_out <= "0111010101"; -- 0.852 V
		when "01111" => data_out <= "0111101011"; -- 0.940 V
		when "10000" => data_out <= "1000111110"; -- 1.147 V (index 15 original table)
		when "10001" => data_out <= "1001110010"; -- 1.253 V
		when "10010" => data_out <= "1010101011"; -- 1.367 V
		when "10011" => data_out <= "1011101010"; -- 1.489 V
		when "10100" => data_out <= "1100101011"; -- 1.620 V
		when "10101" => data_out <= "1101101101"; -- 1.760 V
		when "10110" => data_out <= "1110110111"; -- 1.911 V
		when "10111" => data_out <= "1000000101"; -- 2.075 V
		when "11000" => data_out <= "1000110010"; -- 2.253 V
		when "11001" => data_out <= "1001100110"; -- 2.446 V
		when "11010" => data_out <= "1010011001"; -- 2.657 V
		when "11011" => data_out <= "1011010010"; -- 2.889 V
		when "11100" => data_out <= "1100010011"; -- 3.144 V
		when "11101" => data_out <= "1101011001"; -- 3.427 V
		when "11110" => data_out <= "1110101000"; -- 3.743 V
		when "11111" => data_out <= "1111111111"; -- 4.096 V (index 0 original table)
		when others  => data_out <= (others => '0');
	end case;
end process;
end rtl;


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
      BV4_HOLD_REQ_H_o : out std_ulogic;
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
      BV2_VID_WR_1L_i : in std_ulogic;
      BV2_VID_WR_2L_i : in std_ulogic;
      BV4_HORIZ_BLK_H_o: out std_ulogic;
      BV4_VERT_RESET_H_o: out std_ulogic;
      BV4_CHAR_CLK_H_o : out std_ulogic;
      BV4_ADDR_LD_L_o : out std_ulogic;
      BV4_DOT_CLK_H_o: out std_ulogic;
      BV4_ADDR_CNT_H_o : out std_ulogic;
      BV4_VSR_LOAD_H_o: out std_ulogic;
      BV4_WRITE_LB_L_o : out std_ulogic;
      BV4_HORIZ_DRIVE_L_o : out std_ulogic;
      BV4_VERT_DRIVE_L_o : out std_ulogic;
      BV4_EVEN_FIELD_L_o : out std_ulogic;
      BV4_VERT_FREQ_INT_L_o : out std_ulogic;
      BV5_RV_H_i: in std_ulogic;
      BV4_SC_H_o : out std_ulogic_vector(3 downto 0);
      J9_COMP_o: out std_ulogic_vector(3 downto 0);
      DIRECT_DRIVE_VID_o: out std_ulogic_vector(3 downto 0);
      BV4_VIDEO_OUT_1_H_o: out std_ulogic;
      BV4_VIDEO_OUT_2_H_o: out std_ulogic;
      DEBUG: out  std_ulogic_vector(31 downto 0):= (others => '0')
      );

end BV4;
architecture rtl of BV4 is
     signal LBA: std_ulogic_vector(7 downto 0);
     signal BV4_HORIZ_DRIVE_L: std_ulogic;
     signal BV4_VERT_DRIVE_H: std_ulogic;
     signal V1,V2: std_ulogic;
     signal DW: std_ulogic;
     signal DA: std_ulogic_vector(4 downto 0) := (others => '0');
     signal DA_CONV: std_ulogic_vector(9 downto 0) := (others => '0');
     signal VIDOUT: std_ulogic_vector(7 downto 0) := (others => '0');
     component AD_LUT_32x10 is
	port (address : in  std_ulogic_vector (4 downto 0); 
	      data_out: out std_ulogic_vector (9 downto 0)  -- 10-bit quantized headroom voltage
      );
     end component;
begin
  DC011_INT: dc011 port map(
     clk_i => clk_i,
     clk24_i => clk24_i,
     n_rst_i => '1',
     d0_i => DO_0_i(4),
     d1_i => DO_0_i(5),
     n_vid_wr_i => BV2_VID_WR_1L_i,
     dw_i => DW,
     hold_req_i => BV4_HOLD_REQ_H_o,
     LBA_o => LBA_o,
     dot_clock_o => BV4_DOT_CLK_H_o,
     char_clk_o => BV4_CHAR_CLK_H_o,
     n_write_lb_o => BV4_WRITE_LB_L_o,
     vsr_ld_o => BV4_VSR_LOAD_H_o,
     n_addr_ld_o => BV4_ADDR_LD_L_o,
     n_hdrive_o => BV4_HORIZ_DRIVE_L,
     hblank_o  => BV4_HORIZ_BLK_H_o,
     vrst_o  => BV4_VERT_RESET_H_o,
     vdrive_o => BV4_VERT_DRIVE_H,
     n_vblank_o  => BV4_VERT_BLANK_L_o,
     comp_sync_o => BV4_COMP_SYNC_L_o,
     addr_count_o => BV4_ADDR_CNT_H_o
    );
    
  DC012_INT: dc012 port map(
     clk_i => clk_i,
     dot_clock_i => BV4_DOT_CLK_H_o,
     n_rst_i => '1',
     data_i =>  DO_0_i(3 downto 0),
     n_vid_w2_i => BV2_VID_WR_2L_i,
     vrst_i => BV4_VERT_RESET_H_o,
     vf_intr_o => BV4_VERT_FREQ_INT_L_o,
     revvid_i => BV5_RV_H_i,
     n_d_h_i => BV5_DH_L_i,
     n_d_w_i => BV5_DW_L_i,
     hold_req_o => BV4_HOLD_REQ_H_o,
     n_addr_ld_i => BV4_ADDR_LD_L_o,
     char_clk_i => BV4_CHAR_CLK_H_o,
     hblank_i => BV4_HORIZ_BLK_H_o,
     scan_cnt_o => BV4_SC_H_o,
     vid1out_o => BV4_VIDEO_OUT_1_H_o,
     vid2out_o => BV4_VIDEO_OUT_2_H_o,
     term_i => BV5_TERM_L_i,
     n_underline_i => BV1_UNDERLINE_L_i,
     n_blink_i => BV1_BLINK_L_i,
     n_bold_i => BV1_BOLD_L_i,
     vid_in_i => BV5_SERIAL_VIDEO_H_i
    );
    D_FF_1: D_FF_p
      port map(
       clk_i => not BV4_VERT_DRIVE_H,
       D => BV4_HORIZ_DRIVE_L,
       Q => BV4_EVEN_FIELD_L_o
      );
    BV4_HORIZ_DRIVE_L_o <= BV4_HORIZ_DRIVE_L;
    BV4_VERT_DRIVE_L_o <= not BV4_VERT_DRIVE_H;
    DW <= BV5_DW_L_i nand BV5_DH_L_i;
    -- D/A Latch
    DA_LATCH_PROC: process(BV2_DA_WR_L_i)
    begin
      if rising_edge(BV2_DA_WR_L_i) then
	BV4_INIT_H_o <= DO_0_i(5);
	DA <= DO_0_i(4 downto 0);
      end if;
    end process DA_LATCH_PROC;
    -- Video
    V1 <= (not BV1_GRAPHIC_1_IN_L_i) or (BV4_VIDEO_OUT_1_H_o and BV4_VERT_BLANK_L_o);
    V2 <= (not BV1_GRAPHIC_2_IN_L_i) or (BV4_VIDEO_OUT_2_H_o and BV4_VERT_BLANK_L_o);
    -- approximation of video analog circuit
    J9_COMP_o <= ('0' & V2 & V1 & '1') and BV4_VERT_BLANK_L_o and  BV4_COMP_SYNC_L_o;
    AD_LUT_32x10_INST: AD_LUT_32x10 port map (
         address => (DA),
	 data_out => DA_CONV
      );
    VIDOUT <= '0' & DA_CONV(9 downto 3) + ('0' & V2 & V1 & "00000");
    DIRECT_DRIVE_VID_o <= VIDOUT(3 downto 0);

    BV4_HS_CLK_H_o <= clk24_i;
    BV4_T_HOLD_REQ_H_o <= BV4_HOLD_REQ_H_o;
    SR_FF_1: SR_FF_p
      port map(
       D => BV6_HLDA_H_i,
       S => '1',
       R => BV4_HOLD_REQ_H_o,
       clk_i => LBA_o(4),
       Q => BV4_DMA_ENA_H_o,
       n_Q => BV4_DMA_ENA_L_o
      );
    -- SYNC 1.2k  --v1 1.8  v2 1.1
    -- v1  180 / 1.8k = 0.1  - csync 180 / 720 = 0.25
    -- v2  180 / 1.1k = 0.16  -cs 180 / 570 = 0.315   v1 + v2 180 / 680 = 0.265 - cs 180 /435 = 0.41
     --DEBUG(2) <= BV4_DOT_CLK_H_o;
     DEBUG(7 downto 0) <= LBA_o;
     DEBUG(8) <= BV4_DOT_CLK_H_o;
end rtl;
