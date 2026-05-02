library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity htiming is
    port (
        i_clk: in  std_ulogic; -- input clock signal
        extra_clk: in  std_ulogic; -- input clock signal
        i_rst : in  std_ulogic; -- reset signal
        div_in : in std_ulogic_vector(0 to 8);
        mode80: in  std_ulogic; 
        addr_cnt_on : out  std_ulogic;
        n_hdrive: out  std_ulogic;
        hblank : out  std_ulogic
    );
end entity htiming;


architecture rtl of htiming is
    signal hblank_tmp: std_ulogic := '0';
    signal hblank_tmp_prev: std_ulogic := '0';
    signal hblank_tmp_in: std_ulogic_vector(0 downto 0) := "0";
    signal hblank_tmp_out: std_ulogic_vector(0 downto 0) := "0";
    signal d0: std_ulogic;
    signal d1: std_ulogic;
    signal d2: std_ulogic;
    signal d3: std_ulogic;
    signal d4: std_ulogic;
    signal d5: std_ulogic;
    signal d6: std_ulogic;
    signal d7: std_ulogic;
    signal d8: std_ulogic;
    component delay is
    generic(CYCLES : natural := 8;
            WIDTH  : positive := 16);
    port(clk    : in  std_logic;
         rst    : in  std_logic;
         en     : in  std_logic;
         input  : in  std_logic_vector(WIDTH-1 downto 0);
         output : out std_logic_vector(WIDTH-1 downto 0));
    end component;
begin
--    delay_inst: delay
--    generic map(CYCLES => 7,
--            WIDTH => 1)
--    port map(clk => extra_clk,
--         rst => i_rst,
--         en  => '1',
--         input => hblank_tmp_in, 
--         output => hblank_tmp_out
--    );
    process1: process (i_rst,i_clk,d1) is
    begin
    hblank_tmp_prev <= hblank_tmp;
    if (i_rst = '1' and i_rst'event ) then

       n_hdrive <= '0';
 --      hblank <= '0';
 --      hblank_tmp_in <= "0";
 --      hblank_tmp_out <= "0";
 --      hblank_tmp <= '0';
    end if;
    n_hdrive <= not div_in(8) or div_in(7);
   end process; 
    process2: process (i_rst,d1,div_in) is
    begin
    if (i_rst = '1' and i_rst'event ) then
       hblank_tmp_in <= "0";
    end if;
--    --if d0'event and d1 = '0' then
--    --   hblank_tmp_in <= "1";
--    --end if;
     if rising_edge(d1) then
       if div_in = "010100001" then
         hblank_tmp <= '1';
       elsif  div_in = "010111001" then
         hblank_tmp <= '0';
      -- end if;
      --elsif falling_edge(d1) then
      -- if  div_in = "100000101" then
      --   hblank_tmp <= '0';
        end if;
      end if;
   end process; 
   --hblank_tmp_in(0);
   hblank <= hblank_tmp;
   d0 <= div_in(0);
   d1 <= div_in(1);
   d2 <= div_in(2);
   d3 <= div_in(3);
   d4 <= div_in(4);
   d5 <= div_in(5);
   d6 <= div_in(6);
   d7 <= div_in(7);
   d8 <= div_in(8);
end architecture rtl;
