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
        div_in : in std_ulogic_vector(8 downto 0);
        mode80: in  std_ulogic; 
        addr_cnt_on : out  std_ulogic;
        n_hdrive: out  std_ulogic;
        hblank : out  std_ulogic
    );
end entity htiming;

architecture rtl of htiming is
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
    process_hdrive: process (div_in) is
    begin
      n_hdrive <= not div_in(8) or ((div_in(4) and div_in(5)) and  (not div_in(6) and  not div_in(7)));
    end process process_hdrive;

    process_hblank: process (i_rst,div_in) is
    begin
      if (i_rst = '1' and i_rst'event ) then
         hblank <= '0';
      end if;
     if rising_edge(div_in(1)) then
       if (div_in(8) and not div_in(7) and div_in(6) and (nand div_in(6 downto 4))) then
         hblank <= '1';
       else
         hblank <= '0';
       end if;
     end if;
    end process process_hblank; 

    process_addr_cnt_on: process (extra_clk,div_in) is
      variable prev_val_addr_cnt: std_ulogic:= '0';
    begin
     if extra_clk'EVENT and extra_clk = '0' then
         if (and (div_in(8) & not div_in(7) & div_in(6 downto 4)))   then
           prev_val_addr_cnt := addr_cnt_on;
           addr_cnt_on <= '0' when (div_in(8 downto 0) = "101111010" and mode80 = '1') else -- 
                            '1' when div_in = "101110010" and mode80 = '1' else
                            '1' when div_in = "101110010" and mode80 = '0' else
                            '0' when div_in = "101110000" and mode80 = '0' else
                         prev_val_addr_cnt;
         else
           addr_cnt_on <= prev_val_addr_cnt;
         end if;
      end if;
      -- prev_val_addr_cnt := addr_cnt_on;
    end process process_addr_cnt_on; 
end architecture rtl;
