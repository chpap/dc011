	library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use ieee.std_logic_unsigned.all;
	use work.dc0112_pkg.all;

	entity kb_uart is

	   port( clk_i : in std_ulogic;
	      DB_0_o    : out std_ulogic_vector(7 downto 0);
	      DO_0_i    : in std_ulogic_vector(7 downto 0);
	      LBA_i     : in std_ulogic_vector(7 downto 0);

	      BV2_KBD_RD_L_i: in std_ulogic;
	      BV2_KBD_WR_L_i: in std_ulogic;
	      BV6_RESET_H_i : in std_ulogic;
	      BV6_KBD_TBMT_H_o : out std_ulogic;
	      BV6_KBD_DATA_AVAIL_H_o : out std_ulogic;
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
	    signal data_buf: std_ulogic_vector(7 downto 0) := (others => '0');
	    signal data_out: std_ulogic_vector(7 downto 0);
	    signal key_in: std_ulogic_vector(6 downto 0) := (others => '1');
	    signal key_pressed: std_ulogic := '0';
            signal n_kbd_wr_r, n_kbd_wr_rr, n_kbd_wr_rrr, n_kbd_wr_ne : std_ulogic := '0';

	begin
------------------------
	line_act <= data_buf(4);
	l1 <= data_buf(3);
	l2 <= data_buf(2);
	l3 <= data_buf(1);
	l4 <= data_buf(0);
	local <= data_buf(5);
	scan_request <= data_buf(6);
	beep <= data_buf(7);
	BV6_KBD_TBMT_H_o <= '0';
	LEDs <=  line_act & local & l1 & l2 & l3 & l4;
	DB_0_o  <= data_out;

        kbd_wr_proc:  process(clk_i)
        begin
        if rising_edge(clk_i) then
            -- Συγχρονισμός clk1
            n_kbd_wr_rrr <= n_kbd_wr_rr;
            n_kbd_wr_rr  <= n_kbd_wr_r;
            n_kbd_wr_r   <= BV2_KBD_WR_L_i;
        end if;
        end process kbd_wr_proc;
    -- Ανίχνευση Ακμής (Falling Edge Detection)
        n_kbd_wr_ne  <= n_kbd_wr_rrr and (not n_kbd_wr_rr);

	kbd_proc: process(clk_i,n_kbd_wr_ne,data_processed)
	    variable TMP: std_ulogic := '0';
	    variable DTMP: std_ulogic_vector(7 downto 0) := (others => '0');
	begin
	if(rising_edge(clk_i)) then
	    if(n_kbd_wr_ne) then 
	      DTMP := DO_0_i;
	      TMP := '1';
	    else
	      TMP := '0';
	    end if;
	    data_in <= DTMP;
	    data_avail <= TMP;
          end if;
	end process kbd_proc;
	  -----------------------------
	    

	scan_keys: process(clk_i) -- TODO
	begin
	if rising_edge(clk_i) and key_pressed = '1' then
	    data_out <= '0' & key_in;
        end if;
	end process scan_keys;


        rx_proc: process(data_avail)
          variable TMP : std_ulogic_vector(7 downto 0) := (others => '0');
        begin
            TMP := TMP;
            if(rising_edge(data_avail)) then 
	  --LEDs <= data_in(5 downto 0);
	      TMP := data_in;
           end if;
           data_buf <= TMP;
        end process rx_proc;

debug_proc: process(clk_i)
begin
  if(rising_edge(clk_i)) then
    DEBUG(7 downto 0) <= DO_0_i;
    DEBUG(31 downto 8) <= (others => '0');
  end if;
end process debug_proc;
    
end rtl;
