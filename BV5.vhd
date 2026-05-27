library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dc0112_pkg.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity global_addr_counter is
    Port ( main_clk        : in  STD_LOGIC; -- Το γρήγορο κύριο ρολόι
           clk1, clk2       : in  std_ulogic; -- τα 3 ασύγχρονα ρολόγια
           reset            : in  std_ulogic;
           count_in         : in std_ulogic_vector(11 downto 0);
           count_out        : out std_ulogic_vector(11 downto 0));
end global_addr_counter;

architecture Behavioral of global_addr_counter is
    -- Σήματα για συγχρονισμό και ανίχνευση ακμής
    signal clk1_r, clk1_rr, clk1_rrr : std_ulogic := '0';
    signal clk2_r, clk2_rr, clk2_rrr : std_ulogic := '0';

    signal en1, en2 : std_ulogic := '0';
    signal counter_reg   : std_ulogic_vector(11 downto 0) := (others => '0');
begin

    -- Διαδικασία Συγχρονισμού στο Κύριο Ρολόι
    process(main_clk)
    begin
        if rising_edge(main_clk) then
            -- Συγχρονισμός clk1
            clk1_rrr <= clk1_rr;
            clk1_rr  <= clk1_r;
            clk1_r   <= clk1;

            -- Συγχρονισμός clk2
            clk2_rrr <= clk2_rr;
            clk2_rr  <= clk2_r;
            clk2_r   <= clk2;

        end if;
    end process;

    -- Ανίχνευση Ανερχόμενης Ακμής (Rising Edge Detection)
    --en1 <= clk1_rr and (not clk1_rrr);
    --en2 <= clk2_rr and (not clk2_rrr);

    -- Ανίχνευση Ακμής (Falling Edge Detection)
    en1 <= clk1_rrr and (not clk1_rr);
    en2 <= clk2_rrr and (not clk2_rr);

    -- Κεντρικός Καταμετρητής
    process(main_clk, reset)
        variable counter_next: std_ulogic_vector(11 downto 0);
    begin
        if reset = '1' then
            counter_reg <= (others => '0');
        elsif rising_edge(main_clk) then
            -- Υπολογισμός πόσα ρολόγια είχαν ακμή στον ίδιο κύκλο
            counter_next := counter_reg;
            if en1 = '1' then counter_next := counter_next + 1; end if;
            if en2 = '1' then counter_next := count_in; end if;
            counter_reg <= counter_next;
        end if;
    end process;

    count_out <= counter_reg;
end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dc0112_pkg.all;

entity BV5 is

   port( clk_i : in std_ulogic;
      clk24_i   : in  std_ulogic;
      A0_H_o    : out std_ulogic_vector(15 downto 0);
      DO_0_i    : in std_ulogic_vector(7 downto 0);
      LBA_i     : in std_ulogic_vector(7 downto 0);
      BV4_SC_H_i : in std_ulogic_vector(3 downto 0);
      BV4_WRITE_LB_L_i : in std_ulogic;
      BV4_HOLD_REQ_H_i : in std_ulogic;
      BV4_CHAR_CLK_H_i : in std_ulogic;
      BV4_ADDR_LD_L_i : in std_ulogic;
      BV4_ADDR_CNT_H_i : in std_ulogic;
      BV4_DMA_ENA_L_i : in std_ulogic;
      BV1_ALT_CHAR_SEL_L_i : in std_ulogic;
      BV4_DOT_CLK_H_i: in std_ulogic;
      BV4_VSR_LOAD_H_i: in std_ulogic;
      BV5_SERIAL_VIDEO_H_o: out std_ulogic;
      BV4_HORIZ_BLK_H_i: in std_ulogic;
      BV4_VERT_RESET_H_i: in std_ulogic;
      BV5_RV_H_o: out  std_ulogic;
      BV5_DH_L_o: out  std_ulogic;
      BV5_DW_L_o: out  std_ulogic;
      BV5_TERM_L_o: out  std_ulogic;
      DEBUG: out  std_ulogic_vector(31 downto 0)
      );


end BV5;
architecture rtl of BV5 is
     component global_addr_counter is
      port ( main_clk        : in  std_logic; -- το γρήγορο κύριο ρολόι
           clk1, clk2        : in  std_ulogic; -- τα 3 ασύγχρονα ρολόγια
           reset            : in  std_ulogic;
           count_in         : in std_ulogic_vector(11 downto 0);
           count_out        : out std_ulogic_vector(11 downto 0));
     end component;
     signal addr_counter: std_ulogic_vector(11 downto 0);
     signal addr_counter_in: std_ulogic_vector(11 downto 0);
     signal line_buffer: std_ulogic_vector(7 downto 0) := (others => '0');
     signal screen_ram_latch: std_ulogic_vector(7 downto 0) := (others => '0');
     signal char_gen_latch: std_ulogic_vector(7 downto 0) := (others => '0');
     signal char_gen_latch_in: std_ulogic_vector(7 downto 0);
     signal char_gen_address: std_ulogic_vector(10 downto 0);
     signal char_gen_data: std_ulogic_vector(7 downto 0);
     signal char_gen_data_norm: std_ulogic_vector(7 downto 0);
     signal char_gen_data_alt: std_ulogic_vector(7 downto 0);
     signal video_shift_reg: std_ulogic_vector(7 downto 0) := (others => '0');
     signal lbuf_data_in: std_ulogic_vector(7 downto 0);
     signal lbuf_data_out: std_ulogic_vector(7 downto 0);
     signal addr_latch_out: std_ulogic_vector(15 downto 0) := (others => '0');
     signal A0_H: std_ulogic_vector(15 downto 0) := (others => '1');
     signal SR : std_ulogic;

begin
    --------------------------------------------
    GLOBAL_ADDR_COUNTER1: global_addr_counter
    port map( main_clk => clk_i,
           clk1 => BV4_ADDR_CNT_H_i,
	   clk2 => BV4_ADDR_LD_L_i,
	   reset => BV4_VERT_RESET_H_i,
           count_in => addr_counter_in,
           count_out => addr_counter
   );

   debug_proc: process(clk_i)
   begin
     if(rising_edge(clk_i)) then
        DEBUG(11 downto 0) <= addr_counter;
	DEBUG(15 downto 12) <= "0010";
	DEBUG(31 downto 16) <= (others => '0');
     end if;
   end process debug_proc;
    --------------------------------------------
   --- LINE BUFFER
   LATCH_PROC: process(BV4_CHAR_CLK_H_i)
   begin
     if rising_edge(BV4_CHAR_CLK_H_i) then
	     screen_ram_latch <= DO_0_i;
	     char_gen_latch <= char_gen_latch_in;
     end if;
   end process LATCH_PROC;
   A0_H_o <= addr_latch_out when BV4_DMA_ENA_L_i = '0' else (others => '1');
    
   FONTROM_INST: fontrom 
   generic map(
	   DATAWIDTH => 11,
	   FONTROM_FILE => "roms/character_rom.hex"
	)
   port map (
      addr_i => char_gen_address,
      data_o => char_gen_data_norm
   );

   FONTROM_ALT_INST: fontrom 
   generic map(
	   DATAWIDTH => 11,
	   FONTROM_FILE => "roms/character_rom.hex"
	)
   port map (
      addr_i => char_gen_address,
      data_o => char_gen_data_alt
   );
----------- fontrom selection
   char_gen_data <= char_gen_data_norm when BV1_ALT_CHAR_SEL_L_i = '1' else char_gen_data_alt;
---- VSR
   VSR_PROC: process(BV4_DOT_CLK_H_i,BV4_VSR_LOAD_H_i)
   begin
      if(BV4_VSR_LOAD_H_i = '1') then
          video_shift_reg <= char_gen_data(7 downto 1) & video_shift_reg(7);
      elsif rising_edge(BV4_DOT_CLK_H_i) then
          video_shift_reg <= std_ulogic_vector(shift_left(unsigned(video_shift_reg),1)) or ("0000000" & SR) ;
      end if;
   end process;
   BV5_SERIAL_VIDEO_H_o <= video_shift_reg(7);
--------------   
   SR_FF_1: SR_FF_p
     port map(
      D => char_gen_data(0),
      S => '1',
      R => not BV4_HORIZ_BLK_H_i,
      clk_i => BV4_VSR_LOAD_H_i,
      Q => SR,
      n_Q => open
     );
-------------
    BV5_RV_H_o <= char_gen_latch(7);
    BV5_DH_L_o <= char_gen_latch(6);
    BV5_DW_L_o <= char_gen_latch(5);
---------------
   SR_FF_2: SR_FF_p
     port map(
      D => char_gen_latch(4),
      S => not BV4_VERT_RESET_H_i,
      R => '1',
      clk_i => BV4_ADDR_LD_L_i,
      Q => addr_latch_out(13),
      n_Q => addr_latch_out(14)
     );
     addr_latch_out(15) <= '0';
     addr_latch_out(12) <= '0';
     addr_latch_out(11 downto 0) <= addr_counter;
--
-------------
---- TERMINATOR DETECT
    BV5_TERM_L_o <= nand char_gen_address(10 downto 4);
  LINE_BUF_INST: sram generic map (
	   DATAWIDTH =>8 
   )
  port map (
      addr_i => LBA_i,
      clk => clk_i,
      data_i => lbuf_data_in,
      wren_i => not BV4_WRITE_LB_L_i,
      data_o => lbuf_data_out
   );
-------- ADDRESS /DATA MUXES
    char_gen_address(3 downto 0) <= BV4_SC_H_i;
    char_gen_address(10 downto 4) <= char_gen_latch(6 downto 0);
    addr_counter_in(11 downto 8) <= char_gen_latch(3 downto 0);
    addr_counter_in(7 downto 0) <= screen_ram_latch;
    lbuf_data_in <= screen_ram_latch when BV4_DMA_ENA_L_i = '0' else (others => '0');
    char_gen_latch_in <= lbuf_data_out when (BV4_HOLD_REQ_H_i = '0') -- Output Disable <= 1 TODO check polarities? 
			 else  screen_ram_latch when (BV4_DMA_ENA_L_i = '0') -- buffer en1 and 2 <= 0
			 else (others => '0');



end rtl;
