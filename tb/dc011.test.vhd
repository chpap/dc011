library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.dc0112_pkg.all;

entity dc011_tb is
end entity;

architecture testbench of dc011_tb is
signal clk :                std_logic := '0';
signal reset :              std_logic := '1';
signal done :               std_logic := '0';
signal interrupts :         std_logic_vector(3 downto 0);
signal iop1 :               std_logic_vector(7 downto 0);
signal iop2 :               std_logic_vector(7 downto 0);
signal txd :                std_logic;
signal rxd :                std_logic;

  signal d0: std_ulogic := '0';
  signal d1: std_ulogic := '0';
  signal n_vid_wr: std_ulogic := '1';

  signal  clk100:    std_ulogic :=  '0';
  signal  clk24:    std_ulogic :=  '0';
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

  component cpu8080_testbench is
   port (clk_i : in std_logic;
         reset_i : in std_logic
	     );
  end component;


begin
  dut: dc011 port map (
     clk_i => clk100,
     clk24_i =>clk24,
     n_rst_i => n_rst,
     d0_i => d0,
     d1_i => d1,
     n_vid_wr_i => n_vid_wr,
     dw_i => dw,
     hold_req_i => hold_req,
     LBA_o => LBA,
     dot_clock_o => dot_clock,
     char_clk_o => char_clk,
     n_write_lb_o => n_write_lb,
     vsr_ld_o => vsr_ld,
     n_addr_ld_o => n_addr_ld,
     n_hdrive_o => n_hdrive,
     hblank_o => hblank,
     vrst_o => vrst,
     vdrive_o => vdrive,
     n_vblank_o => n_vblank,
     comp_sync_o => comp_sync,
     addr_count_o => addr_count
);

  process
  begin
    clk24 <= '0';
    wait for 20.76981 ns;
    clk24 <= '1';
    wait for 20.76981 ns;
  end process;

  process
  begin
    clk100 <= '0';
    wait for 10 ns;
    clk100 <= '1';
    wait for 10 ns;
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
    wait for 1000 ns;
    hold_req <= '1';
    wait for 1000 ns;
    hold_req <= '0';
    wait for 1000 ns;
    hold_req <= '1';
    wait for 1000 ns;
for i in 1 to 1000 loop
    hold_req <= '0';
    wait for 3000 ns;
    hold_req <= '1';
    wait for 3000 ns;
end loop;
    wait for 45000 ms;
  end process;

  process 
  begin
for i in 1 to 1000 loop
    dw <= '0';
    wait for 10000 ns;
    dw <= '0';
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
