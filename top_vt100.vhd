library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use work.dc0112_pkg.all;
use work.vt100_pkg.all;

entity top_vt100  is
    port(clk100: in std_logic;
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
     led: out  std_logic_vector(7 downto 0);
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
end entity;

architecture testbench of top_vt100  is
  signal  clk_100:    std_ulogic :=  '0';
  signal  clk_24_07:    std_ulogic :=  '0';
  signal  clk_24_88:    std_ulogic :=  '0';
  signal  clk_6_25:    std_ulogic :=  '0';
  signal  clk_locked:    std_ulogic :=  '0';
  signal  dot_clock:    std_ulogic;
  signal  segment:    std_logic_vector(7 downto 0);
  signal  debug:    std_logic_vector(31 downto 0);
  type disp_array_t is array (0 to 7) of std_logic_vector(3 downto 0);
  signal  display:    disp_array_t := (others => (others => '0'));
  signal  debug_fb: std_logic_vector(31 downto 0);
  signal  debug_vt100: std_logic_vector(31 downto 0);
  signal maxh: std_ulogic_vector(15 downto 0):= (others => '0');
  signal maxv: std_ulogic_vector(15 downto 0):= (others => '0');

-- synthesis translate_off
  package fb_pkg is new work.x11_pkg
    generic map (
      G_WIDTH  => 800,
      G_HEIGHT => 600
    --G_WIDTH  => 2048,
    --G_HEIGHT => 512
    );
  use fb_pkg.all;

  component fb is
  generic (
    WIDTH  : natural := 800;
    HEIGHT : natural := 600 
  );
  port(
    pixel_clock_i : in std_ulogic;
    rgb_i :in std_ulogic_vector(11 downto 0);
    hsync_i: in std_ulogic;
    vsync_i: in std_ulogic;
    debug: out std_ulogic_vector(31 downto 0)
      );
  end component;
-- synthesis translate_on

  component clk_plle2 is
  port ( 
    clk_100    : out std_logic; -- CLKOUT0: 100 MHz
    clk_24_88  : out std_logic; -- CLKOUT1: ~24.8832 MHz
    clk_24_07  : out std_logic; -- CLKOUT2: ~24.0734 MHz
    clk_6_25 : out std_logic; -- CLKOUT3: 6.25 MHz (Lowest)
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in : in STD_LOGIC
  );
  end component;

begin
-- synthesis translate_off
  fb_inst: fb port map(
    pixel_clock_i => dot_clock,
    rgb_i => videor & videog & videob,
    hsync_i => hsync,
    vsync_i => vsync,
    debug => debug_fb
      );
    
-- synthesis translate_on

  plle2_inst: clk_plle2
    port map(clk_100 => clk_100,
    clk_24_88 => clk_24_88,
    clk_24_07 => clk_24_07,
    clk_6_25 => clk_6_25,
    reset => not n_reset_i,
    locked => clk_locked,
    clk_in => clk100
    );

  vt100_inst: vt100
    port map(
     clk100_i => clk100,
     clk24_88_i => clk_24_88,
     clk24_07_i => clk_24_07,
     reset_i => n_reset_i nand clk_locked,
     txd0_o => txd0,
     rxd0_i => rxd0,
     videor_o => videor,
     videog_o => videog,
     videob_o => videob,
     hsync_o => hsync,
     vsync_o => vsync,
     btnc_i => btnc,
     led_o => open,
     kbd_leds_o => kbd_led,
     dot_clock_o => dot_clock,
     ps2_clk => ps2clk,
     ps2_data => ps2data,
     debug_o => debug_vt100
    );

   ca <= segment(7); cb <= segment(6); cc <= segment(5); cd <= segment(4); 
   ce <= segment(3); cf <= segment(2); cg <= segment(1); dp <= segment(0);
   display(0) <= debug(31 downto 28);
   display(1) <= debug(27 downto 24);
   display(2) <= debug(23 downto 20);
   display(3) <= debug(19 downto 16);
   display(4) <= debug(15 downto 12);
   display(5) <= debug(11 downto 8);
   display(6) <= debug(7 downto 4);
   display(7) <= debug(3 downto 0);
   led(0) <=  dot_clock;
   led(1) <=  hsync;
   led(2) <=  clk100;
   led(3) <=  clk_24_07;
   led(4) <=  clk_24_88;
   ------------------
   process(dot_clock)
	   variable counter: std_ulogic_vector(15 downto 0) := (others => '0');
   begin
	   if(rising_edge(dot_clock)) then
	      if(hsync = '1') then
		      counter := (others => '0');
	      else
		      counter := counter + 1;
	      end if;
	      if(counter > maxh) then
		   maxh <= counter;
	      end if;
           end if;
   end process;
   ----------------------
   process(hsync)
	   --variable maxv: std_ulogic_vector(15 downto 0):= (others => '0');
	   variable counter: std_ulogic_vector(15 downto 0) := (others => '0');
   begin
	   if(rising_edge(hsync)) then
	      if(vsync = '1') then
		      counter := (others => '0');
	      else
		      counter := counter + 1;
	      end if;
	   if(counter > maxv ) then
		   maxv <= counter;
	   end if;
           end if;

   end process;
   debug(31 downto 16) <= maxh;
   debug(15 downto 0) <= maxv;

--   debug <= debug_vt100;
-- synthesis translate_off
   --debug <= debug_fb;
-- synthesis translate_on

   SEVEN_DIG_DEC: decod_component
     port map(
        clk  => clk100, 
        A => display(0),
        B => display(1),
        C => display(2),
        D => display(3),
        E => display(4),
        F => display(5),
        G => display(6),
        H => display(7),
        sel_display => an(7 downto 0),
        segment => segment
   );

end;
