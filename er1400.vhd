library ieee;
use ieee.std_logic_1164.all;
--use work.xilinx_block_ram_pkg.all;


entity er1400 is
	port
	(
		data_i	: in std_logic;
		clk	: in std_logic  := '1';
		c_i     : in std_logic_vector (2 downto 0)
	);
end er1400;


architecture syn of er1400 is
 -- component generics
begin
end syn;

