library ieee;
use ieee.std_logic_1164.all;
use work.xilinx_block_ram_pkg.all;


entity sram is
	GENERIC(
	   DATAWIDTH : positive := 10
	);
	port
	(
		addr_i  : in std_logic_vector (DATAWIDTH - 1 downto 0);
		clk	: in std_logic  := '1';
		data_i	: in std_logic_vector (7 downto 0);
		wren_i	: in std_logic ;
	        data_o  : out std_logic_vector (7 downto 0)
	);
end sram;


architecture syn of sram is
 -- component generics
        constant addr_a_width : positive := DATAWIDTH;
        constant addr_b_width : positive := DATAWIDTH;
        constant DATA_A_WIDTH : positive := 8;
        constant DATA_B_WIDTH : positive := 8;

	signal sub_wire0	: std_logic_vector (7 downto 0);
	signal sub_wire1	: std_logic_vector (7 downto 0);
begin
   bram : xilinx_block_ram_dual_port
      generic map (
         ADDR_A_WIDTH => ADDR_A_WIDTH,
         ADDR_B_WIDTH => ADDR_B_WIDTH,
         DATA_A_WIDTH => DATA_A_WIDTH,
         DATA_B_WIDTH => DATA_B_WIDTH)
      port map (
         addr_a => addr_i,
         addr_b => addr_i,
         din_a  => data_i,
         din_b  => data_i,
         dout_a => sub_wire0,
         dout_b => sub_wire1,
         we_a   => wren_i,
         we_b   => wren_i,
         en_a   => '1',
         en_b   => '1',
         ssr_a  => '0',
         ssr_b  => '0',
         clk_a  => clk,
         clk_b  => clk);
	 data_o <= sub_wire0(7 DOWNTO 0);

end syn;

