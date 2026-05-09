-- negative edge triggered ffs
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.dc0112_pkg.all;

 
architecture behavioral of D_FF is
begin
  process(n_clk_i)
  begin
    if(falling_edge(n_clk_i)) then
    Q <= D;
  end if;
end process;
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
 
architecture behavioral of JK_FF is
  signal TMP: std_ulogic := '0';
begin
process(n_clk_i)
begin
   if(falling_edge(n_clk_i)) then
     if(R = '0') and (S = '1') then 
       TMP<='0';
     elsif(S = '0') and (R = '1') then 
       TMP<='1';
     elsif(J='0' and K='1')then
       TMP<='0';
     elsif(J='1' and K='0')then
       TMP<='1';
     elsif(J='1' and K='1')then
       TMP<= not TMP;
     else
       TMP<= TMP;
     end if;
end if;
end process;
Q <= TMP when (R and S) = '1' else R and not S;
n_Q <=not Q;
end behavioral;

library ieee;
use ieee. std_logic_1164.all;
use ieee. std_logic_arith.all;
use ieee. std_logic_unsigned.all;
 
 
architecture behavioral of SR_FF is
   signal TMP: std_ulogic := '0';
begin
process(n_clk_i)
  begin
    if(falling_edge(n_clk_i)) then
    --if(falling_edge(CLOCK)) then
      if(S='0' and R='0')then
        TMP<='Z';
      elsif(S='1' and R='1')then
        TMP<=D;
      elsif(S='0' and R='1')then
        TMP<='1';
      elsif(S='1' and R='0')then
        TMP<='0';
      end if;
    end if;
end process;
    Q <= TMP when R = '1' else '0';
    n_Q <= not Q;
end behavioral;
