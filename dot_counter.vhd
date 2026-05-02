library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity dot_counter is
    -- generic (
    --    -- frequency divisor, <o_clk_freq>=<i_clk_freq>/g_FREQ_DIV
    --    g_FREQ_DIV : integer range 2 to integer'high := 5
    --);
    port (
        dot_clk_s : in  std_ulogic; -- input clock signal
        mode80: in std_ulogic;
        i_rst : in  std_ulogic; -- reset signal
       
        char_clk : out std_ulogic;
        write_lb : out std_ulogic;
        clk80_half: out std_ulogic;
        dot_div : out std_ulogic_vector(0 to 3)
    );
end entity dot_counter;


architecture rtl of dot_counter is
    signal counter: std_logic_vector(0 to 3) := "0000";
    signal maxcounter: std_logic_vector(0 to 3);
    signal maxcount: integer range 1 to 10;
begin
   -- process(i_rst)
   -- begin
   --    counter <= "0000";
   -- end process;
   maxcount <= 10 when mode80 = '1' else 9;
    
    -- Description:
    divide_i_clk_freq : process (dot_clk_s,i_rst) is
    begin
        if (rising_edge(dot_clk_s)) then
            -- need to reset the r_i_clk_counter and begin the new o_clk period
            if (i_rst = '1' or counter = std_logic_vector(to_unsigned(maxcount-1,4))) then
                counter <= "0000";
            else
                counter <= counter + 1;
            end if;
        end if;
    end process divide_i_clk_freq;
    -- maxcounter std_logic_vector(to_unsigned(maxcount,4));
    dot_div <= std_logic_vector(to_unsigned(maxcount,4));
    write_lb <= not counter(1);
    char_clk <= not counter(0);
    clk80_half <= not counter(3);
    
end architecture rtl;
