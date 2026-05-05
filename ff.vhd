-- nefgative edge triggered ffs
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity D_FF is
port( 
     D: in std_logic;
     CLOCK: in std_logic;
     Q: out std_logic
);
end D_FF;
 
architecture behavioral of D_FF is
begin
  process(CLOCK)
  begin
    if(CLOCK='0' and CLOCK'EVENT) then
    Q <= D;
  end if;
end process;
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity JK_FF is
port( 
   J: in std_logic;
   K: in std_logic;
   C: in std_logic;
   S: in std_logic;
   CLOCK: in std_logic;
   Q: out std_ulogic;
   n_Q: out std_ulogic
);
end JK_FF;
 
architecture behavioral of JK_FF is
begin
PROCESS(CLOCK,S,C)
  variable TMP: std_logic;
  begin
   if(CLOCK='0' and CLOCK'EVENT) then
     if(C = '0') and (S = '1') then 
       TMP:='0';
     elsif(S = '0') and (C = '1') then 
       TMP:='1';
     elsif(CLOCK'event and CLOCK = '0') then
       if(J='0' and K='1')then
         TMP:='0';
       elsif(J='1' and K='0')then
         TMP:='1';
       elsif(J='1' and K='1')then
         TMP:= not TMP;
       else
         TMP:=TMP;
       end if;
     end if;
   end if;
   Q <=TMP;
   n_Q <=not TMP;
end PROCESS;
end behavioral;

library ieee;
use ieee. std_logic_1164.all;
use ieee. std_logic_arith.all;
use ieee. std_logic_unsigned.all;
 
entity SR_FF is
  PORT( D,S,R,CLOCK: in std_logic;
  Q, n_Q: out std_logic);
end SR_FF;
 
architecture behavioral of SR_FF is
begin
PROCESS(CLOCK,R)
  variable tmp: std_logic :='0';
  begin
    if((CLOCK='0' and CLOCK'EVENT) or (R = '0' and R'EVENT)) then
    --if((CLOCK='0' and CLOCK'EVENT)) then
      if(S='0' and R='0')then
        tmp:='Z';
      elsif(S='1' and R='1')then
        tmp:=D;
      elsif(S='0' and R='1')then
        tmp:='1';
      elsif(S='1' and R='0')then
        tmp:='0';
      else
        tmp:=tmp;
      end if;
    end if;
    Q <= tmp;
    n_Q <= not tmp;
end PROCESS;
end behavioral;
--  function reverse_vector (a: in std_logic_vector)
--  return std_logic_vector is
--    variable result: std_logic_vector(a'RANGE);
--    alias aa: std_logic_vector(a'REVERSE_RANGE) is a;
--  begin
--    for i in aa'RANGE loop
--      result(i) := aa(i);
--    end loop;
--    return result;
--  end; -- function reverse_any_vector
