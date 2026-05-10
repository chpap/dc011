library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.dc0112_pkg.all;

architecture rtl of vt100 is
signal done :               std_logic := '0';
signal interrupts :         std_logic_vector(3 downto 0);
signal iop1 :               std_logic_vector(7 downto 0);
signal iop2 :               std_logic_vector(7 downto 0);
signal txd :                std_logic;
signal rxd :                std_logic;

  signal d0: std_ulogic := '0';
  signal d1: std_ulogic := '0';
  signal n_vid_wr: std_ulogic := '1';

  signal  n_rst:  std_ulogic;
  signal  LBA:   std_ulogic_vector (7 downto 0);
  signal  dot_clock:   std_ulogic;
  signal  char_clk:   std_ulogic;
  signal  n_write_lb:   std_ulogic;
  signal  vsr_ld:   std_ulogic;
  signal  n_addr_ld:   std_ulogic;
  signal  dw:   std_ulogic;
  signal  hold_req:   std_ulogic;
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

  signal clk_f1: std_logic;
  signal clk_f2: std_logic;
  --component cpu8080_testbench is
  -- port (clk_i : in std_logic;
  --       reset_i : in std_logic
  --	     );
  --end component;
   component i8xxx_stub is
   port( clk_i : in std_logic;
      clk24_i    : in  std_logic;
      n_reset_i : in std_logic;
      pin_a     : out std_logic_vector(15 downto 0);
      pin_d     : inout std_logic_vector(7 downto 0);
      pin_hold  : in  std_logic;
      pin_hlda  : out std_logic;
      pin_ready : in  std_logic;
      pin_wait  : out std_logic;
      pin_int   : in  std_logic;
      pin_inte  : out std_logic;
      pin_dbin  : out std_logic;
      pin_wr_n  : out std_logic;
      n_stsb_o  : out std_logic);
   end component;

begin
   n_rst <= reset_i;
   dc011_inst: dc011 port map (clk24_i, n_rst, d0, d1, n_vid_wr, dw, hold_req, LBA, dot_clock, char_clk, n_write_lb,vsr_ld,n_addr_ld,n_hdrive,hblank,vrst,vdrive,n_vblank,comp_sync,addr_count);
--  dut2: dc012 port map (
-- dot_clock, n_rst, data, n_vid_w2, vrst, vf_intr, revvid, d_h,
--      d_l, n_addr_ld, hold_req, vsr_ld, char_clk, hblank, scan_cnt, vid1out,
--      vid2out, term, n_underline, n_blink, n_bold, vid_in);
--  dut3: cpu8080_testbench port map(clk_i => clk24_i, reset_i => not n_rst);

   i8xxx_stub_inst: i8xxx_stub port map( clk_i => clk24_i,
   clk24_i => clk24_i,
   n_reset_i => n_rst,
   pin_a => open,
   pin_d => open,
   pin_hold => '0',
   pin_hlda => open,
   pin_ready => '0',
   pin_wait => open,
   pin_int => '0',
   pin_inte => open, 
   pin_dbin => open,
   pin_wr_n => open,
   n_stsb_o => open);
end;
