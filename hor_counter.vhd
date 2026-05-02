library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity hor_counter is
    -- generic (
    --    -- frequency divisor, <o_clk_freq>=<i_clk_freq>/g_FREQ_DIV
    --    g_FREQ_DIV : integer range 2 to integer'high := 5
    --);
    port (
        char_clk : in  std_ulogic; -- input clock signal
        mode80: in std_ulogic;
        i_rst : in  std_ulogic; -- reset signal
        clock_2hf: out std_ulogic; 
        clock_hf: out std_ulogic; 
        div_out : out std_ulogic_vector(0 to 8);
        LBA : out std_ulogic_vector(0 to 7)
    );
end entity hor_counter;


architecture rtl of hor_counter is
    signal div1: std_ulogic_vector(4 downto 0) := "00000";
    signal div2: std_ulogic_vector(4 downto 0) := "00000";
    signal maxcount: integer range 1 to 5;
    signal div1_out: std_logic := '0';
    signal div2_out: std_logic := '0';
    signal div3_out: std_logic := '0';
    component clk_divider is
    generic (
        g_FREQ_DIV_MAX : positive := 7 -- maximum available frequency divisor value
    );
    port (
        i_clk : in std_ulogic; -- input clock signal
        i_rst : in std_ulogic; -- reset signal
        -- i_clk frequency is divided by value of this number, <o_clk_freq>=<i_clk_freq>/i_freq_div
        i_freq_div : in  integer range 1 to g_FREQ_DIV_MAX;
        o_counter    : out std_ulogic_vector(0 to 4);
        o_clk      : out std_ulogic -- final output clock
    );
    end component;
    component static_clk_divider is
    generic (
        -- frequency divisor, <o_clk_freq>=<i_clk_freq>/g_FREQ_DIV
        g_FREQ_DIV : integer range 2 to integer'high := 5
    );
    port (
        i_clk : in  std_ulogic; -- input clock signal
        i_rst : in  std_ulogic; -- reset signal
        o_clk : out std_ulogic -- final output clock
    );
    end component;
  function reverse_vector (a: in std_logic_vector)
  return std_logic_vector is
    variable result: std_logic_vector(a'RANGE);
    alias aa: std_logic_vector(a'REVERSE_RANGE) is a;
  begin
    for i in aa'RANGE loop
      result(i) := aa(i);
    end loop;
    return result;
  end; -- function reverse_any_vector
begin
   maxcount <= 3 when mode80 = '1' else 5;
    
   -- resetproc: process (i_rst) is
   -- begin
   -- end process resetproc;
    clk_divider_1 : clk_divider
    generic map(
        g_FREQ_DIV_MAX => 5
    )
    port map (
        i_clk => char_clk,
        i_rst => i_rst,
        i_freq_div => maxcount,
        o_counter => div1,
        o_clk => div1_out

    );
    clk_divider_2 : clk_divider
    generic map(
        g_FREQ_DIV_MAX => 17
    )
    port map (
        i_clk => div1_out,
        i_rst => i_rst,
        i_freq_div => 17,
        o_counter => div2,
        o_clk => div2_out

    );
    clk_divider_3 : static_clk_divider
    generic map(
        g_FREQ_DIV => 2
    )
    port map (
        i_clk => div2_out,
        i_rst => i_rst,
        o_clk => div3_out

    );
--    -- Description:
--    divide_1_clk_freq : process (i_rst,char_clk) is
--    begin
--        if (rising_edge(i_rst)) then
--           div1 <= "000";
--           div1_out <= '0';
--        end if;
--        if (rising_edge(char_clk)) then
---- report "test  " & to_hstring(div1);
--            -- need to reset the r_i_clk_counter and begin the new o_clk period
--            if (div1 = std_logic_vector(to_unsigned(maxcount-1,3))) then
--                div1 <= "000";
--                div1_out <= not div1_out;
--            else
--                 div1 <= div1 + 1;
--            end if;
--        end if;
--    end process divide_1_clk_freq;

--    divide_2_clk_freq : process (i_rst,div1_out) is
--    begin
--        if (rising_edge(i_rst)) then
--           div2 <= "00000";
--           div2_out <= '0';
--        end if;
--        if (rising_edge(div1_out)) then
--            -- need to reset the r_i_clk_counter and begin the new o_clk period
--            if (div2 = std_logic_vector(to_unsigned(17-1,5))) then
--                div2 <= "00000";
--                div2_out <= not div2_out;
--            else
--                div2 <= div2 + 1;
--            end if;
--        end if;
--    end process divide_2_clk_freq;
--
--    divide_3_clk_freq : process (i_rst,div2_out) is
--    begin
--        if (i_rst = '1') then
--           div3_out <= '0';
--        end if;
--        if (rising_edge(div2_out)) then
--           div3_out <= not div3_out;
--        end if;
--    end process divide_3_clk_freq;
    div_out(0 to 2) <= reverse_vector(div1(2 downto 0));
    div_out(3 to 7) <= reverse_vector(div2);
    div_out(8) <= div3_out;
   
    clock_2hf <= div2_out;
    clock_hf <= div3_out;
    LBA(7) <= div_out(1);
    LBA(6) <= div_out(0);
    LBA(5) <= div_out(7);
    LBA(4) <= div_out(3);
    LBA(3) <= div_out(4);
    LBA(2) <= div_out(5);
    LBA(1) <= div_out(6);
    LBA(0) <= div_out(8);
    -- maxcounter std_logic_vector(to_unsigned(maxcount,4));
    -- dot_div <= std_logic_vector(to_unsigned(maxcount,4));
    
end architecture rtl;
