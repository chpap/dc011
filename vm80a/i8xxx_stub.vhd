library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i8xxx_stub is

   port( clk_i : in std_logic;
      clk24_i    : in  std_logic;
      pin_a     : out std_logic_vector(15 downto 0);
      pin_d     : inout std_logic_vector(7 downto 0);
      pin_hold  : in  std_logic;
      pin_hlda  : out std_logic;
      pin_ready : in  std_logic;
      pin_wait  : out std_logic;
      pin_int   : in  std_logic;
      pin_inte  : out std_logic;
      pin_dbin  : out std_logic;
      pin_wr_n  : out std_logic;
      n_reset_i : in std_logic;
      n_stsb_o  : out std_logic);

end i8xxx_stub;
architecture rtl of i8xxx_stub is
   component i8xxx is
   port( clk_i : in std_logic;
      clk24_i    : in  std_logic;
      pin_a     : out std_logic_vector(15 downto 0);
      pin_d     : in std_logic_vector(7 downto 0);
      pin_hold  : in  std_logic;
      pin_hlda  : out std_logic;
      pin_ready : in  std_logic;
      pin_wait  : out std_logic;
      pin_int   : in  std_logic;
      pin_inte  : out std_logic;
      pin_dbin  : out std_logic;
      pin_wr_n  : out std_logic;
      n_reset_i : in std_logic;
      n_stsb_o  : out std_logic);
   end component;
begin
   i8xxx_inst: i8xxx port map( clk_i => clk_i,
   clk24_i => clk24_i,
   pin_a => pin_a,
   pin_d => pin_d ,-- data bus inouts
   pin_hold => pin_hold,
   pin_hlda => pin_hlda,
   pin_ready => pin_ready,
   pin_wait => pin_wait,
   pin_int => pin_int,
   pin_inte => pin_inte, 
   pin_dbin => pin_dbin,
   pin_wr_n => pin_wr_n,
   n_reset_i => n_reset_i,
   n_stsb_o => n_stsb_o);

end rtl;
