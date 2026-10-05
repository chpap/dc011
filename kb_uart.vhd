library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dc0112_pkg.all;
use work.vt100_pkg.all;

entity kb_uart is
   GENERIC(
      clk_freq                  : INTEGER := 100_000_000; --system clock frequency in Hz
      ps2_debounce_counter_size : INTEGER := 9);         --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
   port( clk_i : in std_ulogic;
      RX_KBD_o: out std_ulogic;
      TX_KBD_i: in std_ulogic;
      KBD_CLK_i: in std_ulogic;
      ps2_clk	: inout std_ulogic;
      ps2_data  : inout std_ulogic;
      LEDs : out std_ulogic_vector(5 downto 0);
      DEBUG     : out std_ulogic_vector(31 downto 0));
end kb_uart;

architecture rtl of kb_uart is
    signal line_act, l1, l2, l3, l4, local : std_ulogic := '0';
    signal data_avail,data_processed: std_ulogic := '0';
    signal data_reset: std_ulogic := '0';
    signal scan_request: std_ulogic := '0';
    signal beep: std_ulogic := '0';
    signal data_in: std_ulogic_vector(7 downto 0) := (others => '0');
    signal rd: std_ulogic_vector(7 downto 0);
    signal xd: std_ulogic_vector(7 downto 0) := (others => '0');
    signal key_in: std_ulogic_vector(6 downto 0) := (others => '1');
    signal counter: std_ulogic_vector(7 downto 0) := (others => '0');
    signal KB2_KEY_DOWN_L: std_ulogic := '1';
    signal ff2_n_q: std_ulogic;
    signal ff2_set: std_ulogic;
    signal n_drr: std_ulogic;
    signal dr: std_ulogic;
    signal kbd_clk: std_ulogic;
    signal thre: std_ulogic;
    signal jk_reset: std_ulogic;
    signal clk_counter: std_ulogic;
    signal counter_clear: std_ulogic;
    signal n_counter_match: std_ulogic;
    signal data_strobe: std_ulogic;
    signal SPKR: std_ulogic;
    signal n_kbd_wr_r, n_kbd_wr_rr, n_kbd_wr_rrr, n_kbd_wr_ne : std_ulogic := '0';
    SIGNAL ps2_code_new      : STD_LOGIC;                             --new PS2 code flag from ps2_keyboard component
    SIGNAL ps2_code          : STD_LOGIC_VECTOR(7 DOWNTO 0);          --PS2 code input form ps2_keyboard component
 
    COMPONENT ps2_keyboard_to_ascii IS
    GENERIC(
      clk_freq              : INTEGER;  --system clock frequency in Hz
      debounce_counter_size : INTEGER); --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
    PORT(
      clk          : IN  STD_LOGIC;                     --system clock
      ps2_clk      : IN  STD_LOGIC;                     --clock signal from PS2 keyboard
      ps2_data     : IN  STD_LOGIC;                     --data signal from PS2 keyboard
      ascii_new : OUT STD_LOGIC;                     --flag that new PS/2 code is available on ps2_code bus
      ascii_code     : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)); --code received from PS/2
  END COMPONENT;
begin
------------------------
    ps2_keyboard_0:  ps2_keyboard_to_ascii
    GENERIC MAP(clk_freq => clk_freq, debounce_counter_size => ps2_debounce_counter_size)
    PORT MAP(clk => clk_i, ps2_clk => ps2_clk, ps2_data => ps2_data, ascii_new => ps2_code_new, ascii_code => ps2_code(6 downto 0));
    ps2_proc: process(ps2_code_new)
	begin
       if rising_edge(ps2_code_new) then
		 data_in <= ps2_code;
		 DEBUG(7 downto 0) <= ps2_code;
	   end if;
	end process ps2_proc;

    TR1602_INST_KB: TR1602
        port map (
            rrd_i    => '0',
            rr_o     => rd,
            pe_o     => open,
            fe_o     => open,
            oe_o     => open,
            sfd_i    => '0',
            rrc_i    => KBD_CLK_i,
            n_drr_i  => n_drr,
            dr_o     => dr,
            r_i      => TX_KBD_i,
            mr_i     => '0',
            thre_o   => thre,
            n_thrl_i => data_strobe,
            tre_o    => open,
            tro_o    => RX_KBD_o,
            tr_i     => xd,
            crl_i    => '1',
            pi_i     => '1',
            sbs_i    => '0',
            wls_i    => "11",
            epe_i    => '1',
            trc_i    => KBD_CLK_i
        );

--------------   
        SR_FF_1: SR_FF_p_s
        port map(
          D => dr,
          S => '1',
          clk_i => KBD_CLK_i,
          Q => kbd_clk,
          n_Q => n_drr
        );

        SR_FF_2: SR_FF_p_s
        port map(
          D => KB2_KEY_DOWN_L,
          S => ff2_set,
          clk_i => counter(0),
          Q => data_strobe,
          n_Q => ff2_n_q
        );

        ff2set_proc: process(KBD_CLK_i,ff2_set)
	begin
	      ff2_set <= KBD_CLK_i nand ff2_n_q;
	end process;


	LATCH1: process(thre,KBD_CLK_i)
	begin
	   if(thre = '1') then
		clk_counter <= KBD_CLK_i;
	   end if;
	end process LATCH1;

	jk_reset <= kbd_clk nand rd(6);

        JK_FF_1: JK_FF_n
        port map(
           J => '1',
           K => '0',
           R => jk_reset,
           n_clk_i => xd(6), 
           Q => counter_clear,
           n_Q => open
        );
	xd(7) <= '0';
	xd(6 downto 0) <= counter(7 downto 1);

	counter_proc: process(counter_clear,clk_counter)
	begin
	   if(counter_clear = '1') then
		counter <= (others => '0');
           elsif falling_edge(clk_counter) then
		counter <= counter + 1;
	   end if;
	end process counter_proc;

	line_act <= rd(4);
	l1 <= rd(3);
	l2 <= rd(2);
	l3 <= rd(1);
	l4 <= rd(0);
	local <= rd(5);
	scan_request <= rd(6);
	beep <= rd(7);
	LEDs <=  line_act & local & l1 & l2 & l3 & l4;
	-- DB_0_o  <= data_out;

--        kbd_wr_proc:  process(clk_i)
--        begin
--        if rising_edge(clk_i) then
--            -- Συγχρονισμός clk1
--            n_kbd_wr_rrr <= n_kbd_wr_rr;
--            n_kbd_wr_rr  <= n_kbd_wr_r;
--            n_kbd_wr_r   <= BV2_KBD_WR_L_i;
--        end if;
--        end process kbd_wr_proc;
    -- Ανίχνευση Ακμής (Falling Edge Detection)
--        n_kbd_wr_ne  <= n_kbd_wr_rrr and (not n_kbd_wr_rr);
--
--	kbd_proc: process(clk_i,n_kbd_wr_ne,data_processed)
--	    variable TMP: std_ulogic := '0';
--	    variable DTMP: std_ulogic_vector(7 downto 0) := (others => '0');
--	begin
--	if(rising_edge(clk_i)) then
--	    if(n_kbd_wr_ne) then 
--	      DTMP := DO_0_i;
--	      TMP := '1';
--	    else
--	      TMP := '0';
--	    end if;
--	    data_in <= DTMP;
--	    data_avail <= TMP;
--          end if;
--	end process kbd_proc;
	  -----------------------------
	    

    match_proc: process(counter,ps2_code) -- TODO
	begin  
      if (ps2_code = counter and ps2_code_new = '1') or (counter = x"7F") then
	        n_counter_match <= '0';
	  else
	        n_counter_match <= '1';         
	  end if;
	end process match_proc;
    KB2_KEY_DOWN_L <= n_counter_match;

debug_proc: process(clk_i)
begin
  if(rising_edge(clk_i)) then
     DEBUG(8) <= ps2_code_new;
--    DEBUG(7 downto 0) <= DO_0_i;
--    DEBUG(31 downto 8) <= (others => '0');
  end if;
end process debug_proc;
    
end rtl;
