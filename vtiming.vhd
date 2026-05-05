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
        vcdiv_in: in std_ulogic_vector(9 downto 0);
        hertz60: in  std_ulogic; 
        interlaced: in  std_ulogic; 
        vdrive: out  std_ulogic;
        n_vblank : out  std_ulogic;
        vrst : out  std_ulogic
    );
end entity vtiming;


architecture rtl of vtiming is
signal vblank: std_ulogic;
begin
    vblanc_proc: process (i_rst,i_clk,vcdiv_in) is
      variable vblanc_next : std_ulogic:= '0';
    begin
      if (i_rst = '1') then
        vblank <= '0';
        vblanc_next := '0';
      end if;
      if i_clk'EVENT then
        case hertz60 is
           when '1' =>
             case interlaced is
              when '0' =>
                  -- 60 Hz non-interlaced / checked
                  if (nor (vcdiv_in(9 downto 6) & not vcdiv_in(5) & vcdiv_in(4) & not vcdiv_in(3) &  vcdiv_in(2 downto 0)))  then
                     vblanc_next := '1';
                  elsif (nor (not vcdiv_in(9) & vcdiv_in(8 downto 4) & (not vcdiv_in(3)) &  vcdiv_in(2 downto 0))) then
                    vblanc_next := '0';
                  end if;
              when '1' =>
                  -- 60 Hz interlace TODO 
                   if vcdiv_in = "0000101000" then
                    vblanc_next := '1';
                   elsif vcdiv_in ="1000001000" then
                    vblanc_next := '0';
                   end if;
              when others => 
                   vblanc_next := 'U';
             end case;
           when '0' =>
             case interlaced is
              when '0' =>
                  -- 50 Hz non interlaced TODO 
                  if (nor (vcdiv_in(9 downto 6) & not vcdiv_in(5) & vcdiv_in(4) & not vcdiv_in(3) &  vcdiv_in(2 downto 0)))  then
                     vblanc_next := '1';
                  elsif (nor (not vcdiv_in(9) & vcdiv_in(8 downto 4) & (not vcdiv_in(3)) &  vcdiv_in(2 downto 0))) then
                    vblanc_next := '0';
                  end if;
              when '1' =>
                  -- 50 Hz interlaced TODO 
                   if vcdiv_in = "0000101000" then
                    vblanc_next := '1';
                   elsif vcdiv_in ="1000001000" then
                    vblanc_next := '0';
                   end if;
              when others => 
                   vblanc_next := 'U';
             end case;
              -- vblanc_next := (nor (vcdiv_in(9 downto 6) & not vcdiv_in(5) & vcdiv_in(4) & not vcdiv_in(3) &  vcdiv_in(2 downto 0)))  then
          when others => 
             vblanc_next := 'U';
         end case;
         vblank <= vblanc_next;
      end if;
   end process vblanc_proc; 
    vdrive_proc: process (i_rst,n_vrst,i_clk,vcdiv_in) is
      variable prev_val_vdrive : std_ulogic:= '0';
    begin
      if (i_rst = '1') then
        vdrive <= '0';
        prev_val_vdrive := '0';
      end if;
      if n_vrst'event and n_vrst = '0' then
        if (nor vcdiv_in(9 downto 0)) then
            vdrive <= '1';
            prev_val_vdrive := '1';
        end if;
      end if;
      if i_clk'EVENT and i_clk = '0' then
         if (nor (vcdiv_in(9 downto 5) & not vcdiv_in(4 downto 0)))   then
             vdrive <= '0' ;
             prev_val_vdrive := '0';
         else
           vdrive <= prev_val_vdrive;
         end if;
      end if;
   end process vdrive_proc; 
   vrst <= (not n_vrst) and vdrive and  (nor vcdiv_in(9 downto 0));
   n_vblank <= vblank;
end architecture rtl;
