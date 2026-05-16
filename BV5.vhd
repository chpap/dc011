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
            clk1_r   <= clk1;
            clk1_rr  <= clk1_r;
            clk1_rrr <= clk1_rr;

            -- Συγχρονισμός clk2
            clk2_r   <= clk2;
            clk2_rr  <= clk2_r;
            clk2_rrr <= clk2_rr;

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
      BV5_DV_H_o: out  std_ulogic;
      BV5_DW_H_o: out  std_ulogic;
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
     signal addr_counter: std_ulogic_vector(11 downto 0) := (others => '0');
     signal addr_counter_in: std_ulogic_vector(11 downto 0) := (others => '0');

begin
    addr_counter_in(7 downto 0) <= DO_0_i;

    GLOBAL_ADDR_COUNTER1: global_addr_counter
    port map( main_clk => clk_i,
           clk1 => BV4_ADDR_CNT_H_i,
	   clk2 => BV4_VSR_LOAD_H_i,
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
    
end rtl;
