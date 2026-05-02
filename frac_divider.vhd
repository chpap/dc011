library ieee;
use ieee.std_logic_1164.all;

entity onetoN_divider is
    generic (
        N           : integer -- Base divide
    );
    port (
        rst         : in std_logic;
        clk_i       : in std_logic;
        modulus_sel : in std_logic; -- 1 divide by N.5
        clk_o       : out std_logic
    );
end onetoN_divider;

architecture behavior of onetoN_divider is
    -- internal signals
    signal count        : integer range 0 to N;
    signal rising_ff    : std_logic := '0';
    signal falling_ff   : std_logic := '0';
begin
    process(clk_i,rst)
    begin
        if rst = '1' then
           count <= 0;
           rising_ff <= '0';
        end if;
            if count >= N then
                count <= 0;
                rising_ff <= '1';
            else
                count <= count + 1;
                rising_ff <= '0';
            end if;
    end process;
    clk_o <= rising_ff when modulus_sel = '0' else (rising_ff or falling_ff);
end behavior;
