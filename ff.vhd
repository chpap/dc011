-- negative edge triggered ffs
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.dc0112_pkg.all;

architecture behavioral of D_FF_p is
  signal TMP: std_ulogic := '0';
begin
  process(clk_i)
  begin
    if(rising_edge(clk_i)) then
      TMP <= D;
    end if;
  end process;
  Q <= TMP;
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
architecture behavioral of D_FF_n is
  signal TMP: std_ulogic := '0';
begin
  process(n_clk_i)
  begin
    if(falling_edge(n_clk_i)) then
      TMP <= D;
    end if;
  end process;
  Q <= TMP;
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
-- positive triggered JK FF 
architecture behavioral of JK_FF_p is
begin
process(clk_i,R,S)
  variable TMP: std_ulogic := '0';
begin
   if(R = '0') and (S = '1') then 
     TMP:='0';
   elsif(S = '0') and (R = '1') then 
     TMP:='1';
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
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
-- negative triggered JK FF 
architecture behavioral of JK_FF_n is
begin
process(n_clk_i,R,S)
  variable TMP: std_ulogic := '0';
begin
   if(R = '0') and (S = '1') then 
       TMP:='0';
   elsif(S = '0') and (R = '1') then 
       TMP:='1';
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
end behavioral;

library ieee;
use ieee. std_logic_1164.all;
use ieee. std_logic_arith.all;
use ieee. std_logic_unsigned.all;
 
-- negative triggered FF 
architecture behavioral of SR_FF_n is
   signal TMP: std_ulogic := '0';
begin
process(n_clk_i,R,S)
begin
  if(S='0' and R='1')then
     TMP<='1';
  elsif(S='1' and R='0')then
     TMP<='0';
  elsif(S='0' and R='0')then
        TMP<='Z';
  elsif(falling_edge(n_clk_i)) then
      --if(S='1' and R='1')then
        TMP<=D;
      --end if;
  end if;
end process;
    Q <= TMP;
    n_Q <= not Q;
end behavioral;

library ieee;
use ieee. std_logic_1164.all;
use ieee. std_logic_arith.all;
use ieee. std_logic_unsigned.all;
 
 
-- positive triggered FF ie 74ls74
architecture behavioral of SR_FF_p is
   signal TMP: std_ulogic := '0';
begin
process(clk_i,R,S)
  begin
    if(S='0' and R='1')then
       TMP<='1';
    elsif(S='1' and R='0')then
       TMP<='0';
    elsif(S='0' and R='0')then
       TMP<='Z';
    elsif(rising_edge(clk_i)) then
       if(S='1' and R='1')then
         TMP<=D;
       end if;
    end if;
end process;
    Q <= TMP;
    n_Q <= not Q;
end behavioral;
