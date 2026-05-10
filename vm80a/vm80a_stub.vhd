library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vm80a_stub is

  port (clk_i      : in  std_logic;
        clk_f1_i    : in  std_logic;
        clk_f2_i    : in  std_logic;
        reset_i    : in  std_logic;
        ready_i    : in  std_logic;
        int_i      : in  std_logic;
        nnn_i      : in  std_logic_vector(2 downto 0);
        data_i     : in  std_logic_vector(7 downto 0);
        port_i     : in  std_logic_vector(7 downto 0);
        port_rdy_i : in  std_logic;
        inta_o     : out std_logic;
        sel_o      : out std_logic;
        nwr_o      : out std_logic;
        addr_o     : out std_logic_vector(15 downto 0);
        data_o     : out std_logic_vector(7 downto 0);
        port_o     : out std_logic_vector(7 downto 0);
        port_nwr_o : out std_logic;
        port_sel_o : out std_logic_vector(7 downto 0)
        );

end vm80a_stub;
architecture rtl of vm80a_stub is
   signal pin_d: std_logic_vector(7 downto 0);
   component vm80a is
	   port( pin_clk : in std_logic;
            pin_f1    : in  std_logic;
            pin_f2    : in  std_logic;
            pin_reset : in  std_logic;
            pin_a     : out std_logic_vector(15 downto 0);
            pin_d     : inout std_logic_vector(7 downto 0);
            pin_hold  : in  std_logic;
            pin_hlda  : out std_logic;
            pin_ready : in  std_logic;
            pin_wait  : out std_logic;
            pin_int   : in  std_logic;
            pin_inte  : out std_logic;
            pin_sync  : out std_logic;
            pin_dbin  : out std_logic;
            pin_wr_n  : out std_logic
	       );
   end component;
begin
   vm80a_inst: vm80a port map(
   pin_clk => clk_i,
   pin_f1 => clk_f1_i,
   pin_f2 => clk_f2_i,
   pin_reset => reset_i,
   pin_int => int_i,
   pin_a => open,
   pin_d => pin_d ,-- data bus inouts
   pin_hold => '0',
   pin_hlda => open,
   pin_ready => '0',
   pin_wait => open,
   pin_inte => open, 
   pin_sync => open,
   pin_dbin => open,
   pin_wr_n => open);

end rtl;
