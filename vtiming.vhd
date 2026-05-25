library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.dc0112_pkg.all;


architecture rtl of vtiming is
signal vblank: std_ulogic := '0';
signal vdrive : std_ulogic:= '0';
begin
    vblanc_proc: process (vcdiv_i) is 
    begin
	    vblank <=  ((nor vcdiv_i(9 downto 7)) 
		       and
		       ( 
		          (
		          vcdiv_i(6)
		          and
			       (
			           not vcdiv_i(5)	
				     or
			           (nor vcdiv_i(4 downto 2)) 
				     or 
				   ((nor vcdiv_i(4 downto 3)) and vcdiv_i(2) and (not vcdiv_i(1) or (vcdiv_i(1) and not vcdiv_i(0))))
	                       )
		          )
	                  or 
			  ( not vcdiv_i(6) and (and vcdiv_i(5 downto 3))
			             and (vcdiv_i(2) or (vcdiv_i(0) and vcdiv_i(1) and not vcdiv_i(2)))
			  )
	               )
    );
    end process vblanc_proc; 

    vdrive_proc: process (vcdiv_i) is
    begin
         vdrive <= (((nor vcdiv_i(9 downto 7)) and (vcdiv_i(6) and  not vcdiv_i(5) and not (and vcdiv_i(4 downto 0)))) or ((nor vcdiv_i(9 downto 6)) and (and vcdiv_i(5 downto 0))));
   end process vdrive_proc; 
   

   vdrive_o <= (vdrive or not n_vrst_i) and not rst_i;
   
   vrst_o <= (not n_vrst_i) and vdrive_o; 
   n_vblank_o <= (not vblank ); -- or rst_i;
end architecture rtl;
