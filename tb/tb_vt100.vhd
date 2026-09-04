library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.dc0112_pkg.all;

entity tb_vt100  is
end entity;

architecture testbench of tb_vt100  is
     signal clk100_i: std_logic;
     signal reset_i: std_logic;
     signal TXD0: std_logic;
     signal RXD0: std_logic;
     signal videoR: std_logic_vector(3 downto 0);
     signal videoG: std_logic_vector(3 downto 0);
     signal videoB: std_logic_vector(3 downto 0);
     signal hSync: std_logic;
     signal vSync: std_logic
    );
  component top_vt100  is
    port(clk_i: in std_logic;
     reset_i: in std_logic;
     TXD0: out std_logic;
     RXD0: in std_logic;
     videoR: out  std_logic_vector(3 downto 0);
     videoG: out  std_logic_vector(3 downto 0);
     videoB: out  std_logic_vector(3 downto 0);
     hSync: out  std_logic;
     vSync: out  std_logic
    );
  end component;

begin
  dut: top_vt100 
    port map(
    clk100_i => clk100_i,
    reset_i => reset_i,
    TXD0 => TXD0,
    RXD0 => RXD0,
    videoR => videoR,
    videoG => videoG,
    videoB => videoB,
    hSync => hSync,
    vSync => vSync
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
    reset_i <= '1';
    wait for 5 ns;
    reset_i <= '0';
    wait; -- for 45000 ms;
  end process;
end;
