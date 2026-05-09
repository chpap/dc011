library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


architecture behavior of onetoN_divider is
    -- internal signals
    signal count        : integer range 0 to N;
    signal count_l      : integer range 0 to N;
    signal count_h      : integer range 0 to N;
    signal rising_ff    : std_ulogic := '0';
    signal falling_ff   : std_ulogic := '0';
    -- TODO check falling_ff
        --BIT_WIDTH : integer := integer(ceil(log2(real(g_FREQ_DIV_MAX + 1))))
begin

    process(clk_i)
    begin
        --if rising_edge(rst_i) then
        --   count <= 0;
        --   rising_ff <= '0';
        --end if;
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
    --count <= std_logic_vector(count_h + count_l);
    count <= count_h + count_l;
    with modulus_sel select clk_o <=
       (rising_ff and not rst_i) when '0',
       (rising_ff or '0') and not rst_i when others;
    --   (rising_ff or falling_ff) and not rst_i when others;
    --TODO    report "Was only rising_ff (falling_ff <= '0')"
    -- clk_o <= rising_ff when modulus_sel = '0' else (rising_ff or falling_ff);
end behavior;
