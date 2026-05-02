library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity dc011_tb is
end entity;

architecture testbench of dc011_tb is
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
      n_vblank : out  std_ulogic
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
    signal lba0: std_ulogic;
    signal lba1: std_ulogic;
    signal lba2: std_ulogic;
    signal lba3: std_ulogic;
    signal lba4: std_ulogic;
    signal lba5: std_ulogic;
    signal lba6: std_ulogic;
    signal lba7: std_ulogic;

begin
  dut: dc011 port map (clk, n_rst, d0, d1, n_vid_wr, dw, hold_req, LBA, dot_clock, char_clk, n_write_lb,vsr_ld,n_addr_ld,n_hdrive,hblank,vrst,vdrive,n_vblank);

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
    wait for 2500000 ns;
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
    wait for 2500000 ns;
  end process;
   LBA0 <= LBA(0);
   LBA1 <= LBA(1);
   LBA2 <= LBA(2);
   LBA3 <= LBA(3);
   LBA4 <= LBA(4);
   LBA5 <= LBA(5);
   LBA6 <= LBA(6);
   LBA7 <= LBA(7);
end;
