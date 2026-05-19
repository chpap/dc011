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
       mode_selector <= (hertz60_i & interlaced_i );
       case mode_selector is
         when "11" => code_on <= "0000101000"; code_off <= "1000001000"; -- 60 Hz interlaced 
         when "00" => code_on <= "0000101000"; code_off <= "1000001000"; -- 50 Hz non-interlaced 
         when "01" => code_on <= "0000101000"; code_off <= "1000001000"; -- 50 Hz interlaced 
         when others  => code_on <= "0000101000"; code_off <= "1000001000"; -- 60 Hz non-interlaced 
       end case;
    end process mode_select_proc;

    vblanc_proc_h: process (clk_i) is -- vcdiv_i,code_on,code_off,rst_i,hertz60_i,interlaced_i) is
    --  variable vblank_next: std_ulogic:= '0';
    begin
      --if rising_edge(rst_i) then
      --  vblank <= '0';
      --end if;
      if rising_edge(clk_i) then --  or falling_edge(clk_i) then
         --    if (nor (vcdiv_i(9 downto 6) & not vcdiv_i(5) & vcdiv_i(4) & not vcdiv_i(3) &  vcdiv_i(2 downto 0))) = '1'  then
         --         elsif (nor (not vcdiv_i(9) & vcdiv_i(8 downto 4) & (not vcdiv_i(3)) &  vcdiv_i(2 downto 0))) then
         if vcdiv_i = code_on then
               vblank_h <= '1';
         elsif vcdiv_i = code_off or rst_i = '1' then
               vblank_h <= '0';
         end if;
      end if;
    end process vblanc_proc_h; 
    vblanc_proc_l: process (clk_i) is -- vcdiv_i,code_on,code_off,rst_i,hertz60_i,interlaced_i) is
    begin
      if falling_edge(clk_i) then 
         if vcdiv_i = code_on then
               vblank_l <= '1';
         elsif vcdiv_i = code_off or rst_i ='1'  then
               vblank_l <= '0';
         end if;
      end if;
      --vblank <= vblank_next;
    end process vblanc_proc_l; 
    vblank <= vblank_h when clk_i = '1' else vblank_l;

   vdrive_proc: process (n_vrst_i) is
    begin
      if falling_edge(n_vrst_i) then
          --if (nor vcdiv_i(9 downto 0)) then
	  if (vcdiv_i = vd_code_on) then
              next_val_vdrive <= '1';
          elsif rst_i = '1' then
	      next_val_vdrive <= '0';
          end if;
      --if ((clk_i = '0') and (nor (vcdiv_i(9 downto 5) & not vcdiv_i(4 downto 0))) = '1')   then
         if (clk_i = '0' and vcdiv_i = vd_code_off )   then
            next_val_vdrive <= '0' ;
         end if;
      end if;
   end process vdrive_proc; 
   

   vdrive_proc_clk: process (clk_i) is
    variable TMP: std_ulogic := '1';
    begin
      TMP := '1';
--      next_val_vdrive_mask <= '1';
      if (falling_edge(clk_i)) then
         if (vcdiv_i = vd_code_off)   then
            TMP := '0';
         end if;
--	      if (nor (vcdiv_i(9 downto 5) & not vcdiv_i(4 downto 0))) = '1'   then
--	          TMP := '0';
--              end if;
--     --      next_val_vdrive_mask <= '0';
--     -- else
--	--   next_val_vdrive_mask <= '1';
          next_val_vdrive_mask <= TMP;
      end if;
   end process vdrive_proc_clk;
--
   vdrive_o <= next_val_vdrive and not rst_i;
   

   vrst_o <= (not n_vrst_i) and vdrive_o and  (nor vcdiv_i(9 downto 0));
   n_vblank_o <= (not vblank and  next_val_vdrive_mask) or rst_i;
end architecture rtl;
