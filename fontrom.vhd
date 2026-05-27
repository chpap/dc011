library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use work.vt100_pkg.all;


entity fontrom is
	GENERIC(
	   DATAWIDTH : positive := 11;
	   FONTROM_FILE: string := "/Users/chpap/Documents/VHDL/vhdl_ghdl_examples/dc011/VGA-ROM-8x16.hex"
	);
	port
	(
		addr_i  : in std_logic_vector (DATAWIDTH - 1 downto 0);
	        data_o  : out std_logic_vector (7 downto 0)
	);
end fontrom;


architecture syn of fontrom is
 -- component generics
signal ROM : fontrom_type := init_fontrom_hex(FONTROM_FILE);

begin
    data_o  <= ROM(to_integer(unsigned(addr_i)));

end syn;
