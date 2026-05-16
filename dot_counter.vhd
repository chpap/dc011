library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.dc0112_pkg.all;



architecture rtl of dot_counter is
    signal counter: std_ulogic_vector(3 downto 0) := (others => '0');
    type ctdata is array (0 to 1) of std_ulogic_vector(3 downto 0);
    signal counter_prev: ctdata := (others => (others => '0'));
    signal char_clk_delayed: std_ulogic_vector(1 downto 0) := "00";
    -- signal char_clk_tmp : std_ulogic;
    signal maxcount: integer range 1 to 10 := 10;
begin
    maxcount <= 10 when mode80_i = '1' else 9;
    process(dot_clk_s_i) begin
	    if(rising_edge(dot_clk_s_i)) then
	    if counter = std_ulogic_vector(to_unsigned(maxcount - 1,4)) then
		    counter <= (others => '0');
	    else
		    counter <= counter + 1;
	    end if;
	    end if;
    end process;
    GEN_DELAY: for i in 0 to 1 generate
    delay_inst: delay
    generic map(CYCLES => i + 1,
            WIDTH => 4)
    port map(clk => dot_clk_i,
         rst => rst_i,
         en  => '1',
         --input => ""&char_clk_tmp, 
         --input => ""&counter(3), 
         input => counter, 
         -- output(0) => char_clk_delayed(i)
         output => counter_prev(i)
    );
    end generate GEN_DELAY;
    dot_div_o <= counter_prev(0);
    write_lb_o <= counter_prev(0)(2);
    clk80_half_o <= counter(0);
    char_clk_o <= not counter_prev(0)(3) when mode80_i = '1'  else
    not (counter_prev(1)(3) or (and counter_prev(1)(2 downto 0)));
    
end architecture rtl;
