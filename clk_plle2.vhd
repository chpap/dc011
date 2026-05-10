-- Device      : xc7a100tcsg324-1
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
	CLKFBOUT : out std_logic;
            CLKOUT0  : out std_logic;
            CLKOUT1  : out std_logic;
            CLKOUT2  : out std_logic;
            CLKOUT3  : out std_logic;
            LOCKED   : out std_logic;
            CLKFBIN  : in  std_logic;
            CLKIN1   : in  std_logic;
            PWRDWN   : in  std_logic;
            RST      : in  std_logic;
            DADDR    : in  std_logic_vector(6 downto 0);
            DCLK     : in  std_logic;
            DEN      : in  std_logic;
            DI       : in  std_logic_vector(15 downto 0)
        );
    end component;

    signal clk_fb : std_logic;
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
        CLKOUT0  => clk_100,
        CLKOUT1  => clk_24_88,
        CLKOUT2  => clk_24_07,
        CLKOUT3  => clk_6_25,
        LOCKED   => locked,
        RST      => reset,
        PWRDWN   => '0',
        DADDR    => (others => '0'),
        DCLK     => '0',
        DEN      => '0',
        DI       => (others => '0')
    );
end architecture;

