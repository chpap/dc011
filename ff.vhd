-- negative edge triggered ffs
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.dc0112_pkg.all;

architecture rtl of D_FF_p is
  signal TMP: std_ulogic := '0';
begin
  process(clk_i)
  begin
    if(rising_edge(clk_i)) then
      TMP <= D;
    end if;
  end process;
  Q <= TMP;
end rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
architecture rtl of D_FF_n is
  signal TMP: std_ulogic := '0';
begin
  process(n_clk_i)
  begin
    if(falling_edge(n_clk_i)) then
      TMP <= D;
    end if;
  end process;
  Q <= TMP;
end rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
-- positive triggered JK FF 
architecture rtl of JK_FF_p is
begin
process(clk_i,R)
  variable TMP: std_ulogic := '0';
begin
   if(R = '0') then 
     TMP:='0';
   elsif(rising_edge(clk_i)) then
     if(J='0' and K='1')then
       TMP:='0';
     elsif(J='1' and K='0')then
       TMP:='1';
     elsif(J='1' and K='1')then
       TMP:= not TMP;
     else
       TMP:= TMP;
     end if;
   end if;
  Q <= TMP;
end process;
  n_Q <=not Q;
end rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
-- negative triggered JK FF 
architecture rtl of JK_FF_n is
begin
process(n_clk_i,R)
  variable TMP: std_ulogic := '0';
begin
   if(R = '0')then 
       TMP:='0';
   elsif(falling_edge(n_clk_i)) then
    if(J='0' and K='1')then
       TMP:='0';
     elsif(J='1' and K='0')then
       TMP:='1';
     elsif(J='1' and K='1')then
       TMP:= not TMP;
     else
       TMP:= TMP;
     end if;
   end if;
   Q <= TMP;
end process;
   n_Q <=not Q;
end rtl;

library ieee;
use ieee. std_logic_1164.all;
use ieee. std_logic_arith.all;
use ieee. std_logic_unsigned.all;
 
-- negative triggered FF 
architecture rtl of SR_FF_p_s is
   signal TMP: std_ulogic := '0';
begin
process(clk_i,S)
begin
  if(S='0')then
     TMP<='1';
  elsif(rising_edge(clk_i)) then
      --if(S='1' and R='1')then
        TMP<=D;
      --end if;
  end if;
end process;
    Q <= TMP;
    n_Q <= not Q;
end rtl;

library ieee;
use ieee. std_logic_1164.all;
use ieee. std_logic_arith.all;
use ieee. std_logic_unsigned.all;
 
 
-- positive triggered FF ie 74ls74
architecture rtl of SR_FF_p_r is
   signal TMP: std_ulogic := '0';
begin
process(clk_i,R)
  begin
    if(R='0')then
       TMP<='0';
    elsif(rising_edge(clk_i)) then
       if(R='1')then
         TMP<=D;
       end if;
    end if;
end process;
    Q <= TMP;
    n_Q <= not Q;
end rtl;
