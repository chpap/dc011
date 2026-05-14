-- Device      : xc7a100tcsg324-1D
-- --------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity clk_plle2 is
  Port ( 
    clk_100    : out std_logic; -- CLKOUT0: 100 MHz
    clk_24_88  : out std_logic; -- CLKOUT1: ~24.8832 MHz
    clk_24_07  : out std_logic; -- CLKOUT2: ~24.0734 MHz
    clk_6_25 : out std_logic; -- CLKOUT3: 6.25 MHz (Lowest)
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in : in STD_LOGIC
  );
end entity;

architecture rtl of clk_plle2 is
    -- Χειροκίνητη δήλωση του PLLE2_ADV για το GHDL/Yosys
    component PLLE2_ADV is
        generic (
        BANDWIDTH          : string  := "OPTIMIZED";
        CLKFBOUT_MULT  : integer := 5;
        CLKIN1_PERIOD  : real    := 0.0;
        CLKOUT0_DIVIDE : integer := 1;
        CLKOUT1_DIVIDE : integer := 1;
        CLKOUT2_DIVIDE : integer := 1;
        CLKOUT3_DIVIDE : integer := 1;
        DIVCLK_DIVIDE  : integer := 1;
        STARTUP_WAIT   : string  := "FALSE"
        );
        port (
            CLKIN1   : in  std_logic;
            CLKFBIN  : in  std_logic;
            CLKFBOUT : out  std_logic;
            CLKOUT0  : out std_logic;
            CLKOUT1  : out std_logic;
            CLKOUT2  : out std_logic;
            CLKOUT3  : out std_logic;
            LOCKED   : out std_logic;
            RST      : in  std_logic;
            PWRDWN   : in  std_logic
        );
    end component;
    component BUFG is
       port(
         I: in std_logic;
         O: out std_logic
       );
    end component;
	      

    signal clk_fb : std_logic;
    signal clk0_unbuffered : std_logic;
    signal clk1_unbuffered : std_logic;
    signal clk2_unbuffered : std_logic;
    signal clk3_unbuffered : std_logic;
begin
	-- CLKOUT0 = 800 / 8   = 100 MHz
    -- CLKOUT1 = 800 / 32  = 25 MHz (Πλησιέστερο στο 24.8832 χωρίς fractional MMCM)
    -- CLKOUT2 = 800 / 33  = 24.24 MHz (Πλησιέστερο στο 24.0734)
    -- CLKOUT3 = 800 / 128 = 6.25 MHz (Το χαμηλότερο δυνατό για PLL: DIV=128)

    -- Instantiation του αντικειμένου
    pll_inst : PLLE2_ADV
    generic map (
        CLKIN1_PERIOD  => 10.0,   -- 100 MHz input
        CLKFBOUT_MULT  => 8,      -- VCO = 800 MHz
        DIVCLK_DIVIDE  => 1,
        CLKOUT0_DIVIDE => 8,      -- 100 MHz
        CLKOUT1_DIVIDE => 32,     -- ~25 MHz 
        CLKOUT2_DIVIDE => 33,     -- ~24.24 MHz
        CLKOUT3_DIVIDE => 128     -- 6.25 MHz
    )
    port map (
        CLKIN1   => clk_in,
        CLKFBIN  => clk_fb,
        CLKFBOUT => clk_fb,
        CLKOUT0  => clk0_unbuffered,
        CLKOUT1  => clk1_unbuffered,
        CLKOUT2  => clk2_unbuffered,
        CLKOUT3  => clk3_unbuffered,
        LOCKED   => locked,
        RST      => reset,
        PWRDWN   => '0'
    );
    clk_100 <= clk0_unbuffered;
    clk_24_88 <= clk1_unbuffered;
    clk_24_07<= clk2_unbuffered;
    clk_6_25 <= clk3_unbuffered;
--    bufg_clk0 : BUFG
--    port map (
--       I => clk0_unbuffered,
--       O => clk_100
--       );
--    bufg_clk1 : BUFG
--    port map (
--       I => clk1_unbuffered,
--       O => clk_24_88
--       );
--    bufg_clk2 : BUFG
--    port map (
--       I => clk2_unbuffered,
--       O => clk_24_07
--       );
--    bufg_clk3 : BUFG
--    port map (
--       I => clk3_unbuffered,
--       O => clk_6_25
--       );
end architecture;

