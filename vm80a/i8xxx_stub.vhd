library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i8xxx_stub is

   port( clk_i : in std_logic;
      clk24_i    : in  std_logic;
      a_o     : out std_logic_vector(15 downto 0);
      d_i     : in std_logic_vector(7 downto 0);
      d_o     : out std_logic_vector(7 downto 0);
      hold_i  : in  std_logic;
      hlda_o  : out std_logic;
      ready_i : in  std_logic;
      wait_o  : out std_logic;
      int_i   : in  std_logic;
      inte_o  : out std_logic;
      dbin_o  : out std_logic;
      n_wr_o  : out std_logic;
      n_reset_i : in std_logic;
      n_stsb_o  : out std_logic);

end i8xxx_stub;
architecture rtl of i8xxx_stub is
   component i8xxx is
   port( clk_i : in std_logic;
      clk24_i    : in  std_logic;
      a_o     : out std_logic_vector(15 downto 0);
      d_i     : in std_logic_vector(7 downto 0);
      d_o     : out std_logic_vector(7 downto 0);
      hold_i  : in  std_logic;
      hlda_o  : out std_logic;
      ready_i : in  std_logic;
      wait_o  : out std_logic;
      int_i   : in  std_logic;
      inte_o  : out std_logic;
      dbin_o  : out std_logic;
      n_wr_o  : out std_logic;
      n_reset_i : in std_logic;
      n_stsb_o  : out std_logic);
   end component;
begin
   i8xxx_inst: i8xxx port map( clk_i => clk_i,
   clk24_i => clk24_i,
   a_o => a_o,
   d_i => d_i ,
   d_o => d_o ,
   hold_i => hold_i,
   hlda_o => hlda_o,
   ready_i => ready_i,
   wait_o => wait_o,
   int_i => int_i,
   inte_o => inte_o, 
   dbin_o => dbin_o,
   n_wr_o => n_wr_o,
   n_reset_i => n_reset_i,
   n_stsb_o => n_stsb_o);

end rtl;
