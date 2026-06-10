library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.dc0112_pkg.all;


entity dc012 is
port (
   dot_clock_i: in std_ulogic;
   n_rst_i:  in  std_ulogic;
   data_i:  in  std_ulogic_vector(3 downto 0);
   n_vid_w2_i:  in  std_ulogic;
   vrst_i:  in  std_ulogic;
   vf_intr_o:   out std_ulogic;
   revvid_i:  in  std_ulogic;
   n_d_h_i:   in std_ulogic;
   n_d_w_i:   in std_ulogic;
   n_addr_ld_i:   in std_ulogic;
   hold_req_o:   out std_ulogic;
   char_clk_i:   in std_ulogic;
   hblank_i:   in std_ulogic;
   scan_cnt_o:  out  std_ulogic_vector(3 downto 0);
   vid1out_o:   out std_ulogic;
   vid2out_o:   out std_ulogic;
   n_term_i: in  std_ulogic;
   n_underline_i: in  std_ulogic;
   n_blink_i: in  std_ulogic;
   n_bold_i: in  std_ulogic;
   vid_in_i: in std_ulogic
);
end entity;

architecture behaviour of dc012 is
   type basic_attr_type is
      (ATTR_NONE, ATTR_UNDERLINE, ATTR_REVERSE_VIDEO, TERMINATE,UNDERLINE,BOLD,BLINK);
   type basic_attribute_vector is array (6 downto 0) of basic_attr_type;
   type beam_code_type is
      (O, D, N, B, X);
   type beam_code_vector is array (1 downto 0) of beam_code_type;
   
     -- Purpose: This function performs a bitwise xor on the input vector
  function f_vid_out(
    current_beam_code: in beam_code_type)
    return std_ulogic_vector is
    variable vid_out: std_ulogic_vector(1 downto 0) := "00";
  begin
   with current_beam_code select vid_out :=
     "00" when O,
     "01" when D,
     "10" when N,
     "11" when B,
     "XX" when X,
     "UU" when others;
    return vid_out;
  end function f_vid_out;

   signal attribute_vector: basic_attribute_vector := (ATTR_NONE, ATTR_UNDERLINE, ATTR_REVERSE_VIDEO, TERMINATE,UNDERLINE,BOLD,BLINK);
   signal beam_code: beam_code_vector:= (D,O);
   signal current_beam_code: beam_code_type;
   signal vid_in:  std_ulogic := '0';
   signal scan_cnt:  std_ulogic_vector(3 downto 0) := (others => '0');



   signal basic_attribute: basic_attr_type := ATTR_NONE;
   signal char_attr_vector : std_ulogic_vector(3 downto 0) := "0000";
   signal vidout : std_ulogic_vector(1 downto 0) := "00";
   signal latch1: std_ulogic_vector(2 downto 0) := "000";
   signal latch2: std_ulogic_vector(1 downto 0) := "00";
   signal offset_counter: std_ulogic_vector(3 downto 0) := "0000";
   signal scan_counter: std_ulogic_vector(3 downto 0) := "0000";
   signal character_effect: std_ulogic;
   signal top_scan: std_ulogic;
   signal scroll_mux_out: std_ulogic_vector(3 downto 0);
   signal scroll_latch_L: std_ulogic_vector(1 downto 0) := "00";
   signal scroll_latch_H: std_ulogic_vector(1 downto 0) := "00";
   signal H_CLK3: std_ulogic := '0';
   signal H_CLK2: std_ulogic := '0';
   signal new_scrol_zone_out: std_ulogic := '0';
   signal H_CLK: std_ulogic;
   -- signal hblank_delayed2: std_ulogic;
   signal blink_ff: std_ulogic := '0';
   signal reverse_field_ff: std_ulogic := '0';
   signal vfreq_intr_ff: std_ulogic := '0';
   signal intr_clear: std_ulogic := '0';
   signal hblank_ff: std_ulogic := '0';
   signal hblank_dc12: std_ulogic;
   signal n_term_ff: std_ulogic := '0';
   signal vid_in_delayed: std_ulogic := '0';
   signal scroll_gate1out: std_ulogic;
   signal hreq_gate1out: std_ulogic;
   signal hreq_gate1out_delayed: std_ulogic;
   signal hold_req_int: std_ulogic := '0';
   signal clk_scroll: std_ulogic;
   signal boundary_detect: std_ulogic;
   signal vid_out_state: std_ulogic_vector(1 downto 0);
   component latch1_comp is
    Port ( clk_i: in  STD_LOGIC; -- Το γρήγορο κύριο ρολόι
           n_addr_ld_i, vrst_i : in  std_ulogic;
           reset_i            : in  std_ulogic;
           latch_in         : in std_ulogic_vector(2 downto 0);
           latch_out        : out std_ulogic_vector(2 downto 0));
   end component;
begin
    -- DELAYS
    delay_inst3: delay
    generic map(CYCLES => 3, WIDTH => 1)
    port map(clk => char_clk_i,
         rst => not n_rst_i,
         en  => '1',
         input => ""&hblank_i, 
         output(0) => H_CLK
    );
    --delay_inst32: delay
    --generic map(CYCLES => 2, WIDTH => 1)
    --port map(clk => char_clk_i,
    --     rst => not n_rst_i,
    --     en  => '1',
    --     input => ""&hblank_i, 
    --     output(0) => hblank_delayed2
    --);
    delay_inst2: delay
    generic map(CYCLES => 2, WIDTH => 1)
    port map(clk => char_clk_i,
         rst => not n_rst_i,
         en  => '1',
         input => ""&hreq_gate1out, 
         output(0) => hreq_gate1out_delayed 
    );
    delay_stretch: delay
    generic map(CYCLES => 2, WIDTH => 1)
    port map(clk => dot_clock_i,
         rst => not n_rst_i,
         en  => '1',
         input => ""&vid_in_i, 
         output(0) => vid_in_delayed 
    );

 -- LATCH1_PROC: latch1_comp port map(
 -- 	clk_i => clk_i,
 --       n_addr_ld_i => n_addr_ld_i,
 --       vrst_i => '0',
 --       reset_i => vrst_i,
 --       latch_in => ( revvid_i & n_d_h_i & n_d_w_i ),
 --       latch_out => latch1
 --     );
  latch1_proc: process (n_addr_ld_i,vrst_i) is
    begin
     if( vrst_i = '1' ) then
          latch1 <= (others => '0');
      elsif falling_edge(n_addr_ld_i) then
          latch1 <= ( revvid_i & n_d_h_i & n_d_w_i );
      end if;
  end process latch1_proc;


  latch2_proc: process (hold_req_o,vrst_i) is
    begin
      if rising_edge(hold_req_o) then
          latch2 <= latch1(1 downto 0); -- (n_d_h_i,n_d_w_i) 
      end if;
  end process latch2_proc;


--
--  -- SCAn COUNTER
  scan_counter_proc: process (H_CLK3,vrst_i,scroll_latch_L,scroll_latch_H) is
    begin
      if vrst_i = '1'  then
        offset_counter <= scroll_latch_H & scroll_latch_L;
        scan_counter <= "0000";
      elsif rising_edge(H_CLK3) then
        offset_counter <= offset_counter + 1;
        scan_counter <= scan_counter + 1;
      end if;
  end process scan_counter_proc;
--  -- COMMAND DECOdER
  command_decode: process (n_vid_w2_i,vrst_i,data_i) is
    variable TMP_scroll_latch_L, TMP_scroll_latch_H : std_ulogic_vector(1 downto 0) := (others => '0');
    variable TMP_blink_ff, TMP_vfreq_intr_ff, TMP_reverse_field_ff : std_ulogic := '0';
    variable TMP_basic_attribute : basic_attr_type := ATTR_NONE;
    begin
       TMP_scroll_latch_L := TMP_scroll_latch_L;
       TMP_scroll_latch_H := TMP_scroll_latch_H;
       TMP_blink_ff := TMP_blink_ff;
       TMP_vfreq_intr_ff := TMP_vfreq_intr_ff;
       TMP_reverse_field_ff := TMP_reverse_field_ff;
       TMP_basic_attribute := TMP_basic_attribute;

    if falling_edge(n_vid_w2_i) then
      case data_i is
        when "0000" => TMP_scroll_latch_L := "00";
        when "0001" => TMP_scroll_latch_L := "01";
        when "0010" => TMP_scroll_latch_L := "10";
        when "0011" => TMP_scroll_latch_L := "11";
        when "0100" => TMP_scroll_latch_H := "00";
        when "0101" => TMP_scroll_latch_H := "01";
        when "0110" => TMP_scroll_latch_H := "10";
        when "0111" => TMP_scroll_latch_H := "11";
        when "1000" => TMP_blink_ff := not TMP_blink_ff;
        when "1001" => TMP_vfreq_intr_ff := '0';
        when "1010" => TMP_reverse_field_ff := '1';
        when "1011" => TMP_reverse_field_ff  := '0';
        when "1100" => TMP_basic_attribute := ATTR_UNDERLINE; TMP_blink_ff := '0';
        when "1101" => TMP_basic_attribute := ATTR_REVERSE_VIDEO; TMP_blink_ff := '0';
        when others => TMP_blink_ff := '0';
      end case;
    end if;
    if vrst_i = '1' then
       TMP_vfreq_intr_ff := '1';
    end if;
    scroll_latch_L <= TMP_scroll_latch_L;
    scroll_latch_H <= TMP_scroll_latch_H;
    blink_ff <= TMP_blink_ff;
    vfreq_intr_ff <= TMP_vfreq_intr_ff;
    reverse_field_ff <= TMP_reverse_field_ff;
    basic_attribute <= TMP_basic_attribute;
  end process command_decode;
  --SCAN_COUNT_SEQ
  scan_count_proc: process (hblank_i) is
    begin
    if rising_edge(hblank_i) then
      case latch2 is -- dh dw
      -- double height top half
      when "00" => scan_cnt <= (('0' & scroll_mux_out(3 downto 1)) - 1);
      -- double height bottom half
      when "01" => scan_cnt <= (('0' & scroll_mux_out(3 downto 1)) + 4);
      --when others => scan_cnt <= (scroll_mux_out - 1) mod 16;
      -- no double height
      when others => scan_cnt <= scroll_mux_out - 1;
      end case;
     end if;
    end process scan_count_proc;
    scan_cnt_o <= scan_cnt;
  

  -- SCROLL MUX
  scroll_mux_out <= offset_counter when clk_scroll = '1' else scan_counter;
  -- SCROLL FF
  SCROLL_FF: SR_FF_p_s -- negative triggered
      port map(
       D => latch1(2),
       S => '1',
       clk_i => not boundary_detect,
       Q => clk_scroll,
       n_Q => open
      );
   -- BOUNDARY DET
   boundary_detect <= and (scan_counter & H_CLK2);
   -- TOP SCAN GATE
   top_scan <= and (not scroll_mux_out(3 downto 0));
  -- HBLANK FF
   SR_FF_BLANK: SR_FF_p_s
     port map(
      D => hblank_i,
      S => n_term_ff,
      clk_i => char_clk_i,
      Q => hblank_dc12,
      n_Q => open
     );

--  -- TERM  FF
--   SR_FF_TERM: SR_FF_p
--     port map(
--      D => n_term_i,
--      S => '1',
--      R => hblank_i,
--      clk_i => char_clk_i,
--      Q => n_term_ff,
--      n_Q => open
--     );
--
  term_ff_latch_proc: process (char_clk_i,hblank_i,n_term_i) is
    begin
     if( hblank_i = '1' ) then
          n_term_ff <= '1';
      elsif rising_edge(char_clk_i) and n_term_i = '0' then
          n_term_ff <= '0';
      end if;
  end process term_ff_latch_proc;


  vf_intr_o  <= vfreq_intr_ff;
  
   -- H_CLK3 <= hblank_i and hblank_delayed3;
   -- H_CLK2 <= hblank_i and hblank_delayed2;
   scroll_gate1out <= top_scan or new_scrol_zone_out; 
   hreq_gate1out <= hold_req_int and (latch2(1) or latch2(0)); --  TODO and addr_ld;
   hold_req_int <= H_CLK3 and scroll_gate1out and n_term_ff;
   hold_req_o <= hold_req_int  or hreq_gate1out_delayed; -- TODO
   process(char_clk_i,hblank_i)
	   variable ccounter: integer range 0 to 31;
   begin
	   if rising_edge(char_clk_i) then
	       if(hblank_i = '1') then
		       ccounter := ccounter + 1;
	       else
		       ccounter := 0;
	       end if;
	   end if;
	   if ccounter >= 0 and ccounter < 2 then
	           H_CLK3 <= '0';
	   else
	           H_CLK3 <= '1';
	   end if;
	   if ccounter > 1 and ccounter < 4 then
		   H_CLK2 <= '1';
	   else
		   H_CLK2 <= '0';
	   end if;
   end process;

  -- O-Off/D-Dim/N-Normal/B-Bright/X-NA 
  -- char attr vector -> Rev,Underline,Bold,Blink
  -- beam_code -> BG vid (VID_IN_H = 0) Normal/Blink | FG vid (VID_IN_H = 1) Normal/Blink
   char_attr_vector <= ((revvid_i xor reverse_field_ff)&n_underline_i&n_bold_i&(n_blink_i and blink_ff));
   with char_attr_vector select beam_code <=
      (O,N) when "0111",
      (O,D) when "0110",
      (O,B) when "0101",
      (O,N) when "0100",
      (O,N) when "0011",
      (O,D) when "0010",
      (O,B) when "0001",
      (O,N) when "0000",
      (D,O) when "1111",
      (D,N) when "1110",
      (N,O) when "1101",
      (N,B) when "1100",
      (D,O) when "1011",
      (D,N) when "1010",
      (N,O) when "1001",
      (N,B) when "1000",
      (X,X) when others;


   --vid_in <= vid_in_i or vid_in_delayed; TODO
   vid_in <= vid_in_i;

   vid_out_state <= vid_in & (n_term_ff or (not revvid_i));
   with (vid_out_state) select vidout <=  -- TODO maybe revvid_i xor reverse_field_ff ?
   f_vid_out(beam_code(1)) and (n_term_ff)  when "01", -- BG normal , blank if term 
     f_vid_out(beam_code(0)) and (n_term_ff)  when "11", -- FB normal , blank if term
     f_vid_out(D) when "00", -- BG after term_i and revvid
     f_vid_out(O) when others; -- FG afer term_i and revvid

   vid1out_o <= hblank_dc12 and vidout(0);
   vid2out_o <= hblank_dc12 and vidout(1);

end architecture;
-----------------------------------------
--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;
--use ieee.math_real.all;
--use work.dc0112_pkg.all;
--
--
----  latch1_proc: process (n_addr_ld_i, vrst_i) is
--entity latch1_comp is
--    Port ( clk_i: in  STD_LOGIC; -- Το γρήγορο κύριο ρολόι
--           n_addr_ld_i, vrst_i : in  std_ulogic;
--           reset_i            : in  std_ulogic;
--           latch_in         : in std_ulogic_vector(2 downto 0);
--           latch_out        : out std_ulogic_vector(2 downto 0));
--end latch1_comp;
--
--architecture Behavioral of latch1_comp  is
--    -- Σήματα για συγχρονισμό και ανίχνευση ακμής
--    signal clk1_r, clk1_rr, clk1_rrr : std_ulogic := '0';
--    signal clk2_r, clk2_rr, clk2_rrr : std_ulogic := '0';
--
--    signal en_n_addr, en_vrst : std_ulogic := '0';
--begin
--    -- Διαδικασία Συγχρονισμού στο Κύριο Ρολόι
--    process(clk_i)
--    begin
--        if rising_edge(clk_i) then
--            -- Συγχρονισμός clk1
--            clk1_rrr <= clk1_rr;
--            clk1_rr  <= clk1_r;
--            clk1_r   <= n_addr_ld_i;
--
--            -- Συγχρονισμός clk2
--            clk2_rrr <= clk2_rr;
--            clk2_rr  <= clk2_r;
--            clk2_r   <= vrst_i;
--
--        end if;
--    end process;
--
--    -- Ανίχνευση Ανερχόμενης Ακμής (Rising Edge Detection)
--    --en_n_addr <= clk1_rr and (not clk1_rrr);
--    en_vrst <= clk2_rr and (not clk2_rrr);
--
--    -- Ανίχνευση Ακμής (Falling Edge Detection)
--    en_n_addr <= clk1_rrr and (not clk1_rr);
--    --en_vrst <= clk2_rrr and (not clk2_rr);
--    process(clk_i, reset_i)
--        variable TMP: std_ulogic_vector(2 downto 0) := (others => '0');
--    begin
--        if reset_i = '1' then
--            TMP := (others => '0');
--        elsif rising_edge(clk_i) then
--            if en_vrst = '1' then TMP := (others => '0'); 
--	    elsif en_n_addr = '1' then TMP := latch_in ; end if;
--        end if;
--	latch_out <= TMP;
--    end process;
--
--end Behavioral;
--
