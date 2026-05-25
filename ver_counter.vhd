library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.dc0112_pkg.all;


entity ver_counter is
    port (
        clock_2hf_i: in  std_ulogic; -- input clock signal
        clock_h5_i: in  std_ulogic; -- input clock signal
        hcdiv_i : in std_ulogic_vector(8 downto 0);
        rst_i : in  std_ulogic; -- reset signal
        interlaced_i: in  std_ulogic;
        hertz60_i: in  std_ulogic;
        n_vrst_o : out  std_ulogic;
        div_o : out std_ulogic_vector(9 downto 0 )
    );
end entity ver_counter;


architecture rtl of ver_counter is
    signal div: std_ulogic_vector(9 downto 0) := (others => '0'); 
    signal maxcount: integer range 1 to 630;
begin
    maxcount <= 524 when (hertz60_i = '1' and interlaced_i = '0') else 525  when (hertz60_i = '1' and interlaced_i = '1') else 630 when (hertz60_i = '0' and interlaced_i = '0') else 629;
    vert_div: process(clock_2hf_i,rst_i)
    begin
	if rst_i = '1' then
	  div <= (others => '0');
        elsif rising_edge(clock_2hf_i) then
	  if( div = std_ulogic_vector(to_unsigned(maxcount - 1,10))) then
	     div <= (others => '0');
          else
	     div <= div + 1;
    	  end if;
       end if;
    end process vert_div;

    div_o(9 downto 0) <= div;
    n_vrst_o <=  ((nor hcdiv_i(6 downto 4)) and (hcdiv_i(7) xor hcdiv_i(8))) 
		 nand 
		 (nor div(9 downto 6)and(and div(5 downto 1) ));
		
end architecture rtl;
