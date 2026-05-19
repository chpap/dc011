library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.dc0112_pkg.all;


entity dc012 is
port (
   clk_i: in std_ulogic;
   dot_clock_i: in std_ulogic;
   n_rst_i:  in  std_ulogic;
   data_i:  in  std_ulogic_vector(3 downto 0);
   n_vid_w2_i:  in  std_ulogic;
   vrst_i:  in  std_ulogic;
   vf_intr_o:   out std_ulogic;
   revvid_i:  in  std_ulogic;
   d_h_i:   in std_ulogic;
   d_l_i:   in std_ulogic;
   n_addr_ld_i:   in std_ulogic;
   hold_req_o:   out std_ulogic;
   char_clk_i:   in std_ulogic;
   hblank_i:   in std_ulogic;
   scan_cnt_o:  out  std_ulogic_vector(3 downto 0);
   vid1out_o:   out std_ulogic;
   vid2out_o:   out std_ulogic;
   term_i: in  std_ulogic;
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
   type beam_code_vector is array (3 downto 0) of beam_code_type;
   signal attribute_vector: basic_attribute_vector := (ATTR_NONE, ATTR_UNDERLINE, ATTR_REVERSE_VIDEO, TERMINATE,UNDERLINE,BOLD,BLINK);
   signal beam_code: beam_code_vector:= (D,D,O,O);
   signal current_beam_code: beam_code_type;



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
   signal CNT: std_ulogic := '0';
   signal new_scrol_zone_out: std_ulogic := '0';
   signal hblank_delayed: std_ulogic;
   signal blink_ff: std_ulogic := '0';
   signal reverse_field_ff: std_ulogic := '0';
   signal vfreq_intr_ff: std_ulogic := '0';
   signal intr_clear: std_ulogic := '0';
   signal hblank_ff: std_ulogic := '0';
   signal term_ff: std_ulogic := '0';
   signal vid_in_delayed: std_ulogic := '0';
   signal scroll_gate1out: std_ulogic;
   signal hreq_gate1out: std_ulogic;
   signal hreq_gate1out_delayed: std_ulogic;
   signal hold_req_int: std_ulogic := '0';
   signal clk_scroll: std_ulogic;
   signal CLK: std_ulogic;
   component latch1_comp is
    Port ( clk_i: in  STD_LOGIC; -- Το γρήγορο κύριο ρολόι
           n_addr_ld_i, vrst_i : in  std_ulogic;
           reset_i            : in  std_ulogic;
           latch_in         : in std_ulogic_vector(2 downto 0);
           latch_out        : out std_ulogic_vector(2 downto 0));
   end component;
begin
    --- DELAYS
    delay_inst3: delay
    generic map(CYCLES => 3, WIDTH => 1)
    port map(clk => char_clk_i,
         rst => not n_rst_i,
         en  => '1',
         input => ""&hblank_i, 
         output(0) => hblank_delayed
    );
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
   --LATCH 2 TODO vrst ?
  latch2_proc: process (hold_req_o,vrst_i) is
    begin
    if rising_edge(hold_req_o) then
       latch2 <= latch1(1 downto 0); -- (d_h_i,d_l_i) 
    end if;
  end process latch2_proc;



  LATCH1_PROC: latch1_comp port map(
  	clk_i => clk_i,
	n_addr_ld_i => n_addr_ld_i,
	vrst_i => vrst_i,
	reset_i => vrst_i,
	latch_in => ( revvid_i & d_h_i & d_l_i ),
	latch_out => latch1
      );
--
--  -- SCAn COUNTER
  scan_counter_proc: process (CNT,vrst_i) is
    begin
      if vrst_i = '1'  then
        offset_counter <= scroll_latch_H & scroll_latch_L;
        scan_counter <= "0000";
      elsif rising_edge(CNT) then
        offset_counter <= offset_counter + 1;
        scan_counter <= scan_counter + 1;
      end if;
  end process scan_counter_proc;
--  -- COMMAND DECOdER
  command_decode: process (n_vid_w2_i,vrst_i) is
    begin
    if vrst_i = '1' then
       vfreq_intr_ff <= '1';
    end if;
    if falling_edge(n_vid_w2_i) then
      case data_i is
        when "0000" => scroll_latch_L <= "00";
        when "0001" => scroll_latch_L <= "01";
        when "0010" => scroll_latch_L <= "10";
        when "0011" => scroll_latch_L <= "11";
        when "0100" => scroll_latch_H <= "00";
        when "0101" => scroll_latch_H <= "01";
        when "0110" => scroll_latch_H <= "10";
        when "0111" => scroll_latch_H <= "11";
        when "1000" => blink_ff <= not blink_ff;
        when "1001" => vfreq_intr_ff <= '0';
        when "1010" => reverse_field_ff <= '1';
        when "1011" => reverse_field_ff  <= '0';
        when "1100" => basic_attribute <= ATTR_UNDERLINE; blink_ff <= '0';
        when "1101" => basic_attribute <= ATTR_REVERSE_VIDEO; blink_ff <= '0';
        when others => blink_ff <= '0';
      end case;
    end if;
  end process command_decode;
  --SCAN_COUNT_SEQ
  scan_count_proc: process (hblank_i) is
    begin
    if rising_edge(hblank_i) then
--      when "00" => scan_cnt_o <= to_signed(scroll_mux_out - 1,4) mod 16;
--      when "01" => scan_cnt_o <= (scroll_mux_out - 1) mod 16;
--      when "10" => scan_cnt_o <= (shift_left(unsigned(scroll_mux_out),1)  - 1) mod 16;
      case latch2 is
      when "11" => scan_cnt_o <= scroll_mux_out - 1 mod 16;
      when others => scan_cnt_o <= scroll_mux_out - 1 mod 16;
      end case;
     end if;
    end process scan_count_proc;
  

  -- SCROLL MUX
  scroll_mux_out <= offset_counter when clk_scroll = '1' else scan_counter;
  -- SCROLL FF
  SCROLL_FF: SR_FF
      port map(
       D => latch1(2),
       S => '1',
       R => '1',
       n_clk_i => CLK,
       Q => clk_scroll,
       n_Q => open
      );
   -- BOUNDARY DET
   CLK <= and (scan_counter & CNT);
   -- TOP SCAN GATE
   top_scan <= and (not scroll_mux_out(3 downto 0));

  vf_intr_o  <= vfreq_intr_ff;
  
   CNT <= hblank_delayed;
   scroll_gate1out <= top_scan or new_scrol_zone_out; 
   hreq_gate1out <= hold_req_int and (latch2(1) or latch2(0)); --  TODO and addr_ld;
   hold_req_int <= not CNT and scroll_gate1out and not term_ff;
   hold_req_o <= hold_req_int  or hreq_gate1out_delayed; -- TODO

  -- O-Off/D-Dim/N-Normal/B-Bright/X-NA 
  -- char attr vector -> Rev,Underline,Bold,Blink
  -- beam_code -> BG vid (VID_IN_H = 0) Normal/Blink | FG vid (VID_IN_H = 1) Normal/Blink
   char_attr_vector <= (revvid_i&n_underline_i&n_bold_i&n_blink_i);
   with char_attr_vector select beam_code <=
      (O,O,N,N) when "0111",
      (O,O,N,D) when "0110",
      (O,O,B,B) when "0101",
      (O,O,B,N) when "0100",
      (O,O,N,N) when "0011",
      (O,O,N,D) when "0010",
      (O,O,B,B) when "0001",
      (O,O,B,N) when "0000",
      (D,D,O,O) when "1111",
      (D,O,O,N) when "1110",
      (N,N,O,O) when "1101",
      (N,O,O,B) when "1100",
      (D,D,O,O) when "1011",
      (D,O,O,N) when "1010",
      (N,N,O,O) when "1001",
      (N,O,O,B) when "1000",
      (X,X,X,X) when others;

   vid1out_o <= vidout(0);
   vid2out_o <= vidout(1);
   with current_beam_code select vidout <=
     "00" when O,
     "01" when D,
     "10" when N,
     "11" when B,
     "XX" when X,
     "UU" when others;
    

end architecture;
---------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.dc0112_pkg.all;


--  latch1_proc: process (n_addr_ld_i, vrst_i) is
entity latch1_comp is
    Port ( clk_i: in  STD_LOGIC; -- Το γρήγορο κύριο ρολόι
           n_addr_ld_i, vrst_i : in  std_ulogic;
           reset_i            : in  std_ulogic;
           latch_in         : in std_ulogic_vector(2 downto 0);
           latch_out        : out std_ulogic_vector(2 downto 0));
end latch1_comp;

architecture Behavioral of latch1_comp  is
    -- Σήματα για συγχρονισμό και ανίχνευση ακμής
    signal clk1_r, clk1_rr, clk1_rrr : std_ulogic := '0';
    signal clk2_r, clk2_rr, clk2_rrr : std_ulogic := '0';

    signal en_n_addr, en_vrst : std_ulogic := '0';
begin

    -- Διαδικασία Συγχρονισμού στο Κύριο Ρολόι
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            -- Συγχρονισμός clk1
            clk1_rrr <= clk1_rr;
            clk1_rr  <= clk1_r;
            clk1_r   <= n_addr_ld_i;

            -- Συγχρονισμός clk2
            clk2_rrr <= clk2_rr;
            clk2_rr  <= clk2_r;
            clk2_r   <= vrst_i;

        end if;
    end process;

    -- Ανίχνευση Ανερχόμενης Ακμής (Rising Edge Detection)
    en_n_addr <= clk1_rr and (not clk1_rrr);
    en_vrst <= clk2_rr and (not clk2_rrr);

    -- Ανίχνευση Ακμής (Falling Edge Detection)
    --en_n_addr <= clk1_rrr and (not clk1_rr);
    --en_vrst <= clk2_rrr and (not clk2_rr);
    process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            latch_out <= (others => '0');
        elsif rising_edge(clk_i) then
            if en_vrst = '1' then latch_out <= (others => '0'); 
	    elsif en_n_addr = '1' then latch_out <= latch_in ; end if;
        end if;
    end process;

end Behavioral;

