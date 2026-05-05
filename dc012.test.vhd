library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity dc012_tb is
end entity;

architecture testbench of dc012_tb is
  signal d0: std_logic := '0';
  signal d1: std_logic := '0';
  signal n_vid_wr: std_logic := '1';
  component dc011
    port(
      clk:    in  std_logic;
      n_rst:  in  std_logic;
      d0:  in  std_logic;
      d1:  in  std_logic;
      n_vid_wr:  in  std_logic;
      dw:  in  std_logic;
      hold_req:  in  std_logic;
      LBA:   out std_logic_vector (7 downto 0);
      dot_clock:   out std_logic;
      char_clk:   out std_logic;
      n_write_lb:   out std_logic;
      vsr_ld:   out std_logic;
      n_addr_ld: out std_logic;
      n_hdrive: out  std_ulogic;
      hblank : out  std_ulogic;
      vrst : out  std_ulogic;
      vdrive: out  std_ulogic;
      n_vblank : out  std_ulogic;
      comp_sync: out  std_ulogic;
      addr_count: out  std_ulogic
    );
  end component;
  component dc012 is
    port (
      dot_clock: in std_ulogic;
      n_rst:  in  std_logic;
      data:  in  std_logic_vector(3 downto 0);
      n_vid_w2:  in  std_logic;
      vrst:  in  std_logic;
      vf_intr:   out std_logic;
      revvid:  in  std_logic;
      d_h:   in std_logic;
      d_l:   in std_logic;
      addr_ld:   in std_logic;
      hold_req:   out std_logic;
      vsr_ld:   out std_logic;
      char_clk:   in std_logic;
      hblank:   in std_logic;
      scan_cnt:  in  std_logic_vector(3 downto 0);
      vid1out:   in std_logic;
      vid2out:   in std_logic;
      term: in  std_logic;
      underline: in  std_logic;
      blink: in  std_logic;
      bold: in  std_logic;
      vid_in: in std_logic
     );
  end component;

  signal  clk:    std_logic;
  signal  n_rst:  std_logic;
  signal  LBA:   std_logic_vector (7 downto 0);
  signal  dot_clock:   std_logic;
  signal  char_clk:   std_logic;
  signal  n_write_lb:   std_logic;
  signal  vsr_ld:   std_logic;
  signal  n_addr_ld:   std_logic;
  signal  dw:   std_logic;
  signal  hold_req:   std_logic;
  signal n_hdrive: std_ulogic;
  signal hblank : std_ulogic;
  signal vrst : std_ulogic;
  signal vdrive: std_ulogic;
  signal n_vblank : std_ulogic;
  signal comp_sync: std_ulogic;
  signal addr_count: std_ulogic;

  signal data:  std_logic_vector(3 downto 0);
  signal n_vid_w2:  std_logic;
  signal vf_intr:   std_logic;
  signal revvid:  std_logic;
  signal d_h:   std_logic;
  signal d_l:   std_logic;
  signal addr_ld:   std_logic;
  signal scan_cnt:  std_logic_vector(3 downto 0);
  signal vid1out:  std_logic;
  signal vid2out:  std_logic;
  signal term: std_logic;
  signal underline: std_logic;
  signal blink: std_logic;
  signal bold: std_logic;
  signal vid_in: std_logic;
begin
  dut: dc011 port map (clk, n_rst, d0, d1, n_vid_wr, dw, hold_req, LBA, dot_clock, char_clk, n_write_lb,vsr_ld,n_addr_ld,n_hdrive,hblank,vrst,vdrive,n_vblank,comp_sync,addr_count);
  dut2: dc012 port map (
      dot_clock, n_rst, data, n_vid_w2, vrst, vf_intr, revvid, d_h,
      d_l, addr_ld, hold_req, vsr_ld, char_clk, hblank, scan_cnt, vid1out,
      vid2out, term, underline, blink, bold, vid_in);

  process
  begin
    clk <= '0';
    wait for 20.7698 ns;
    clk <= '1';
    wait for 20.7698 ns;
  end process;

  process
  begin
    n_rst <= '0';
    wait for 5 ns;
    n_rst <= '1';
    wait for 45000 ms;
  end process;
  process 
  begin
    hold_req <= '0';
    wait for 10 ns;
    hold_req <= '1';
    wait for 10 ns;
    hold_req <= '0';
    wait for 10 ns;
    hold_req <= '1';
    wait for 10 ns;
for i in 1 to 1000 loop
    hold_req <= '0';
    wait for 3 ns;
    hold_req <= '1';
    wait for 3 ns;
end loop;
    wait for 45000 ms;
  end process;

  process 
  begin
for i in 1 to 1000 loop
    dw <= '0';
    wait for 1000 ns;
    dw <= '1';
    wait for 1000 ns;
end loop;
    wait for 45000 ms;
  end process;

  process
     begin
wait for 10 ns;
    n_vid_wr <= '1';
    -- d0 <= '0'; --80
    d0 <= '0';
    d1 <= '0';
    n_vid_wr <= '0';
    wait for 10 ns;
    n_vid_wr <= '1';
    wait for 10 ns;
    d0 <= '0';
    d1 <= '1';
    n_vid_wr <= '0';
    wait for 10 ns;
    n_vid_wr <= '1';
    wait for 45000 ms;
  end process;
end;
