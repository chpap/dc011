library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity dc012 is
port (
  dot_clock: in std_ulogic;
  n_rst:  in  std_logic;
  data:  in  std_logic_vector(3 downto 0);
  n_vid_w2:  in  std_logic;
  vrst:  in  std_logic;
  vf_intr:   out std_logic;
  revvid:  in  std_logic;
  d_h:   in std_logic;
  d_l:   in std_logic;
  addr_ld:   in std_logic;
  hold_req:   out std_logic;
  vsr_ld:   out std_logic;
  char_clk:   in std_logic;
  hblank:   in std_logic;
  scan_cnt:  in  std_logic_vector(3 downto 0);
  vid1out:   in std_logic;
  vid2out:   in std_logic;
  term: in  std_logic;
  underline: in  std_logic;
  blink: in  std_logic;
  bold: in  std_logic;
  vid_in: in std_logic
);
end entity;

architecture behaviour of dc012 is
   type basic_attr_type is
      (ATTR_NONE, ATTR_UNDERLINE, ATTR_REVERSE_VIDEO);
   signal basic_attribute: basic_attr_type := ATTR_NONE;
   signal offset_counter: std_logic_vector(3 downto 0) := "0000";
   signal scan_counter: std_logic_vector(3 downto 0) := "0000";
   signal scroll_latch_L: std_logic_vector(1 downto 0) := "00";
   signal scroll_latch_H: std_logic_vector(1 downto 0) := "00";
   signal blink_ff: std_logic := '0';
   signal reverse_field_ff: std_logic := '0';
   signal vfreq_intr_ff: std_logic := '0';
   signal intr_clear: std_logic := '0';
   signal revvid_latch: std_logic := '0';
   signal d_h_latch: std_logic := '0';
   signal d_l_latch: std_logic := '0';
begin
  command_decode: process (n_vid_w2,data,addr_ld) is
    begin
    if vrst'EVENT and vrst = '1' then
       vfreq_intr_ff <= '1';
       d_l_latch <= '0';
       d_h_latch <= '0';
       revvid_latch <= '0';
       offset_counter <= scroll_latch_H & scroll_latch_L;
       scan_counter <= "0000";
    end if;
    if addr_ld'EVENT and addr_ld = '1' then
       d_l_latch <= d_l;
       d_h_latch <= d_h;
       revvid_latch <= revvid;
    end if;
    if n_vid_w2'EVENT and n_vid_w2 = '0' then
      case data is
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
  vf_intr <= vfreq_intr_ff;
end architecture;
