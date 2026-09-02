library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dc0112_pkg.all;
use work.vt100_pkg.all;

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
	signal xmit_data: std_ulogic;
	signal rec_data: std_ulogic;
	signal n_request_to_send: std_ulogic;
	signal n_data_terminal_ready: std_ulogic;
	signal data_set_ready: std_ulogic;
	signal rx_clk, tx_clk: std_ulogic;

begin
   I8251A_INST: i8251A port map(
        clk_i => BV6_F2_TTL_i,
        reset_i => BV6_RESET_H_i,
        D_i => std_logic_vector(DB_0_i),
        std_ulogic_vector(D_o) => DB_0_o,
        n_cs_i => A0_H_i(0),
        c_d_i => A0_H_i(1),
        rd_n_i => BV6_IO_RD_L_i,
        wr_n_i => BV6_IO_WR_L_i,
        -- Serial Transmitter Signals
        txd_i => xmit_data,
        txc_n_i => tx_clk,
        txrdy_o => BV3_XMIT_FLAG_H_o,
        txempty_o => open,
        -- Serial Receiver Signals
        rxd_i => rec_data,
        rxc_n_i => rx_clk,
        rxrdy_o => BV3_REC_FLAG_H_o,
        -- Modem Control Signals
        n_dsr_i => not data_set_ready,
        n_dtr_o => n_data_terminal_ready,
        n_rts_o => n_request_to_send,
        n_cts_i => '0'
    );
------------------------------------
debug_proc: process(clk_i)
begin
  if(rising_edge(clk_i)) then
    DEBUG(15 downto 0) <= A0_H_i;
    DEBUG(31 downto 16) <= (others => '0');
  end if;
end process debug_proc;
   BV3_OPTION_PRESENT_H_o <= '0';
    
end rtl;
