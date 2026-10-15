library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
--use work.xilinx_block_ram_pkg.all;


entity ls273 is
	port
	(
		data_i	: in std_logic_vector(7 downto 0);
		data_o	: out std_logic_vector(7 downto 0);
		clk_i	: in std_logic;
		n_clr_i : in std_logic := '1'
	);
end ls273;


architecture syn of ls273 is
 -- component generics
begin

process(clk_i,n_clr_i)
begin
  if(n_clr_i='0') then
	data_o <= (others => '0');
  else
  	if rising_edge(clk_i) then
		data_o <= data_i;
  	end if;
  end if;
end process;
end syn;

