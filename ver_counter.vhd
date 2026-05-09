library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.dc0112_pkg.all;


entity ver_counter is
    port (
        clock_2hf: in  std_ulogic; -- input clock signal
        clock_h5: in  std_ulogic; -- input clock signal
        hcdiv_in : in std_ulogic_vector(8 downto 0);
        i_rst : in  std_ulogic; -- reset signal
        interlaced: in  std_ulogic;
        hertz60: in  std_ulogic;
        n_vrst : out  std_ulogic;
        div_out : out std_ulogic_vector(9 downto 0 )
    );
end entity ver_counter;


architecture rtl of ver_counter is
    signal div: std_ulogic_vector(9 downto 0) := "0000000000";
    signal maxcount: integer range 1 to 630;
    signal div1_out: std_ulogic := '0';
begin
    maxcount <= 524 when (hertz60 = '1' and interlaced = '0') else 525  when (hertz60 = '1' and interlaced = '1') else 630 when (hertz60 = '0' and interlaced = '0') else 629;
    clk_divider_1 : clk_divider
    generic map(
        g_FREQ_DIV_MAX => 630,
        BIT_WIDTH => 10 
    )
    port map (
        i_clk => clock_2hf,
        i_rst => i_rst,
        i_freq_div => maxcount,
        o_counter => div,
        o_clk => div1_out
    );
    -- div_out(0 to 9) <= reverse_vector(div);
    div_out(9 downto 0) <= div;
    n_vrst <=  not hcdiv_in(8) or  ((hcdiv_in(7) or hcdiv_in(5))  or not hcdiv_in(6)  or (hcdiv_in(4) and hcdiv_in(3)));
    
end architecture rtl;
