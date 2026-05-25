library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.dc0112_pkg.all;


entity comp_sync_gen is
    port (
       clk132_half_i : in std_ulogic; -- input clock signal
       char_clk_i : in std_ulogic;
       rst_i : in  std_ulogic; -- reset signal
       mode80_i: in std_ulogic;
       hblank_i : in std_ulogic;
       vblank_i : in std_ulogic;
       vcdiv_i : in std_ulogic_vector(9 downto 0);
       hcdiv_i : in std_ulogic_vector(8 downto 0);
       dot_div_i : in std_ulogic_vector(0 to 3);
       comp_sync_o: out std_ulogic := '0'

    );
end entity comp_sync_gen;


architecture rtl of comp_sync_gen is
	signal clk_ref: std_ulogic;
	signal hblank: std_ulogic;
	signal hblankrrr,hblankrr,hblankr: std_ulogic := '0';
	signal vblankrrr,vblankrr,vblankr: std_ulogic := '0';
	signal hcounter: integer range 0 to 1023 := 0;
	signal chsync: std_ulogic;
	signal cvsync: std_ulogic;
	signal eqpulse: std_ulogic;
	signal vmask: std_ulogic;
	signal vmask2: std_ulogic;
	signal rising_fh, rising_fv : std_ulogic;
	signal combpulse: std_ulogic := '1';
	signal vcounter: integer range 0 to 2011 := 0 ;
--	signal chcounter: integer range 0 to 2011 := 0 ;
--	signal chcounter2: integer range 0 to 2011 := 0 ;
begin
      clk_ref <= clk132_half_i;
	       
      vmask <= vblank_i and not (((nor vcdiv_i(9 downto 6)) and ((and vcdiv_i(5 downto 3)) and not (and vcdiv_i(5 downto 0))))
	       or
	       ((nor vcdiv_i(9 downto 7)) and ((and vcdiv_i(6 downto 5))) and (nor vcdiv_i(4 downto 3))) 
	       or
	       ((nor vcdiv_i(9 downto 7)) and vcdiv_i(6) and not vcdiv_i(5) and ((vcdiv_i(4) and not (nor vcdiv_i(3 downto 1) and not vcdiv_i(0) )))
       ));
     
      vmask2 <= vmask and (
		(( and vcdiv_i(5 downto 0)) or (nor vcdiv_i(5 downto 2)) or
		   ((nor vcdiv_i(5 downto 3) and vcdiv_i(2) and (nor vcdiv_i(1 downto 0))))
	          )
		or
		(
		( nor vcdiv_i(5 downto 4) and vcdiv_i(3) and (vcdiv_i(2) or (not vcdiv_i(2) and vcdiv_i(1) and vcdiv_i(0)) )                )
	         or (vcdiv_i(4) and (nor (vcdiv_i(3 downto 0)))))
		or
		((not vcdiv_i(5) and vcdiv_i(4) and not vcdiv_i(3))
		and 
		(and vcdiv_i(2 downto 0)))
--		and not (not vcdiv_i(2) and not vcdiv_i(0)))
		or
		(not vcdiv_i(5)
		and (and vcdiv_i(4 downto 3))
		and not vcdiv_i(2))
		or
		(not vcdiv_i(5)
		and (and vcdiv_i(4 downto 2))
		and (nor vcdiv_i(1 downto 0)))
	);
--      process(chsync)
--      begin
--         if rising_edge(chsync) then
--		 if(vblank_i = '0') then
--			 chcounter <= chcounter + 1;
--			 chcounter2 <= 0;
--		 else
--			 chcounter <= 0;
--			 chcounter2 <= chcounter2 + 1;
--		 end if;
--		 end if;
--	 end process;
      countproc: process(clk_ref,hblank_i)
      begin
         if rising_edge(clk_ref) then
	   hblankrrr <= hblankrr;
	   hblankrr <= hblankr;
           hblankr <= hblank_i;
	   vblankrrr <= vblankrr;
	   vblankrr <= vblankr;
           vblankr <= vblank_i;
    -- Ανίχνευση Ανερχόμενης Ακμής (Rising Edge Detection)
          rising_fh <= hblankrr and (not hblankrrr);
          rising_fv <= vblankrr and (not vblankrrr);

    -- Ανίχνευση Ακμής (Falling Edge Detection)
    -- falling_ff <= hblankrrr and (not hblankrr);

	   if(rising_fh = '0') then
		hcounter <= hcounter + 1;
	   else
		hcounter <= 0;
           end if;
	   if(rising_fv = '0' and vcounter < 2000) then
		vcounter <= vcounter + 1;
	   else
		vcounter <= 0;
           end if;
	 end if;
      end process;
      process(hcounter)
      begin

      if (hcounter > 14) and (hcounter < 72) then
         chsync <= '0';
      else
         chsync <= '1';
      end if;
      if ((hcounter > 14) and (hcounter < 43)) or ((hcounter > 397) and (hcounter < 426)) then
         eqpulse <= '0';
      else
         eqpulse <= '1';
      end if;
      if ((hcounter > 14) and (hcounter < 344)) or ((hcounter > 397) and (hcounter < 727) ) then
         combpulse <= '0';
      else
         combpulse <= '1';
      end if;
      end process;
      comp_sync_o <= (chsync and not vmask)or (eqpulse and vmask2) or (combpulse and not vmask2 and vmask);

end architecture rtl;
