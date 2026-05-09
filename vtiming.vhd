library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.dc0112_pkg.all;


architecture rtl of vtiming is
signal code_on : std_ulogic_vector(9 downto 0) := "0000101000";
signal code_off : std_ulogic_vector(9 downto 0) := "1000001000";
signal vd_code_on : std_ulogic_vector(9 downto 0) := "0000000000";
signal vd_code_off : std_ulogic_vector(9 downto 0) := "0000011111";
signal mode_selector : std_ulogic_vector(1 downto 0) := "10";
signal vblank: std_ulogic := '0';
signal vblank_h: std_ulogic := '0';
signal vblank_l: std_ulogic := '0';
signal next_val_vdrive : std_ulogic:= '0';
signal next_val_vdrive_mask : std_ulogic:= '0';
begin
     mode_select_proc: process(mode_selector,code_on,code_off) is
     begin
       mode_selector <= (hertz60 & interlaced );
       case mode_selector is
         when "11" => code_on <= "0000101000"; code_off <= "1000001000"; -- 60 Hz interlaced 
         when "00" => code_on <= "0000101000"; code_off <= "1000001000"; -- 50 Hz non-interlaced 
         when "01" => code_on <= "0000101000"; code_off <= "1000001000"; -- 50 Hz interlaced 
         when others  => code_on <= "0000101000"; code_off <= "1000001000"; -- 60 Hz non-interlaced 
       end case;
    end process mode_select_proc;

    vblanc_proc_h: process (i_clk) is -- vcdiv_in,code_on,code_off,i_rst,hertz60,interlaced) is
    --  variable vblank_next: std_ulogic:= '0';
    begin
      --if rising_edge(i_rst) then
      --  vblank <= '0';
      --end if;
      if rising_edge(i_clk) then --  or falling_edge(i_clk) then
         --    if (nor (vcdiv_in(9 downto 6) & not vcdiv_in(5) & vcdiv_in(4) & not vcdiv_in(3) &  vcdiv_in(2 downto 0))) = '1'  then
         --         elsif (nor (not vcdiv_in(9) & vcdiv_in(8 downto 4) & (not vcdiv_in(3)) &  vcdiv_in(2 downto 0))) then
         if vcdiv_in = code_on then
               vblank_h <= '1';
         elsif vcdiv_in = code_off or i_rst = '1' then
               vblank_h <= '0';
         end if;
      end if;
    end process vblanc_proc_h; 
    vblanc_proc_l: process (i_clk) is -- vcdiv_in,code_on,code_off,i_rst,hertz60,interlaced) is
    begin
      if falling_edge(i_clk) then 
         if vcdiv_in = code_on then
               vblank_l <= '1';
         elsif vcdiv_in = code_off or i_rst ='1'  then
               vblank_l <= '0';
         end if;
      end if;
      --vblank <= vblank_next;
    end process vblanc_proc_l; 
    vblank <= vblank_h when i_clk = '1' else vblank_l;

   vdrive_proc: process (n_vrst) is
    begin
      if falling_edge(n_vrst) then
          --if (nor vcdiv_in(9 downto 0)) then
	  if (vcdiv_in = vd_code_on) then
              next_val_vdrive <= '1';
          elsif i_rst = '1' then
	      next_val_vdrive <= '0';
          end if;
      --if ((i_clk = '0') and (nor (vcdiv_in(9 downto 5) & not vcdiv_in(4 downto 0))) = '1')   then
         if (i_clk = '0' and vcdiv_in = vd_code_off )   then
            next_val_vdrive <= '0' ;
         end if;
      end if;
   end process vdrive_proc; 
   

   vdrive_proc_clk: process (i_clk) is
    variable TMP: std_ulogic := '1';
    begin
      TMP := '1';
--      next_val_vdrive_mask <= '1';
      if (falling_edge(i_clk)) then
         if (vcdiv_in = vd_code_off)   then
            TMP := '0';
         end if;
--	      if (nor (vcdiv_in(9 downto 5) & not vcdiv_in(4 downto 0))) = '1'   then
--	          TMP := '0';
--              end if;
--     --      next_val_vdrive_mask <= '0';
--     -- else
--	--   next_val_vdrive_mask <= '1';
          next_val_vdrive_mask <= TMP;
      end if;
   end process vdrive_proc_clk;
--
   vdrive <= next_val_vdrive and not i_rst;
   

   vrst <= (not n_vrst) and vdrive and  (nor vcdiv_in(9 downto 0));
   n_vblank <= (not vblank and  next_val_vdrive_mask) or i_rst;
end architecture rtl;
