--------------------------------------------------------------------------------
-- Copyright (C) 2016-2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:    independent
--------------------------------------------------------------------------------
-- Description:
--     This source file represents a generic implementation of a clock divider.
--     It supports to dynamically change frequency divisor, including 1 value.
--     While changing i_freq_div value, there does not exist an interval, where
--     output clock period is not defined one of the assigned i_freq_div values.
--------------------------------------------------------------------------------
-- Notes:
--     1. For static clock divide, use static_clk_divider as it has lower
--        requirements of hardware resources.
--     2. Period of output o_clk starts with '1' value, followed by '0'.
--     3. When it is not possible to perform clock frequency division without
--        a remainder, the o_clk will have '1' value one i_clk period shorter
--        than '0' value per o_clk period.
--     4. To get the most effective resource optimization, choose g_FREQ_DIV_MAX
--        equal to (2^n)-1.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.dc0112_pkg.all;


architecture rtl of clk_divider is
    signal rst_count: std_ulogic := '0';
    signal r_divided_i_clk    : std_ulogic := '0'; -- value of i_clk based on counter method
    signal r_divided_i_clk_r    : std_ulogic := '0';
    signal r_divided_i_clk_c    : std_ulogic := '0';
    signal half_period: std_ulogic := '0';
    signal o_counter_tmp  : std_ulogic_vector(BIT_WIDTH -1 downto 0) := (others => '0');
begin
    process(i_clk) begin
	    if o_counter_tmp = std_ulogic_vector(to_unsigned(i_freq_div-1,4)) then
		    o_counter_tmp <= (others => '0');
	    else
		    o_counter_tmp <= o_counter_tmp + 1;
	    end if;
    end process;
    o_clk <=  r_divided_i_clk;
    o_counter <= o_counter_tmp;
 --   r_divided_i_clk <= nor (o_counter xor std_logic_vector(to_unsigned(i_freq_div,BIT_WIDTH-1)));
    rst_count <= nor (o_counter_tmp xor std_logic_vector(to_unsigned(i_freq_div,BIT_WIDTH)));
    half_period <=  nor (o_counter_tmp xor std_logic_vector(to_unsigned((i_freq_div-1)/2,BIT_WIDTH)));
    -- Description:
    --     Performs i_clk frequency division, outputs need to be composed to get the final clock.
    divide_i_clk_freq : process (i_clk) is
        -- register to store internally i_freq_div value in a time
        variable r_freq_div : integer range 1 to g_FREQ_DIV_MAX;
    begin
--   -- #report "BITs      " & to_string(o_counter_tmp'length);
        if (rising_edge(i_clk)) then
           if half_period = '1' then
              r_divided_i_clk_c <= '0';
              --half_period <= '0';
           end if;
            -- need to reset the r_i_clk_counter and begin the new o_clk period
            --if (i_rst = '1' or o_counter_tmp = std_ulogic_vector(to_unsigned( r_freq_div - 1,BIT_WIDTH))) then
            if (i_rst = '1' or o_counter_tmp = r_freq_div - 1) then
                r_divided_i_clk_c <= '1'; -- when i_rst is '1', then final clock should be '0'
                r_freq_div      := i_freq_div; -- internal register to store a reference value
            end if;
        end if;
    end process divide_i_clk_freq;
    --r_divided_i_clk <= r_divided_i_clk_c and r_divided_i_clk_r;
    r_divided_i_clk <= r_divided_i_clk_c when not half_period else '0';
end architecture rtl;
    

