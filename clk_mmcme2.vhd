-- Device      : xc7a100tcsg324-1D
-- --------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity clk_mmcme2 is
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

architecture rtl of clk_mmcme2 is
    -- Χειροκίνητη δήλωση του PLLE2_ADV για το GHDL/Yosys
component MMCME2_ADV is
    generic (
        BANDWIDTH            : string  := "OPTIMIZED";
        CLKFBOUT_MULT_F      : real    := 5.000;
        CLKFBOUT_PHASE       : real    := 0.000;
        CLKFBOUT_USE_FINE_PS : boolean := FALSE;
        CLKIN1_PERIOD        : real    := 0.000;
        CLKIN2_PERIOD        : real    := 0.000;
        CLKOUT0_DIVIDE_F     : real    := 1.000;
        CLKOUT0_DUTY_CYCLE   : real    := 0.500;
        CLKOUT0_PHASE        : real    := 0.000;
        CLKOUT0_USE_FINE_PS : boolean := FALSE;
        CLKOUT1_DIVIDE       : integer := 1;
        CLKOUT1_DUTY_CYCLE   : real    := 0.500;
        CLKOUT1_PHASE        : real    := 0.000;
        CLKOUT1_USE_FINE_PS : boolean := FALSE;
        CLKOUT2_DIVIDE       : integer := 1;
        CLKOUT2_DUTY_CYCLE   : real    := 0.500;
        CLKOUT2_PHASE        : real    := 0.000;
        CLKOUT2_USE_FINE_PS : boolean := FALSE;
        CLKOUT3_DIVIDE       : integer := 1;
        CLKOUT3_DUTY_CYCLE   : real    := 0.500;
        CLKOUT3_PHASE        : real    := 0.000;
        CLKOUT3_USE_FINE_PS : boolean := FALSE;
        CLKOUT4_CASCADE      : boolean := FALSE;
        CLKOUT4_DIVIDE       : integer := 1;
        CLKOUT4_DUTY_CYCLE   : real    := 0.500;
        CLKOUT4_PHASE        : real    := 0.000;
        CLKOUT4_USE_FINE_PS : boolean := FALSE;
        CLKOUT5_DIVIDE       : integer := 1;
        CLKOUT5_DUTY_CYCLE   : real    := 0.500;
        CLKOUT5_PHASE        : real    := 0.000;
        CLKOUT5_USE_FINE_PS : boolean := FALSE;
        CLKOUT6_DIVIDE       : integer := 1;
        CLKOUT6_DUTY_CYCLE   : real    := 0.500;
        CLKOUT6_PHASE        : real    := 0.000;
        CLKOUT6_USE_FINE_PS : boolean := FALSE;
        COMPENSATION         : string  := "ZHOLD";
        DIVCLK_DIVIDE        : integer := 1;
        REF_JITTER1          : real    := 0.010;
        REF_JITTER2          : real    := 0.010;
        STARTUP_WAIT         : boolean := FALSE
    );
    port (
        CLKFBIN        : in  std_logic;
        CLKIN1         : in  std_logic;
        CLKIN2         : in  std_logic;
        CLKINSEL       : in  std_logic;
        DADDR          : in  std_logic_vector(6 downto 0);
        DCLK           : in  std_logic;
        DEN            : in  std_logic;
        DI             : in  std_logic_vector(15 downto 0);
        DWE            : in  std_logic;
        PSCLK          : in  std_logic;
        PSEN           : in  std_logic;
        PSINCDEC       : in  std_logic;
        PWRDWN         : in  std_logic;
        RST            : in  std_logic;
        CLKFBOUT       : out std_logic;
        CLKFBOUTB      : out std_logic;
        CLKFBSTOPPED   : out std_logic;
        CLKINSTOPPED   : out std_logic;
        CLKOUT0        : out std_logic;
        CLKOUT0B       : out std_logic;
        CLKOUT1        : out std_logic;
        CLKOUT1B       : out std_logic;
        CLKOUT2        : out std_logic;
        CLKOUT2B       : out std_logic;
        CLKOUT3        : out std_logic;
        CLKOUT3B       : out std_logic;
        CLKOUT4        : out std_logic;
        CLKOUT5        : out std_logic;
        CLKOUT6        : out std_logic;
        DO             : out std_logic_vector(15 downto 0);
        DRDY           : out std_logic;
        LOCKED         : out std_logic;
        PSDONE         : out std_logic
    );
    end component;

    component BUFG is
       port(
         I: in std_logic;
         O: out std_logic
       );
    end component;
	      
    -- Internal clock signals
    signal clk_fb_out     : std_logic;
    signal clk_fb_in      : std_logic;
    
    -- signal clk_fb : std_logic;
    signal clk0_unbuffered : std_logic;
    signal clk1_unbuffered : std_logic;
    signal clk2_unbuffered : std_logic;
    signal clk3_unbuffered : std_logic;
begin

    -- 2. Feedback Clock Buffer
    -- Required for internal phase alignment logic inside the MMCM
    clkfb_buf_inst : BUFG
        port map (
            I => clk_fb_out,
            O => clk_fb_in
        );
  -- 3. Output Clock Buffers
    -- Routes the raw MMCM outputs to the global clock network
    bufg_clk0 : BUFG
    port map (
       I => clk0_unbuffered,
       O => clk_24_07
       );
    bufg_clk1 : BUFG
    port map (
       I => clk1_unbuffered,
       O => clk_24_88
       );
    bufg_clk2 : BUFG
    port map (
       I => clk2_unbuffered,
       O => clk_100
       );
    bufg_clk3 : BUFG
    port map (
       I => clk3_unbuffered,
       O => clk_6_25
       );

	-- CLKOUT0 = 800 / 8   = 100 MHz
    -- CLKOUT1 = 800 / 32  = 25 MHz (Πλησιέστερο στο 24.8832 χωρίς fractional MMCM)
    -- CLKOUT2 = 800 / 33  = 24.24 MHz (Πλησιέστερο στο 24.0734)
    -- CLKOUT3 = 800 / 128 = 6.25 MHz (Το χαμηλότερο δυνατό για PLL: DIV=128)
	-- 4. MMCM Primitive Instantiation
    -- Configuration Math:
    -- F_VCO = F_IN * (CLKFBOUT_MULT_F / DIVCLK_DIVIDE)
    -- F_VCO = 100 MHz * (8.000 / 1) = 800 MHz (Inside Artix-7 safe VCO range)
    -- F_OUT0 = F_VCO / CLKOUT0_DIVIDE_F = 1000 MHz / 5.000 = 200 MHz
    -- F_OUT1 = F_VCO / CLKOUT1_DIVIDE   = 1000 MHz / 10    = 100 MHz
    mmcm_adv_inst : MMCME2_ADV
        generic map (
            BANDWIDTH            => "OPTIMIZED",
            CLKIN1_PERIOD        => 10.000,          -- 10.000 ns = 100 MHz input
            CLKIN2_PERIOD        => 0.000,
            DIVCLK_DIVIDE        => 1,               -- Master division factor (1-106)
            CLKFBOUT_MULT_F      => 8.000,          -- VCO Multiplier (2.000-64.000)
            CLKFBOUT_PHASE       => 0.0,
            CLKFBOUT_USE_FINE_PS => FALSE,

            -- Configuration for Output 0 (24.0734 MHz)
            CLKOUT0_DIVIDE_F     => 33.250,           -- Divide factor (1.000-128.000)
            CLKOUT0_PHASE        => 0.0,
            CLKOUT0_DUTY_CYCLE   => 0.5,
            CLKOUT0_USE_FINE_PS => FALSE,

            -- Configuration for Output 1 (24.8832 MHz with 0 degree phase shift)
            CLKOUT1_DIVIDE       => 32,              -- Divide factor (1-128)
            CLKOUT1_PHASE        => 0.0,            -- 0 degree phase shift
            CLKOUT1_DUTY_CYCLE   => 0.5,
            CLKOUT1_USE_FINE_PS => FALSE,

            -- Configuration for Output 2 (100 MHz with 0 degree phase shift)
            CLKOUT2_DIVIDE       => 8,              -- Divide factor (1-128)
            CLKOUT2_PHASE        => 0.0,            -- 0 degree phase shift
            CLKOUT2_DUTY_CYCLE   => 0.5,
            CLKOUT2_USE_FINE_PS => FALSE,

            CLKOUT3_DIVIDE       => 128,              -- Divide factor (1-128)
            CLKOUT3_PHASE        => 0.0,            -- 0 degree phase shift
            CLKOUT3_DUTY_CYCLE   => 0.5,
            CLKOUT3_USE_FINE_PS => FALSE,

            COMPENSATION         => "ZHOLD",
            STARTUP_WAIT         => FALSE
        )
        port map (
            -- Clock Inputs
            CLKIN1          => clk_in,         -- Primary clock input
            CLKIN2          => '0',                  -- Secondary clock input (unused)
            CLKINSEL        => '1',                  -- High selects CLKIN1

            -- Feedback Ports
            CLKFBIN         => clk_fb_in,            -- Feedback input from BUFG
            CLKFBOUT        => clk_fb_out,           -- Feedback output directly to BUFG
            CLKFBOUTB       => open,                 -- Inverted feedback (unused)

            -- Clock Outputs
            CLKOUT0         => clk0_unbuffered,         -- 200 MHz output pin
            CLKOUT0B        => open,                 -- Inverted 200 MHz output (unused)
            CLKOUT1         => clk1_unbuffered,         -- 100 MHz output pin
            CLKOUT1B        => open,
            CLKOUT2         => clk2_unbuffered,
            CLKOUT2B        => open,
            CLKOUT3         => clk3_unbuffered,
            CLKOUT3B        => open,
            CLKOUT4         => open,
            CLKOUT5         => open,
            CLKOUT6         => open,

            -- Control and Status Ports
            CLKFBSTOPPED    => open,
            CLKINSTOPPED    => open,
            LOCKED          => locked,               -- Active high lock signal
            PWRDWN          => '0',                  -- Power down (active high)
            RST             => reset,                -- Asynchronous Reset

            -- Dynamic Reconfiguration Ports (DRP) - Unused
            DADDR           => (others => '0'),
            DCLK            => '0',
            DEN             => '0',
            DI              => (others => '0'),
            DO              => open,
            DRDY            => open,
            DWE             => '0',

            -- Fine Phase Shift Ports - Unused
            PSCLK           => '0',
            PSEN            => '0',
            PSINCDEC        => '0',
            PSDONE          => open
        );
	-- CLKOUT0 = 800 / 8   = 100 MHz
    -- CLKOUT1 = 800 / 32  = 25 MHz (Πλησιέστερο στο 24.8832 χωρίς fractional MMCM)
    -- CLKOUT2 = 800 / 33  = 24.24 MHz (Πλησιέστερο στο 24.0734)
    -- CLKOUT3 = 800 / 128 = 6.25 MHz (Το χαμηλότερο δυνατό για PLL: DIV=128)

    -- Instantiation του αντικειμένου
--    pll_inst : PLLE2_ADV
--    generic map (
--        CLKIN1_PERIOD  => 10.0,   -- 100 MHz input
--        CLKFBOUT_MULT  => 8,      -- VCO = 800 MHz
--        DIVCLK_DIVIDE  => 1,
--        CLKOUT0_DIVIDE => 8,      -- 100 MHz
--        CLKOUT1_DIVIDE => 32,     -- ~25 MHz 
--        CLKOUT2_DIVIDE => 33,     -- ~24.24 MHz
--        CLKOUT3_DIVIDE => 128     -- 6.25 MHz
--    )
--    port map (
--        CLKIN1   => clk_in,
--        CLKFBIN  => clk_fb,
--        CLKFBOUT => clk_fb,
--        CLKOUT0  => clk0_unbuffered,
--        CLKOUT1  => clk1_unbuffered,
--        CLKOUT2  => clk2_unbuffered,
--        CLKOUT3  => clk3_unbuffered,
--        LOCKED   => locked,
--        RST      => reset,
--        PWRDWN   => '0'
--    );
--    clk_100 <= clk0_unbuffered;
--    clk_24_88 <= clk1_unbuffered;
--    clk_24_07<= clk2_unbuffered;
--    clk_6_25 <= clk3_unbuffered;
end architecture;

