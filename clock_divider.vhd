-- Filename: clock_divider_struct.vhd
-- Created by HDL-SCHEM-Editor at Mon Jun  2 17:11:38 2025
--
-- clock_divider algorithm
-- =======================
-- To make this description better readable the following abbreviations are used:
-- S = period in unit time of the incoming system clock clk_i
-- C = period in unit time of the outgoing clock clk_divided_o
-- I = clock_period_int_part_i
-- N = clock_period_fract_part_nominator_i
-- D = clock_period_fract_part_denominator_i
--
-- The new clock shall have the period:
-- C = (I + N/D) * S
-- But the used counter can only create too short or too long periods:
-- C_short =  I * S
-- C_long  = (I + 1) * S
-- When using C_short, the error is: I*S - (I + N/D)*S = -N/D * S
-- When using C_long,  the error is: (I + 1)*S - (I + N/D)*S = (1-N/D) * S
-- When divided by S, the resulting error has the unit "number of system clocks".
-- When multiplying with D the resulting error E is too big by factor D, but is an integer number:
-- E_short = -N   , always < 0
-- E_long  = D-N  , always > 0
--
-- This error E is used by the algorithm and has the value 0 at the first edge of the new clock.
-- The algorithm always starts with a too short period, so at the second edge, E will have the value -N.
-- When the algorithm detects E<0, it uses periods with C_long (always adding D-N to E).
-- When the algorithm detects E>=0, it uses periods with C_short (always adding -N to E).
-- After D periods of the new clock, E will always have the value 0.
--
-- E gets the smallest value when E=0 and -N is added, which gives E=-N (if E>0 the result cannot get smaller).
-- E gets the biggest value when E=-1 and D-N is added, which gives E=D-N-1 (if E<-1 the result cannot get bigger).
-- Therefore E is limited between:
-- -N <= E <= D-N-1
-- When E is multiplied by S and divided by D, the result is the jitter (in unit time) of the clock
-- edge of the divided clock (so E is called "jitter" in the implementation below).
-- The jitter is limited between:
-- -S*N/D <= jitter (unit time) <= S*(D-N-1)/D
-- The jitter in unit percentage compared to the exact period of the new clock is:
-- - S*N/(D*C)             <= jitter (unit percentage) <= S*(D-N-1)/(D*C)
-- - S*N/(D*(I + N/D) * S) <= jitter (unit percentage) <= S*(D-N-1)/(D*(I + N/D) * S)
--   - N/(D*(I + N/D))     <= jitter (unit percentage) <=   (D-N-1)/(D*(I + N/D))
--   - N/(D*I+N)           <= jitter (unit percentage) <=   (D-N-1)/(D*I+N)
-- It is clear that a big I produces a small jitter because the ratio C/C_short=1+N/(D*I) and
-- also the ratio C/C_long=(I+N/D)/(I+1)=(D*I+N)/(D*I+D) gets closer to 1 at increasing I.
--
-- Example: Create 115.2 KHz UART clock from 100 MHz system clock:
-- clock_period_int_part_i               = 868
-- clock_period_fract_part_nominator_i   =   1
-- clock_period_fract_part_denominator_i =  18
-- jitter                                = -0.0064% .. +0.10%
--
-- Filename: clock_divider_e.vhd
-- Created by HDL-SCHEM-Editor at Mon Jun  2 17:11:38 2025
--
-- clock_divider documentation
-- ===========================
-- (see also http://www.hdl-schem-editor.de/clock_divider/clock_divider.php)
-- The clock_divider module shall create a clock whose period is n-times longer than that of the incoming clock.
-- The factor n is defined as (with '/' being a division with a real number result):
-- n = clock_period_int_part_i + clock_period_fract_part_nominator_i/clock_period_fract_part_denominator_i
-- However, since the clock_divider module will create the new clock using only a simple counter,
-- the desired period must be approximated by creating a new clock whose period alternates
-- between clock_period_int_part_i and clock_period_int_part_i+1 times the incoming period.
-- In this way after clock_period_fract_part_denominator_i periods of the new clock, the new clock will always have a rising clock edge
-- that occurs at an exact correct point in time, as multiplying n with clock_period_fract_part_denominator_i creates an integer number:
-- clock_period_fract_part_denominator_i*n = clock_period_fract_part_denominator_i*clock_period_int_part_i + clock_period_fract_part_nominator_i
-- The timing of all other rising clock edges will not be exact, but will behave as if the new clock had a jitter.
-- This jitter is kept as small as possible.
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity clock_divider is
    generic (
        constant g_period_width        : natural := 8; -- Allowed values: >= 2
        constant g_fraction_width      : natural := 3; -- Allowed values: >= 2
        constant g_create_clock_enable : boolean := true
    );
    port (
        clk_i                                 : in  std_logic;
        clock_period_fract_part_denominator_i : in  unsigned(g_fraction_width-1 downto 0);
        clock_period_fract_part_nominator_i   : in  unsigned(g_fraction_width-1 downto 0);
        clock_period_int_part_i               : in  unsigned(g_period_width-1 downto 0); -- Allowed values: >= 2
        enable_clock_divider_i                : in  std_logic;
        res_i                                 : in  std_logic;
        clk_divided_o                         : out std_logic
    );
end entity clock_divider;

architecture struct of clock_divider is
    signal counter                            : unsigned(g_period_width-1 downto 0);
    signal counter_long                       : unsigned(g_period_width-1 downto 0);
    signal counter_short                      : unsigned(g_period_width-1 downto 0);
    signal jitter                             : signed(g_fraction_width downto 0); -- To get the jitter as time, divide the value by clock_period_fract_part_denominator_i and multiply it by the period of clk_i.
    signal jitter_delta_for_too_long_periods  : signed(g_fraction_width downto 0);
    signal jitter_delta_for_too_short_periods : signed(g_fraction_width downto 0);
begin
    jitter_delta_for_too_short_periods <= signed('0'&clock_period_fract_part_nominator_i);
    jitter_delta_for_too_long_periods  <= signed('0'&clock_period_fract_part_denominator_i) - signed('0'&clock_period_fract_part_nominator_i);
    process(jitter_delta_for_too_long_periods)
    begin
        assert now=0 ns or jitter_delta_for_too_long_periods(g_fraction_width)='0' -- signbit must always be 0.
        report "Error: clock_period_fract_part_nominator_i is bigger than clock_period_fract_part_denominator_i but must be smaller." severity error;
    end process;
    counter_short <= clock_period_int_part_i - 1;
    counter_long  <= clock_period_int_part_i;
    process (res_i, clk_i)
    begin
        if res_i='1' then
            counter <= (others => '0');
            jitter  <= (others => '0');
        elsif rising_edge(clk_i) then
            if enable_clock_divider_i='0' then
                counter <= (others => '0');
                jitter  <= (others => '0');
            else
                if counter=0 then
                    if clock_period_fract_part_nominator_i=0 then -- nominator and denominator are ignored.
                        counter <= counter_short;
                    else
                        if jitter<0 then
                            counter <= counter_long; -- Start a too long period.
                            jitter  <= jitter + jitter_delta_for_too_long_periods;
                        else
                            counter <= counter_short; -- Start a too short period.
                            jitter  <= jitter - jitter_delta_for_too_short_periods;
                        end if;
                    end if;
                else
                    counter <= counter - 1;
                end if;
            end if;
        end if;
    end process;
    process (res_i, clk_i)
    begin
        if res_i='1' then
            clk_divided_o <= '0';
        elsif rising_edge(clk_i) then
            if enable_clock_divider_i='0' then
                clk_divided_o <= '0';
            else
                if counter=0 then
                    clk_divided_o <= '1';
                elsif g_create_clock_enable or counter=('0' & clock_period_int_part_i(g_period_width-1 downto 1)) then
                    clk_divided_o <= '0';
                end if;
            end if;
        end if;
    end process;
    
end architecture;
