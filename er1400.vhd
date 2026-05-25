library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
--use work.xilinx_block_ram_pkg.all;


entity er1400 is
	port
	(
		data_i	: in std_logic;
		data_o	: out std_logic;
		clk_i	: in std_logic  := '1';
		c_i     : in std_logic_vector (2 downto 0)
	);
end er1400;


architecture syn of er1400 is
 -- component generics
   type nvram_type is array (0 to 99) of std_ulogic_vector(13 downto 0);
   shared variable nvram : nvram_type := (others => (others => '0'));
   type t_State is (Standby,Accept_Address, Read, Shift_Data_Out, Erase,Accept_Data, Write, Not_Used );
   signal state : t_State := Standby;
   signal data_buf : std_ulogic_vector(13 downto 0) := (others => '0');
   signal data_o_buf: std_ulogic := '0';
   signal address_buf : std_ulogic_vector(19 downto 0);
   signal address10 : integer range 0 to 9 := 0;
   signal address1 : integer range 0 to 9 := 0;
   signal address : integer range 0 to 99 := 0;
begin

process(clk_i)
begin
  if rising_edge(clk_i) then
    case c_i is
     when "000" => state <= Standby; 
     when "011" => state <= Accept_Address;
     when "100" => state <= Read;
     when "101" => state <= Shift_Data_Out;
     when "010" => state <= Erase;
     when "111" => state <= Accept_Data; 
     when "110" => state <= Write;
     when others => state <= Not_Used; -- Default case (disable all)
    end case;
  end if;
  if rising_edge(clk_i) then
  case state is
    --when Accept_Address => address_buf(counter) <= data_i; counter <= counter - 1;
    --when Accept_Address => address_buf <= std_ulogic_vector(shift_left(unsigned(address_buf),1)) or "0000000000000" & data_i ;
    when Accept_Address => address_buf <= address_buf(19 downto 1)  & data_i ;
    when Read  => data_buf <= nvram(address);
    when Shift_Data_Out => data_o_buf <= data_buf(13) ;data_buf <= std_ulogic_vector(shift_left(unsigned(data_buf),1));
    when Erase => nvram(address) := (others => '0');
    --when Accept_Data => data_buf(counter) <= data_i; counter <= counter - 1;
    --when Accept_Data => data_buf <= std_ulogic_vector(shift_left(unsigned(data_buf),1)) or "0000000000000" & data_i ;
    when Accept_Data => data_buf <= data_buf(13 downto 1) & data_i ;
    when Write => nvram(address) := data_buf;
    when others =>  -- Default case (disable all)
  end case;
  end if;
end process;

  with address_buf(19 downto 10) select
	  address10 <= 0 when "0000000001",
	               1 when "0000000010",
	               2 when "0000000100",
	               3 when "0000001000",
	               4 when "0000010000",
	               5 when "0000100000",
	               6 when "0001000000",
	               7 when "0010000000",
	               8 when "0100000000",
	               9 when "1000000000",
		       0 when others;
  with address_buf(9 downto 0) select
	  address1  <= 0 when "0000000001",
	               1 when "0000000010",
	               2 when "0000000100",
	               3 when "0000001000",
	               4 when "0000010000",
	               5 when "0000100000",
	               6 when "0001000000",
	               7 when "0010000000",
	               8 when "0100000000",
	               9 when "1000000000",
		       0 when others;
   address <= address10 * 10 + address1;
   data_o <= data_o_buf;


end syn;

