library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.dc0112_pkg.all;

entity dc011_tb is
end entity;

architecture testbench of dc011_tb is
  signal d0: std_logic := '0';
  signal d1: std_logic := '0';
  signal n_vid_wr: std_logic := '1';

  signal  clk24:    std_ulogic;
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

begin
  dut: dc011 port map (clk24, n_rst, d0, d1, n_vid_wr, dw, hold_req, LBA, dot_clock, char_clk, n_write_lb,vsr_ld,n_addr_ld,n_hdrive,hblank,vrst,vdrive,n_vblank,comp_sync,addr_count);

  process
  begin
    clk24 <= '0';
    wait for 20.7698 ns;
    clk24 <= '1';
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
