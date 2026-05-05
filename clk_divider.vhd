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

entity clk_divider is
    generic (
        g_FREQ_DIV_MAX : positive := 7; -- maximum available frequency divisor value
        constant BIT_WIDTH : integer := integer(ceil(log2(real(g_FREQ_DIV_MAX + 1))))
    );
    port (
        i_clk : in std_ulogic; -- input clock signal
        i_rst : in std_ulogic; -- reset signal
        
        -- i_clk frequency is divided by value of this number, <o_clk_freq>=<i_clk_freq>/i_freq_div
        i_freq_div : in  integer range 1 to g_FREQ_DIV_MAX;
        o_counter    : out std_ulogic_vector(BIT_WIDTH - 1 downto 0);
        o_clk      : out std_ulogic -- final output clock;
    );
end entity clk_divider;


architecture rtl of clk_divider is
    signal rst_count: std_ulogic := '0';
    signal r_use_direct_i_clk : std_ulogic := '0'; -- force to use direct i_clk input as output clock
    signal r_divided_i_clk    : std_ulogic := '0'; -- value of i_clk based on counter method
    signal half_period: std_ulogic := '0';

component counter10b_ripple is
    generic (
        COUNTBITS: positive := BIT_WIDTH; -- maximum available frequency divisor value
        g_MAX_COUNT: positive := g_FREQ_DIV_MAX
    );
    port (
        i_clk : in std_ulogic; -- input clock signal
        i_rst : in std_ulogic; -- reset signal
        o_counter    : out std_ulogic_vector(COUNTBITS - 1 downto 0)
    );
end component;
begin
    counter10b_inst : counter10b_ripple
    generic map(
        COUNTBITS => BIT_WIDTH,
        g_MAX_COUNT => i_freq_div
    )
    port map(
       i_clk => i_clk,
       i_rst => rst_count,
       o_counter => o_counter
    );
     
    -- switch between direct i_clk and r_divided_i_clk
    o_clk <= i_clk when r_use_direct_i_clk = '1' else r_divided_i_clk;
 --   r_divided_i_clk <= nor (o_counter xor std_logic_vector(to_unsigned(i_freq_div,BIT_WIDTH-1)));
    rst_count <= nor (o_counter xor std_logic_vector(to_unsigned(i_freq_div,BIT_WIDTH)));
    half_period <=  nor (o_counter xor std_logic_vector(to_unsigned((i_freq_div-1)/2,BIT_WIDTH)));

    -- Description:
    --     Performs i_clk frequency division, outputs need to be composed to get the final clock.
    divide_i_clk_freq : process (i_clk,half_period) is
        -- register to store internally i_freq_div value in a time
        variable r_freq_div : integer range 1 to g_FREQ_DIV_MAX;
        -- internal i_clk counter
        -- variable r_i_clk_counter : integer range 1 to g_FREQ_DIV_MAX;
    begin
--   -- #report "BITs      " & to_string(o_counter'length);
       if rising_edge(half_period) then
            r_divided_i_clk <= '0';
            --half_period <= '0';
       end if;
        if (rising_edge(i_clk)) then
            -- need to reset the r_i_clk_counter and begin the new o_clk period
            --if (i_rst = '1' or o_counter = std_ulogic_vector(to_unsigned( r_freq_div - 1,BIT_WIDTH))) then
            if (i_rst = '1' or o_counter = r_freq_div - 1) then
                -- when i_freq_div is 1, then it needs to be used direct i_clk
                if (i_freq_div = 1) then
                    r_use_direct_i_clk <= not i_rst;
                else
                    r_use_direct_i_clk <= '0';
                end if;
                
                r_divided_i_clk <= '1'; -- when i_rst is '1', then final clock should be '0'
                r_freq_div      := i_freq_div; -- internal register to store a reference value
            end if;
        end if;
    end process divide_i_clk_freq;
end architecture rtl;
    

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity counter10b_fast is
    generic (
        COUNTBITS: positive := 10; -- maximum available frequency divisor value
        g_MAX_COUNT: positive := 17
    );
    port (
        i_clk : in std_ulogic; -- input clock signal
        i_rst : in std_ulogic; -- reset signal
        o_counter    : out std_ulogic_vector(COUNTBITS - 1  downto 0)
    );
end entity counter10b_fast;

architecture structural of counter10b_fast  is
  component SR_FF is
    port( 
     D: in std_logic;
     S: in std_logic;
     R: in std_logic;
     CLOCK: in std_logic;
     Q: out std_ulogic;
     n_Q: out std_ulogic
    );
   end component;
    signal q_internal: std_ulogic_vector(COUNTBITS - 1 downto 0);
    signal d_inputs: std_ulogic_vector(COUNTBITS - 1 downto 0) := (others => '0');
    signal and_chain: std_ulogic_vector(COUNTBITS - 1  downto 0) ;
begin
   GEN_COUNTER: for i in 0 to COUNTBITS - 1 generate
      FIRST_BIT: if i = 0 generate
        d_inputs(0) <= not q_internal(0);
        and_chain(0) <= q_internal(0);
      end generate FIRST_BIT;
      THER_BITS: if i > 0 generate
        d_inputs(i) <= q_internal(i) xor and_chain(i - 1);
        and_chain(i) <= and_chain(i - 1) and q_internal(i);
      end generate THER_BITS;
   DFF_INST: SR_FF port map(
     D =>  d_inputs(i),
     S =>  '1',
     R =>  not i_rst,
     CLOCK => i_clk,
     Q => q_internal(i),
     n_Q => open
     );
    end generate GEN_COUNTER;
    o_counter <= q_internal;

end structural;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity counter10b_ripple is
    generic (
        COUNTBITS: positive := 10; -- maximum available frequency divisor value
        g_MAX_COUNT: positive := 17
    );
    port (
        i_clk : in std_ulogic; -- input clock signal
        i_rst : in std_ulogic; -- reset signal
        o_counter    : out std_ulogic_vector(COUNTBITS - 1  downto 0)
    );
end entity counter10b_ripple;

architecture ripple of counter10b_ripple  is
  component SR_FF is
    port( 
     D: in std_logic;
     S: in std_logic;
     R: in std_logic;
     CLOCK: in std_logic;
     Q: out std_ulogic;
     n_Q: out std_ulogic
    );
   end component;
    signal q_internal: std_ulogic_vector(COUNTBITS - 1 downto 0) := (others => '0');
    signal d_inputs: std_ulogic_vector(COUNTBITS - 1 downto 0) := (others => '0');
begin
   GEN_COUNTER: for i in 0 to COUNTBITS - 1 generate
      FIRST_BIT: if i = 0 generate
   --     d_inputs(0) <=  q_internal(0);
   DFF_INST: SR_FF port map(
     D =>  d_inputs(i),
     S =>  '1',
     R =>  not i_rst,
     CLOCK => i_clk,
     Q => q_internal(i),
     n_Q => d_inputs(i)
     );
      end generate FIRST_BIT;
      THER_BITS: if i > 0 generate
   --     d_inputs(i) <= q_internal(i);
   DFF_INST: SR_FF port map(
     D =>  d_inputs(i),
     S =>  '1',
     R =>  not i_rst,
     CLOCK => q_internal(i-1),
     Q => q_internal(i),
     n_Q => d_inputs(i)
     );
      end generate THER_BITS;
    end generate GEN_COUNTER;
    o_counter <= q_internal;

end ripple;
