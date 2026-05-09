library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.dc0112_pkg.all;


entity hor_counter is
    port (
        char_clk : in  std_ulogic; -- input clock signal
        mode80: in std_ulogic;
        i_rst : in  std_ulogic; -- reset signal
        clk_extra: in  std_ulogic;
        clock_2hf: out std_ulogic; 
        clock_hf: out std_ulogic; 
        div_out : out std_ulogic_vector(8 downto 0);
        LBA : out std_ulogic_vector(7 downto 0)
    );
end entity hor_counter;


architecture rtl of hor_counter is
    signal div1: std_ulogic_vector(2 downto 0);
    signal div2: std_ulogic_vector(4 downto 0);
    signal div1_tmp: std_ulogic_vector(2 downto 0) := (others => '0');
    signal div2_tmp: std_ulogic_vector(4 downto 0) := (others => '0');
    signal div3_tmp: std_ulogic_vector(1 downto 0) := (others => '0');
    signal div_out_delayed : std_ulogic_vector(8 downto 0);
    signal maxcount: integer range 1 to 5;
    signal div1_out: std_ulogic := '0';
    signal div2_out: std_ulogic := '0';
    signal div3_out: std_ulogic := '0';
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
        o_counter => div1_tmp,
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
        o_counter => div2_tmp,
        o_clk => div2_out

    );
    clk_divider_3 : clk_divider
    generic map(
        g_FREQ_DIV_MAX => 2
    )
    port map (
        i_clk => div2_out,
        i_rst => i_rst,
        i_freq_div => 2,
        o_counter => div3_tmp,
        o_clk => div3_out

    );
    delay_inst: delay
    generic map(CYCLES => 4,
            WIDTH => 9)
    port map(clk => clk_extra,
         rst => i_rst,
         en  => '1',
         --input => ""&char_clk_tmp, 
         --input => ""&counter(3), 
         input => div_out_delayed, 
         -- output(0) => char_clk_delayed(i)
         output => div_out
    );
    div_out_delayed(2 downto 0) <= div1;
    div_out_delayed(7 downto 3) <= div2;
    -- div_out(8) <= div3_out;
    div_out_delayed(8) <= div3_tmp(0);
   
    clock_2hf <= div2_out;
    clock_hf <= div3_out;
    LBA(7) <= div_out(8);
    LBA(6) <= div_out(6);
    LBA(5) <= div_out(5) or (div_out(7) and div_out(1));
    LBA(4) <= not div_out(4);
    LBA(3) <= div_out(3);
    LBA(2) <= div_out(7);
    LBA(1) <= (div_out(0) nor div_out(1)) or (div_out(7) and div_out(1));
    LBA(0) <= div_out(0) or (div_out(7) and div_out(1)); 
    --LBA(1) <= div_out(1) or (div_out(7) and div_out(0));
    --LBA(0) <= (div_out(0) nor div_out(1)) or (div_out(7) and div_out(0));
    div1 <= div1_tmp(2 downto 0);
    div2 <= div2_tmp(4 downto 0);
    
end architecture rtl;
