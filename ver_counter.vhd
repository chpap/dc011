library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity ver_counter is
    port (
        clock_2hf: in  std_ulogic; -- input clock signal
        i_rst : in  std_ulogic; -- reset signal
        mode80: in  std_ulogic;
        interlaced: in  std_ulogic;
        hertz60: in  std_ulogic;
        n_vrst : out  std_ulogic;
        div_out : out std_ulogic_vector(0 to 9)
    );
end entity ver_counter;


architecture rtl of ver_counter is
    signal div1: std_ulogic_vector(0 to 2) := "000";
    signal div2: std_ulogic_vector(0 to 4) := "00000";
    signal maxcount: integer range 1 to 5;
    signal div1_out: std_logic := '0';
    signal div2_out: std_logic := '0';
    signal div3_out: std_logic := '0';
    signal tmp: std_logic;
    signal LBA_tmp : std_ulogic_vector(0 to 7) := "00000000";
    component clk_divider is
    generic (
        g_FREQ_DIV_MAX : positive := 7 -- maximum available frequency divisor value
    );
    port (
        i_clk : in std_ulogic; -- input clock signal
        i_rst : in std_ulogic; -- reset signal
        -- i_clk frequency is divided by value of this number, <o_clk_freq>=<i_clk_freq>/i_freq_div
        i_freq_div : in  integer range 1 to g_FREQ_DIV_MAX;
        o_counter    : out std_ulogic_vector(0 to 5);
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
begin
    
    
end architecture rtl;
