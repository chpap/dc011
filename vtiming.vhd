library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity vtiming is
    port (
        i_clk: in  std_ulogic;
        i_rst: in  std_ulogic; 
        n_vrst: in  std_ulogic; 
        clk_2hf: in  std_ulogic; 
        vcdiv_in: in std_ulogic_vector(0 to 9);
        hertz60: in  std_ulogic; 
        interlaced: in  std_ulogic; 
        vdrive: out  std_ulogic;
        n_vblank : out  std_ulogic;
        vrst : out  std_ulogic
    );
end entity vtiming;


architecture rtl of vtiming is
begin
    htiming_proc: process (i_clk) is
    begin
    if (i_rst = '1') then
       vdrive <= '0';
    end if;

    if i_clk'event then
       vdrive <= i_clk;
    end if;
   end process; 
   vrst <= not n_vrst;
   n_vblank <= n_vrst;
end architecture rtl;
