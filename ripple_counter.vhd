library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.dc0112_pkg.all;

entity counter10b_ripple is
    generic (
        COUNTBITS: positive; -- maximum available frequency divisor value
        g_MAX_COUNT: positive
    );
    port (
        i_clk : in std_ulogic; -- input clock signal
        i_rst : in std_ulogic; -- reset signal
        o_counter    : out std_ulogic_vector(COUNTBITS - 1  downto 0)
    );
end entity counter10b_ripple;

architecture ripple of counter10b_ripple  is
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
     n_clk_i => i_clk,
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
     n_clk_i => q_internal(i-1),
     Q => q_internal(i),
     n_Q => d_inputs(i)
     );
      end generate THER_BITS;
    end generate GEN_COUNTER;
    o_counter <= q_internal;

end ripple;
