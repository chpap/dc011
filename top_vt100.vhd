library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.dc0112_pkg.all;

entity top_vt100  is
    port(clk100_i: in std_logic;
     n_reset_i: in std_logic;
     TXD0: out std_logic;
     RXD0: in std_logic;
     videoR: out  std_logic_vector(3 downto 0);
     videoG: out  std_logic_vector(3 downto 0);
     videoB: out  std_logic_vector(3 downto 0);
     hSync: out  std_logic;
     vSync: out  std_logic
    );
end entity;

architecture testbench of top_vt100  is
  signal  clk_100:    std_ulogic :=  '0';
  signal  clk_24_07:    std_ulogic :=  '0';
  signal  clk_24_88:    std_ulogic :=  '0';
  signal  clk_6_25:    std_ulogic :=  '0';
--  component clk_plle2 is
--  port ( 
--    clk_100    : out std_logic; -- CLKOUT0: 100 MHz
--    clk_24_88  : out std_logic; -- CLKOUT1: ~24.8832 MHz
--    clk_24_07  : out std_logic; -- CLKOUT2: ~24.0734 MHz
--    clk_6_25 : out std_logic; -- CLKOUT3: 6.25 MHz (Lowest)
--    reset : in STD_LOGIC;
--    locked : out STD_LOGIC;
--    clk_in : in STD_LOGIC
--  );
--  end component;

begin
--  plle2_inst: clk_plle2
--    port map(clk_100 => clk_100,
--    clk_24_88 => clk_24_88,
--    clk_24_07 => clk_24_07,
--    clk_6_25 => clk_6_25,
--    reset => not n_reset_i,
--    locked => open,
--    clk_in => clk100_i
--    );
  vt100_inst: vt100
    port map(clk24_i => clk_24_88,
     clk100_i => clk100_i,
     reset_i => n_reset_i,
     TXD0 => TXD0, 
     RXD0 => RXD0,
     videoR => videoR,
     videoG => videoG,
     videoB => videoB,
     hSync => hSync,
     vSync => vSync
    );
end;
