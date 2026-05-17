library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use work.vt100_pkg.all;


entity fontrom is
	GENERIC(
	   DATAWIDTH : positive := 13;
	   RAM_WIDTH  : NATURAL := 8;
	   RAM_DEPTH  : NATURAL := 8192;
	   FONTROM_FILE: string := "/Users/chpap/Documents/VHDL/vhdl_ghdl_examples/dc011/VGA-ROM-8x16.hex"
	);
	port
	(
		addr_i  : in std_logic_vector (DATAWIDTH - 1 downto 0);
		clk	: in std_logic  := '1';
	        data_o  : out std_logic_vector (7 downto 0)
	);
end fontrom;


architecture syn of fontrom is
 -- component generics
        constant ADDR_A_WIDTH : positive := DATAWIDTH;
        constant ADDR_B_WIDTH : positive := DATAWIDTH;
        constant DATA_A_WIDTH : positive := 8;
        constant DATA_B_WIDTH : positive := 8;

	signal sub_wire0	: std_logic_vector (7 downto 0);
	signal sub_wire1	: std_logic_vector (7 downto 0);


signal ROM : fontrom_type := init_fontrom_hex(FONTROM_FILE);


begin
    process(clk)
    begin
        if rising_edge(clk) then
            data_o  <= ROM(to_integer(unsigned(addr_i)));
        end if;
    end process;

end syn;
