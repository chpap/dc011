library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


architecture behavior of onetoN_divider is
    -- internal signals
    signal clk1_r, clk1_rr, clk1_rrr : std_ulogic := '0';
    signal clk2_r, clk2_rr, clk2_rrr : std_ulogic := '0';

    signal en1, en2 : std_ulogic := '0';
    signal counter_reg   : std_ulogic_vector(11 downto 0) := (others => '0');

    signal count        : integer range 0 to N;
    signal count_l      : integer range 0 to N;
    signal count_h      : integer range 0 to N;
    signal rising_ff    : std_ulogic := '0';
    signal falling_ff   : std_ulogic := '0';
begin

    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' or count = N - 1 then
                count_h <= 0;
                rising_ff <= '1';
            else
                count_h <= count_h + 1;
                rising_ff <= '0';
            end if;
        end if;
    end process;
    process(clk_i)
    begin
        if falling_edge(clk_i) then
            if rst_i = '1' or count = N - 1  then
                count_l <= 0;
                falling_ff <= '1';
            else
                count_l <= count_l + 1;
                falling_ff <= '0';
            end if;
         end if;
    end process;
    count <= count_h + count_l;
    with modulus_sel select clk_o <=
       (rising_ff and not rst_i) when '0',
       (rising_ff xor falling_ff) and not rst_i when others;
end behavior;
