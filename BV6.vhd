library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vt100_pkg.all;
use work.dc0112_pkg.all;

entity BV6 is
   port( clk_i : in std_ulogic;
      clk24_i    : in  std_ulogic;
      n_reset_i : in std_ulogic;
      A0_H_o     : out std_ulogic_vector(15 downto 0);
      DB_0_i     : in std_ulogic_vector(7 downto 0);
      DO_0_o  : out std_ulogic_vector(7 downto 0);
      LBA_i  : in std_ulogic_vector(7 downto 0);
      BV6_HLDA_H_o  : out std_ulogic;
      BV6_RESET_H_o : out std_ulogic;
      BV4_T_HOLD_REQ_H_i : in std_ulogic;
      BV4_DMA_ENA_H_i: in std_ulogic;
      BV6_INTA_L_o: out std_ulogic;
      BV6_IO_WR_L_o: out std_ulogic;
      BV6_IO_RD_L_o: out std_ulogic;
      BV6_MEM_WR_L_o: out std_ulogic;
      BV6_MEM_RD_L_o: out std_ulogic;

      BV3_XMIT_FLAG_H_i : in std_ulogic;
      BV3_REC_FLAG_H_i : in std_ulogic;
      BV6_KBD_DATA_AVAIL_H_i: in std_ulogic;
      BV2_KBD_WR_L_i: in std_ulogic;
      BV2_KBD_RD_L_i: in std_ulogic;
      BV4_EVEN_FIELD_L_i: in std_ulogic;
      BV3_OPTION_PRESENT_H_i: in std_ulogic;
      BV2_NVR_DATA_H_i: in std_ulogic;
      BV2_FLAG_RD_L_i: in std_ulogic;
      BV1_GRAPHICS_FLAG_L: in std_ulogic;
      BV1_ADVANCED_VIDEO_L_i: in std_ulogic;
      BV4_VERT_FREQ_INT_L_i : in std_ulogic;
      BV6_F2_TTL_o : out std_ulogic;
      ps2_clk	: inout std_ulogic;
      ps2_data  : inout std_ulogic;
      kbd_LEDs_o : out std_ulogic_vector(5 downto 0);
      btn1_i    : in std_logic;
      DEBUG: out std_ulogic_vector(31 downto 0));
end BV6;

architecture rtl of BV6 is
   signal BV6_RESET_H : std_ulogic;
   signal BV6_INTR_H : std_ulogic;
   signal BV6_KBD_TBMT_H: std_ulogic;
   signal BV6_MEM_RD_L: std_ulogic;
   signal ready : std_ulogic := '1';
   signal wait80 : std_ulogic;
   signal n_stsb : std_ulogic;
   signal inte : std_ulogic;
   signal dbin : std_ulogic;
   signal clk8080 : std_ulogic;
   signal RX_KBD : std_ulogic;
   signal TX_KBD : std_ulogic;
   signal flag_buffer: std_ulogic_vector(7 downto 0);
   signal debug_i8xxx: std_ulogic_vector(31 downto 0);
   signal debug_kb: std_ulogic_vector(31 downto 0);
   signal intr_buffer: std_ulogic_vector(7 downto 0);
   signal BV6_KBD_DATA_AVAIL_H: std_ulogic;
   signal DB_0: std_ulogic_vector(7 downto 0);
   signal D_FLAG_BUF : std_ulogic_vector(7 downto 0) := (others => '0');
   signal D_INT_VEC_BUF : std_ulogic_vector(7 downto 0) := (others => '0');
   signal D_KB_UART : std_ulogic_vector(7 downto 0);

   component i8xxx is
   port( clk_i : in std_logic;
      clk24_i    : in  std_logic;
      n_reset_i : in std_logic;
      f2_ttl_o  : out std_ulogic;
      a_o     : out std_logic_vector(15 downto 0);
      d_i     : in std_logic_vector(7 downto 0);
      d_o     : out std_logic_vector(7 downto 0);
      hold_i  : in  std_logic;
      hlda_o  : out std_logic;
      ready_i : in  std_logic;
      wait_o  : out std_logic;
      int_i   : in  std_logic;
      inte_o  : out std_logic;
      dbin_o  : out std_logic;
      reset_o : out std_logic;
      n_stsb_o: out std_logic;
      n_memr_o: out std_logic;
      n_memw_o: out std_logic;
      n_ior_o : out std_logic;
      n_iow_o : out std_logic;
      n_inta_o: out std_logic;
      debug_o: out std_logic_vector(31 downto 0));
   end component;
   component T8080se is
	generic(
		Mode : integer := 2;    -- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
		T2Write : integer := 0  -- 0 => WR_n active in T3, /=0 => WR_n active in T2
	);
	port(
		RESET_n         : in std_logic;
		CLK                     : in std_logic;
		CLKEN           : in std_logic;
		READY           : in std_logic;
		HOLD            : in std_logic;
		INT                     : in std_logic;
		INTE            : out std_logic;
		DBIN            : out std_logic;
		SYNC            : out std_logic;
		VAIT            : out std_logic;
		HLDA            : out std_logic;
		WR_n            : out std_logic;
		A                       : out std_logic_vector(15 downto 0);
		DI                      : in std_logic_vector(7 downto 0);
		DO                      : out std_logic_vector(7 downto 0)
	);
   end component T8080se;

begin
--   i8xxx_inst: i8xxx port map( clk_i => clk_i,
--   clk24_i => clk24_i,
--   n_reset_i => n_reset_i,
--   f2_ttl_o  => BV6_F2_TTL_o,
--   a_o => A0_H_o,
--   d_i => DB_0,
--   d_o => DO_0_o,
--   hold_i => BV4_T_HOLD_REQ_H_i,
--   hlda_o => BV6_HLDA_H_o,
--   ready_i => ready,
--   wait_o => wait80,
--   int_i => BV6_INTR_H,
--   inte_o => inte, 
--   dbin_o => dbin,
--   reset_o => BV6_RESET_H,
--   n_stsb_o => n_stsb,
--   n_memr_o => BV6_MEM_RD_L,
--   n_memw_o => BV6_MEM_WR_L_o,
--   n_ior_o => BV6_IO_RD_L_o,
--   n_iow_o => BV6_IO_WR_L_o,
--   n_inta_o => BV6_INTA_L_o,
--   debug_o => debug_i8xxx
--);
    clock_divider_8080 :NtoM_divider
       generic map(
          N => 8,
          M => 1
       )
       port map(
          clk_i => clk24_i,
          rst_i => '0',
          clk_o => clk8080
       );
   T8080se_inst: T8080se port map( RESET_n => n_reset_i,
		CLK => clk8080,
		CLKEN => '1',
		READY => ready,
		HOLD => BV4_T_HOLD_REQ_H_i,
		INT => int_i,
		INTE => inte_i,
		DBIN => dbin,
		SYNC => open,
		VAIT => wait80,
		HLDA => BV6_HLDA_H_o,
		WR_n => BV2_KBD_WR_L_i,
   		A => A0_H_o,
   		DI => DB_0,
   		DO => DO_0_o
	);
    BV6_RESET_H <= not n_reset_i;


    TR1602_INST: TR1602
        port map (
            rrd_i    => BV2_KBD_RD_L_i,
            rr_o     => D_KB_UART,
            pe_o     => open,
            fe_o     => open,
            oe_o     => open,
            sfd_i    => '0',
            rrc_i    => LBA_i(4),
            n_drr_i  => BV2_KBD_RD_L_i,
            dr_o     => open,
            r_i      => RX_KBD, -- input from keyboard
            mr_i     => BV6_RESET_H,
            thre_o   => BV6_KBD_TBMT_H,
            n_thrl_i => BV2_KBD_WR_L_i,
            tre_o    => open,
            tro_o    => TX_KBD,
            tr_i     => DO_0_o,
            crl_i    => '1',
            pi_i     => '1',
            sbs_i    => '0',
            wls_i    => "11",
            epe_i    => '1',
            trc_i    => LBA_i(4) 
        );

   KB_UART_INST: kb_uart port map(
     clk_i => clk_i,
     RX_KBD_o => RX_KBD,
     TX_KBD_i => TX_KBD,
     KBD_CLK_i => LBA_i(4), -- DEBUG
     LEDs => kbd_LEDs_o,
     btn1_i => btn1_i,
     ps2_clk => ps2_clk,
     ps2_data => ps2_data,
     DEBUG => debug_kb);

   BV6_RESET_H_o <= BV6_RESET_H;
   BV6_MEM_RD_L_o <= BV6_MEM_RD_L and not BV4_DMA_ENA_H_i;
   --- FLAG BUFFER
   ---------------------
   FLAG_BUF_PROC: process(BV2_FLAG_RD_L_i)
   begin
     if falling_edge(BV2_FLAG_RD_L_i) then
       D_FLAG_BUF <= flag_buffer;
     end if;
   end process FLAG_BUF_PROC;
   flag_buffer <= BV6_KBD_TBMT_H & LBA_i(7) & BV2_NVR_DATA_H_i & BV4_EVEN_FIELD_L_i & BV3_OPTION_PRESENT_H_i & BV1_GRAPHICS_FLAG_L &  BV1_ADVANCED_VIDEO_L_i & BV3_XMIT_FLAG_H_i;

   --- INTR BUFFER
   ---------------------
   INTR_BUF_PROC: process(BV6_INTA_L_o)
   begin
     if falling_edge(BV6_INTA_L_o)  then
       D_INT_VEC_BUF <= intr_buffer;
     end if;
   end process INTR_BUF_PROC;
   intr_buffer <= "11" & not BV4_VERT_FREQ_INT_L_i & (BV3_XMIT_FLAG_H_i or BV3_REC_FLAG_H_i) & BV6_KBD_DATA_AVAIL_H_i & "111";
   BV6_INTR_H <= (not BV4_VERT_FREQ_INT_L_i) or (BV6_KBD_DATA_AVAIL_H_i or BV3_XMIT_FLAG_H_i or BV3_REC_FLAG_H_i  );
   -------------- DATA BUS MUX
   DB_0 <= D_INT_VEC_BUF when BV6_INTA_L_o = '0' else 
	   DB_0_i when (BV6_MEM_RD_L = '0' or BV6_MEM_WR_L_o = '0') else
	   D_FLAG_BUF when BV2_FLAG_RD_L_i = '0' else
	   D_KB_UART when BV2_KBD_RD_L_i = '0' else
	   (others => '0' );

   --DEBUG <= DB_0_i & DO_0_o & A0_H_o;
   DEBUG(15 downto 0) <= debug_kb(15 downto 0);
   DEBUG(23 downto 16) <= D_KB_UART;
   DEBUG(24) <= BV2_KBD_RD_L_i;
   DEBUG(25) <= BV2_FLAG_RD_L_i;
   DEBUG(26) <= BV6_MEM_RD_L_o;
   DEBUG(27) <= BV6_MEM_WR_L_o;
end rtl;
