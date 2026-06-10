library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity NtoM_divider is
    generic (
        N           : integer range 1 to 4;
        M           : integer range 1 to 4
    );
    port (
        rst_i         : in std_ulogic;
        clk_i       : in std_ulogic;
        clk_o       : out std_ulogic
    );
end NtoM_divider;
architecture behavior of NtoM_divider is -- where M = 2
    -- internal signals
    signal counter   : std_ulogic_vector(3 downto 0) := (others => '0');
    signal counter_r_reg   : std_ulogic_vector(3 downto 0) := (others => '0');
    signal counter_f_reg   : std_ulogic_vector(3 downto 0) := (others => '0');

begin
    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            counter_r_reg <= (others => '0');
         elsif rising_edge(clk_i) then
            counter_r_reg <= std_ulogic_vector(unsigned(counter_r_reg + 1) mod N);
        end if;
    end process;

    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            counter_f_reg <= (others => '0');
	elsif falling_edge(clk_i) then
            counter_f_reg <= std_ulogic_vector(unsigned(counter_f_reg + 1) mod N);
        end if;
    end process;
    --counter <= counter_r_reg + counter_f_reg;
    counter <= std_ulogic_vector(unsigned(counter_r_reg + counter_f_reg) mod N);
    --   if counter <= std_ulogic_vector(unsigned(counter_r_reg + counter_f_reg) mod N);
    clk_o <= '0' when counter = "0000" else '1';
    -- clk_o <= clk_div;
end behavior;
