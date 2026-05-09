--------------------------------------------------------------------------------
-- Copyright (C) 2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:    independent
--------------------------------------------------------------------------------
-- Description:
--     This source file represents a generic implementation of a clock divider
--     with a fixed frequency divisor.
--------------------------------------------------------------------------------
-- Notes:
--     1. Period of output o_clk starts with '1' value, followed by '0'.
--     2. When the g_FREQ_DIV is set as an odd number, the o_clk will have '1'
--        value one n_clk_i period shorter than '0' value per o_clk period.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;



architecture rtl of static_clk_divider is 
   signal o_clk_TMP: std_ulogic := '0';
begin
    
    -- Description:
    --     Perform n_clk_i frequency division by counting and create the final o_clk signal.
    divide_i_clk_freq : process (n_clk_i,i_rst) is
        variable r_i_clk_counter : integer range 1 to g_FREQ_DIV := 1; -- internal n_clk_i counter
    begin
        if rising_edge(n_clk_i) then
            -- need to reset the r_i_clk_counter and begin the new o_clk period
            if (i_rst = '1' or r_i_clk_counter = g_FREQ_DIV) then
                o_clk_TMP           <= '1';
                r_i_clk_counter := 1;
            else
                
                if (r_i_clk_counter = (g_FREQ_DIV / 2)) then -- half of the o_clk period
                    o_clk_TMP <= '0';
                end if;
                
                r_i_clk_counter := r_i_clk_counter + 1; -- counting rising edges
                
            end if;
        end if;
    end process divide_i_clk_freq;
    o_clk <= o_clk_TMP when i_rst = '1' else '1';
    
end architecture rtl;
