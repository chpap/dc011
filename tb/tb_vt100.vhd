library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.dc0112_pkg.all;

entity tb_vt100  is
end entity;

architecture testbench of tb_vt100  is
     signal clk100_i: std_logic;
     signal clk_24_07_i: std_logic;
     signal clk_24_88_i: std_logic;
     signal reset_i: std_logic;
     signal TXD0: std_logic;
     signal RXD0: std_logic;
     signal videoR: std_logic_vector(3 downto 0);
     signal videoG: std_logic_vector(3 downto 0);
     signal videoB: std_logic_vector(3 downto 0);
     signal hSync: std_logic;
     signal vSync: std_logic;
     
  component top_sim_vt100  is
    port(clk100: in std_logic;
     clk_24_07:   in std_ulogic;
     clk_24_88:   in std_ulogic;
     hsync: out  std_logic;
     vsync: out  std_logic;
     n_reset_i: in std_logic;
     txd0: out std_logic;
     rxd0: in std_logic;
     btnc: in std_logic;
     videor: out  std_logic_vector(3 downto 0);
     videog: out  std_logic_vector(3 downto 0);
     videob: out  std_logic_vector(3 downto 0);
     kbd_led: out  std_logic_vector(5 downto 0);
     led: out  std_logic_vector(9 downto 0);
     sw: in  std_logic_vector(15 downto 0);
     an: out  std_logic_vector(7 downto 0);
     ca: out  std_logic;
     cb: out  std_logic;
     cc: out  std_logic;
     cd: out  std_logic;
     ce: out  std_logic;
     cf: out  std_logic;
     cg: out  std_logic;
     dp: out  std_logic;
     ps2clk: inout std_logic;
     ps2data: inout std_logic
    );

  end component;

begin
  dut: top_sim_vt100 
    port map(
    clk100 => clk100_i,
    clk_24_07 => clk_24_07_i,
    clk_24_88 => clk_24_88_i,
    n_reset_i => reset_i,
    TXD0 => TXD0,
    RXD0 => RXD0,
    videoR => videoR,
    videoG => videoG,
    videoB => videoB,
    hSync => hSync,
    vSync => vSync,
    sw => (others=>'1'),
    btnc => '1',
    ps2clk => open,
    ps2data => open
    );

  process
  begin
    clk100_i <= '0';
    wait for 5 ns;
    clk100_i <= '1';
    wait for 5 ns;
  end process;

  process
  begin
    clk_24_07_i <= '0';
    wait for 20.764 ns;
    clk_24_07_i <= '1';
    wait for 20.764 ns;
  end process;

  process
  begin
    clk_24_88_i <= '0';
    wait for 20.0965 ns;
    clk_24_88_i <= '1';
    wait for 20.0965 ns;
  end process;

  process
  begin
    reset_i <= '1';
    wait for 5 ns;
    reset_i <= '0';
    wait; -- for 45000 ms;
  end process;
end;
