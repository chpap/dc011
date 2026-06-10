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
   component i8251A is
    Port (
        -- System and CPU Bus Signals
        clk_i         : in    STD_LOGIC;                      -- Main logic clock
        reset_i       : in    STD_LOGIC;                      -- System Reset (Active High)
        D_i           : in STD_LOGIC_VECTOR(7 downto 0);   -- Bidirectional Data Bus
        D_o           : out STD_LOGIC_VECTOR(7 downto 0);   -- Bidirectional Data Bus
        n_cs_i        : in    STD_LOGIC;                      -- Chip Select (Active Low)
        c_d_i         : in    STD_LOGIC;                      -- Control/Status = 1, Data = 0
        rd_n_i        : in    STD_LOGIC;                      -- Read Enable (Active Low)
        wr_n_i        : in    STD_LOGIC;                      -- Write Enable (Active Low)
        -- Serial Transmitter Signals
        txd_i         : out   STD_LOGIC := '1';               -- Transmit Serial Data
        txc_n_i       : in    STD_LOGIC;                      -- Transmitter Clock (Active Low)
        txrdy_o       : out   STD_LOGIC;                      -- Transmitter Ready for Byte
        txempty_o     : out   STD_LOGIC;                      -- Transmitter Shift Register Empty
        -- Serial Receiver Signals
        rxd_i         : in    STD_LOGIC;                      -- Receive Serial Data
        rxc_n_i       : in    STD_LOGIC;                      -- Receiver Clock (Active Low)
        rxrdy_o       : out   STD_LOGIC;                      -- Receiver Has Data Ready
        -- Modem Control Signals
        n_dsr_i       : in    STD_LOGIC := '1';               -- Data Set Ready (Active Low)
        n_dtr_o       : out   STD_LOGIC := '1';               -- Data Terminal Ready (Active Low)
        n_rts_o       : out   STD_LOGIC := '1';               -- Request to Send (Active Low)
        n_cts_i       : in    STD_LOGIC := '0'                -- Clear to Send (Active Low)
    );
   end component;
   component TR1602 is
    Port (
	rrd_i        : in  std_ulogic; -- receiver register disconnect LT: H-> disconnect input rr frm holding reg
	rr_o         : out  std_ulogic_vector(7 downto 0); -- contents of RHR (Receiver Holding Register) when rrd -> 0
        pe_o         : out std_ulogic; -- parity error
        fe_o         : out std_ulogic; -- framing error
        oe_o         : out std_ulogic; -- overrun error : DRF (Data Received Flag) was not reset before a new character was transferred to the RHR
        sfd_i        : in  std_ulogic; -- disconnects PE,FE, OE and THRE , allowing them to be bus connected
        rrc_i        : in  std_ulogic; -- receiver clock frequency: 16x desired receiver shift rate
        n_drr_i      : in std_ulogic; -- data receiver reset (negative logic). level triggered asynchronous reset of the DR (Data Received) line
        dr_o         : out std_ulogic; -- data received. A high level indicates that a complete character has been received
        r_i          : in std_ulogic; -- receiver input. 
        mr_i         : in std_ulogic; -- Master reset input. High level clears the logic : TR and RR, THR, FE, OE, PE, n_DRR and sets TRO, THRE, TRE
        thre_o       : out std_ulogic; -- transmitter holding register empty. high level indicates the transmitter holding register has transferred 
                                       -- its contents to the transmiter register and may be loaded with a new character
        n_thrl_i     : in std_ulogic; -- transmitter holding register load(negative logic) . Low level enters a character into the 
                                      -- THR (Transmitter holding register). A transition from low to high level transfers the character into the TR
                                      -- (Transmitter Register) if it is not in the process of transmitting. If a  character is trnsmitted, the transfer
                                      -- is delayed until its transmission is completed. Upon completion , the new character is automatically transferred
                                      -- simultaneously with the initiation of its serial transmission
	tre_o        : out std_ulogic; -- transmitter register empty .high level when TR has completed transmission of full character including stop bits
                                       -- it remains so until start of new transmission
        tro_o        : out std_ulogic; -- The contents ot the TR together with start stop and parity bits are serialy shifted out on this line. When idle this line remains higho
        tr_i         : in std_ulogic_vector(7 downto 0); -- Transmitter register data inputs. These line load a character into the TRHL with the THRL Strobe pin
	                              -- If acharacter of less than 8 bits is selected (by wls(0) and wls(1)) hte character is right justified and the 
	                              -- excess bits are discarded
	crl_i        : in std_ulogic; -- Loads the control register CR with the control bits (wls(0), wls(1), epe, pi, sbs)
	pi_i         : in std_ulogic; -- Parity inhibit. Inhibits parity generation and clamps PE output to low.
        sbs_i        : in std_ulogic; -- This line selects the stop bits after the parity bit. High selects 2 and low 1. In the case of a word selection of 5 bits, high selects .5 stop bits
        wls_i       : in std_ulogic_vector(1 downto 0); -- these two bits sleect the character length ( exclusive of parity)
                                     -- wls(1)   wls(0)  word length
                                      -----------------------------  
                                      -- L         L     5 bits
                                      -- L         H     6 bits
                                      -- H         L     7 bits
                                      -- H         H     8 bits
	epe_i       : in std_ulogic; -- even parity enable. High level selects even, low selects odd
        trc_i       : in std_ulogic -- transmitter clock. 16x the desired shift rate
        
    );
   end component TR1602;
   component kb_uart is
   port( clk_i : in std_ulogic;
      RX_KBD_o: out std_ulogic;
      TX_KBD_i: in std_ulogic;
      KBD_CLK_i: in std_ulogic;
      ps2_clk	: inout std_ulogic;
      ps2_data  : inout std_ulogic;
      LEDs : out std_ulogic_vector(5 downto 0);
      DEBUG     : out std_ulogic_vector(31 downto 0));
   end component;
   component BV2 is
   port( clk_i : in std_ulogic;
      clk24_i    : in  std_ulogic;
      DO_0_i     : in std_ulogic_vector(7 downto 0);
      DB_0_o     : out std_ulogic_vector(7 downto 0);
      LBA_i     : in std_ulogic_vector(7 downto 0);
      A0_H_i : in std_ulogic_vector(15 downto 0);
      BV6_RESET_L_i  : in std_ulogic;
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
      BV2_DA_WR_L_o: out std_ulogic;
      BV2_WRITE_BAUD_H_o: out std_ulogic;
      BV2_SEL_8_12K_L_o: out std_ulogic;
      BV2_SEL_ATT_RAM_L_o: out std_ulogic);
   end component;
   component BV3 is
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
      BV2_VID_WR_1L_i: in std_ulogic;
      BV2_VID_WR_2L_i: in std_ulogic;
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
      BV4_SC_H_o : out std_ulogic_vector(3 downto 0);
      BV5_RV_H_i: in  std_ulogic;
      J9_COMP_o: out std_ulogic_vector(3 downto 0);
      DIRECT_DRIVE_VID_o: out std_ulogic_vector(3 downto 0);
      BV4_VIDEO_OUT_1_H_o: out std_ulogic;
      BV4_VIDEO_OUT_2_H_o: out std_ulogic;
      DEBUG: out  std_ulogic_vector(31 downto 0));
   end component;
   component BV5 is
   port( clk_i : in std_ulogic;
      A0_H_o    : out std_ulogic_vector(15 downto 0);
      DO_0_i    : in std_ulogic_vector(7 downto 0);
      LBA_i     : in std_ulogic_vector(7 downto 0);
      BV4_SC_H_i : in std_ulogic_vector(3 downto 0);
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
      BV5_DH_L_o: out  std_ulogic;
      BV5_DW_L_o: out  std_ulogic;
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
      BV4_DMA_ENA_H_i: in std_ulogic;
      BV4_T_HOLD_REQ_H_i : in std_ulogic;
      BV6_INTA_L_o: out std_ulogic;
      BV6_IO_WR_L_o: out std_ulogic;
      BV6_IO_RD_L_o: out std_ulogic;
      BV6_MEM_WR_L_o: out std_ulogic;
      BV6_MEM_RD_L_o: out std_ulogic;
      BV3_XMIT_FLAG_H_i : in std_ulogic;
      BV3_REC_FLAG_H_i : in std_ulogic;
      BV6_KBD_DATA_AVAIL_H_i: in std_ulogic;
      BV2_KBD_RD_L_i: in std_ulogic;
      BV2_KBD_WR_L_i: in std_ulogic;
      BV4_EVEN_FIELD_L_i: in std_ulogic;
      BV3_OPTION_PRESENT_H_i: in std_ulogic;
      BV2_NVR_DATA_H_i: in std_ulogic;
      BV2_FLAG_RD_L_i: in std_ulogic;
      BV1_GRAPHICS_FLAG_L: in std_ulogic;
      BV1_ADVANCED_VIDEO_L_i: in std_ulogic;
      BV4_VERT_FREQ_INT_L_i : in std_ulogic;
      BV6_F2_TTL_o : out std_ulogic;
      kbd_LEDs_o : out std_ulogic_vector(5 downto 0);
      ps2_clk	: inout std_ulogic;
      ps2_data  : inout std_ulogic;
      DEBUG: out std_ulogic_vector(31 downto 0));
   end component;
   component AVO is
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
