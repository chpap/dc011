library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.dc0112_pkg.all;


entity htiming is
    port (
        clk_i: in  std_ulogic; -- input clock signal
        extra_clk_i: in  std_ulogic; -- input clock signal
        rst_i : in  std_ulogic; -- reset signal
        div_in : in std_ulogic_vector(8 downto 0);
        mode80_i: in  std_ulogic; 
        addr_cnt_on_o : out  std_ulogic;
        n_hdrive_o: out  std_ulogic;
        hblank_o : out  std_ulogic
    );
end entity htiming;

architecture rtl of htiming is
    signal    hblank :  std_ulogic := '0';
    signal    hdrive:  std_ulogic := '0';
begin
    process_hdrive: process (div_in) is
    begin
      hdrive <= (div_in(8) xor div_in(7)) and not(div_in(8) and not div_in(7) and div_in(6) and div_in(5) and div_in(4));
    end process process_hdrive;
    n_hdrive_o <= not hdrive; 

    -- TODO simplify hblank
    process_hblank: process (div_in) is
    begin
       hblank <= (
		 ((div_in(7) xor div_in(8)) and (not div_in(6) and not div_in(5))) 
                  or 
		 (not div_in(4) and div_in(5) and not div_in(6) and not div_in(7) and div_in(8))
	         )
                 xor 
		 ((nor div_in(6 downto 0)) and div_in(7) and not div_in(8))
                 xor (not div_in(0) and not div_in(1) and div_in(2) and div_in(3) and not div_in(4) and div_in(5) and not div_in(6) and not div_in(7) and div_in(8))
                 xor (div_in(1) and not div_in(2) and div_in(3) and not div_in(4) and div_in(5) and not div_in(6) and not div_in(7) and  div_in(8)) ;


    end process process_hblank; 
    hblank_o <= hblank and not rst_i;

    process_addr_cnt_on: process (div_in,hblank) is
    begin
	addr_cnt_on_o <=  (hblank and 
			  (
			     div_in(5) and not div_in(4) 
			     and 
			     (
			       div_in(3)
			       or 
			       (not div_in(3) and not div_in(2) and div_in(1))
		             )
		           )
                         );

    end process process_addr_cnt_on; 
end architecture rtl;
