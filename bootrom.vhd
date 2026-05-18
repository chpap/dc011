library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use work.vt100_pkg.all;


entity bootrom is
	GENERIC(
	   DATAWIDTH : positive := 13;
	   RAM_WIDTH  : NATURAL := 8;
	   RAM_DEPTH  : NATURAL := 8192;
           BOOTROM_FILE: string := "roms/vt100.rom.hex"
	);
	port
	(
		addr_i  : in std_logic_vector (DATAWIDTH - 1 downto 0);
		clk	: in std_logic  := '1';
	        data_o  : out std_logic_vector (7 downto 0)
	);
end bootrom;


architecture syn of bootrom is
 -- component generics
        constant ADDR_A_WIDTH : positive := DATAWIDTH;
        constant ADDR_B_WIDTH : positive := DATAWIDTH;
        constant DATA_A_WIDTH : positive := 8;
        constant DATA_B_WIDTH : positive := 8;

	signal sub_wire0	: std_logic_vector (7 downto 0);
	signal sub_wire1	: std_logic_vector (7 downto 0);


--type rom_type is array (0 to RAM_DEPTH - 1)
--  of std_logic_vector(RAM_WIDTH - 1 downto 0);
-- subtype word_t  is std_logic_vector(ram_width - 1 downto 0);  
--LXI D, 3001H   // 11 01 30

    
--    -- Εδώ γίνεται η κλήση της συνάρτησης για την αρχικοποίηση
--signal ROM : bootrom_type:= (
--    0      => x"21",
--    1      => x"00",
--    2      => x"00",
--    3      => x"11",
--    4      => x"01",
--    5      => x"30",
--    6      => x"7e",
--    7      => x"23",
--    8      => x"7d",
--    9      => x"bb",
--    10      => x"c2",
--    11      => x"06",
--    12      => x"00",
--    13      => x"7c",
--    14      => x"ba",
--    15      => x"c2",
--    16      => x"06",
--    17      => x"00",
--    18      => x"c3",
--    19      => x"00", --
--    20      => x"00",
--    others => x"00"    -- Όλες οι υπόλοιπες 8189 θέσεις γίνονται 00
--);
--    21 00 00 11 01 30 7E 23 7D BB C2 06 01 7C BA C2 06 01 C3 00 01
signal ROM : bootrom_type := init_bootrom_hex(BOOTROM_FILE);


begin
    process(clk)
    begin
        if rising_edge(clk) then
            data_o  <= ROM(to_integer(unsigned(addr_i)));
        end if;
    end process;

end syn;
