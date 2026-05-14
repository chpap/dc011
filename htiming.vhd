library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.dc0112_pkg.all;


entity htiming is
    port (
        clk_i: in  std_ulogic; -- input clock signal
        extra_clk_i: in  std_ulogic; -- input clock signal
        rst_i : in  std_ulogic; -- reset signal
        div_in : in std_ulogic_vector(8 downto 0);
        mode80_i: in  std_ulogic; 
        addr_cnt_on_o : out  std_ulogic;
        n_hdrive_o: out  std_ulogic;
        hblank_o : out  std_ulogic
    );
end entity htiming;

architecture rtl of htiming is
    signal    hblank_tmp :  std_ulogic := '0';
begin
    process_hdrive: process (div_in) is
    begin
      n_hdrive_o <= not div_in(8) or ((div_in(4) and div_in(5)) and  (not div_in(6) and  not div_in(7)));
    end process process_hdrive;

    process_hblank: process (div_in) is
    begin
     if rising_edge(div_in(1)) then
       if (div_in(8) and not div_in(7) and div_in(6) and (nand div_in(6 downto 4))) then
         hblank_tmp <= '1';
       else
         hblank_tmp <= '0';
       end if;
     end if;
    end process process_hblank; 
    hblank_o <= hblank_tmp and not rst_i;

    process_addr_cnt_on: process (extra_clk_i) is
      variable prev_val_addr_cnt: std_ulogic:= '0';
    begin
     if falling_edge(extra_clk_i) then
         if (and (div_in(8) & not div_in(7) & div_in(6 downto 4)))   then
           prev_val_addr_cnt := addr_cnt_on_o;
           addr_cnt_on_o <= '0' when (div_in(8 downto 0) = "101111010" and mode80_i = '1') else -- 
                            '1' when div_in = "101110010" and mode80_i = '1' else
                            '1' when div_in = "101110010" and mode80_i = '0' else
                            '0' when div_in = "101110000" and mode80_i = '0' else
                         prev_val_addr_cnt;
         else
           addr_cnt_on_o <= prev_val_addr_cnt;
         end if;
      end if;
      -- prev_val_addr_cnt := addr_cnt_on;
    end process process_addr_cnt_on; 
end architecture rtl;
