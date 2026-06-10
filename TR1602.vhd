library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- ============================================================================
-- Module Name:    TR1602 UART IC
-- Description:    Complete VHDL implementation of the TR1602 UART interface.
--                 Includes 16x oversampling, dynamic word length configuration,
--                 and tristate bus controls.
-- ============================================================================


entity TR1602 is
    Port (
        -- uart interface
	rrd_i        : in  std_ulogic; -- receiver register disconnect LT: H-> disconnect input rr frm holding reg
	rr_o         : out  std_ulogic_vector(7 downto 0); -- contents of RHR (Receiver Holding Register) when rrd -> 0
        pe_o         : out std_ulogic; -- parity error
        fe_o         : out std_ulogic; -- framing error
        oe_o         : out std_ulogic; -- overrun error : DRF (Data Received Flag) was not reset before a new character was transferred to the RHR
        sfd_i        : in  std_ulogic; -- disconnects PE,FE, OE and THRE , allowing them to be bus connected
        rrc_i        : in  std_ulogic; -- receiver clock frequency: 16x desired receiver shift rate
        n_drr_i      : in std_ulogic; -- data receiver reset (negative logic). level triggered asynchronous reset of the DR (Data Received) line
        dr_o         : out std_ulogic; -- data received. A high level indicates that a complete character has been received
        r_i          : in std_ulogic; -- receiver input. 
        mr_i         : in std_ulogic; -- Master reset input. High level clears the logic : TR and RR, THR, FE, OE, PE, n_DRR and sets TRO, THRE, TRE
        thre_o       : out std_ulogic; -- transmitter holding register empty. high level indicates the transmitter holding register has transferred 
                                       -- its contents to the transmiter register and may be loaded with a new character
        n_thrl_i     : in std_ulogic; -- transmitter holding register load(negative logic) . Low level enters a character into the 
                                      -- THR (Transmitter holding register). A transition from low to high level transfers the character into the TR
                                      -- (Transmitter Register) if it is not in the process of transmitting. If a  character is trnsmitted, the transfer
                                      -- is delayed until its transmission is completed. Upon completion , the new character is automatically transferred
                                      -- simultaneously with the initiation of its serial transmission
	tre_o        : out std_ulogic; -- transmitter register empty .high level when TR has completed transmission of full character including stop bits
                                       -- it remains so until start of new transmission
        tro_o        : out std_ulogic; -- The contents ot the TR together with start stop and parity bits are serialy shifted out on this line. When idle this line remains higho
        tr_i         : in std_ulogic_vector(7 downto 0); -- Transmitter register data inputs. These line load a character into the TRHL with the THRL Strobe pin
	                              -- If acharacter of less than 8 bits is selected (by wls(0) and wls(1)) hte character is right justified and the 
	                              -- excess bits are discarded
	crl_i        : in std_ulogic; -- Loads the control register CR with the control bits (wls(0), wls(1), epe, pi, sbs)
	pi_i         : in std_ulogic; -- Parity inhibit. Inhibits parity generation and clamps PE output to low.
        sbs_i        : in std_ulogic; -- This line selects the stop bits after the parity bit. High selects 2 and low 1. In the case of a word selection of 5 bits, high selects .5 stop bits
        wls_i       : in std_ulogic_vector(1 downto 0); -- these two bits sleect the character length ( exclusive of parity)
                                     -- wls(1)   wls(0)  word length
                                      -----------------------------  
                                      -- L         L     5 bits
                                      -- L         H     6 bits
                                      -- H         L     7 bits
                                      -- H         H     8 bits
	epe_i       : in std_ulogic; -- even parity enable. High level selects even, low selects odd
        trc_i       : in std_ulogic -- transmitter clock. 16x the desired shift rate
    );
end entity;

architecture RTL of TR1602 is
    -- Helper function to calculate actual data word length
    pure function get_word_length(wls : std_ulogic_vector(1 downto 0)) return integer is
    begin
        case wls is
            when "00"   => return 5;
            when "01"   => return 6;
            when "10"   => return 7;
            when "11"   => return 8;
            when others => return 8;
        end case;
    end function get_word_length;

    -- Helper function to calculate parity bit
    pure function calc_parity(data : std_ulogic_vector; len : integer range 5 to 8; even : std_ulogic) return std_ulogic is
        variable p : std_ulogic := '0';
    begin
        for i in 0 to 7 loop
	    if i < len then
               p := p xor data(i);
            end if ;
        end loop;
        if even = '1' then
            return p;
        else
            return not p;
        end if;
     end function calc_parity;

    -- Control Register Bits (latched when crl_i = '1')
    signal r_pi   : std_ulogic := '0';
    signal r_sbs  : std_ulogic := '0';
    signal r_wls  : std_ulogic_vector(1 downto 0) := "00";
    signal r_epe  : std_ulogic := '0';

    -- Transmitter Internal Signals
    signal tx_reg     : std_ulogic_vector(7 downto 0) := (others => '0');
    signal th_reg   : std_ulogic_vector(7 downto 0) := (others => '0');
    signal thr_empty     : std_ulogic := '1'; -- High όταν το th_reg έχει δεδομένα
    signal tr_empty   : std_ulogic := '1'; -- High when THR holds data to be transmitted
    signal thr_flag,tr_flag    : std_ulogic := '0'; -- toggles each transmission
    signal thr_flag_held,tr_flag_held : std_ulogic := '1'; -- toggles each transmission
    signal tx_shift_reg: std_ulogic_vector(12 downto 0) := (others => '1'); -- Max: 1 start + 8 data + 1 parity + 2 stop + 1 idle
    signal tx_bit_cnt  : integer range 0 to 15 := 0;
    signal tx_clk_div  : unsigned(3 downto 0) := (others => '0');
    signal tx_busy     : std_ulogic := '0';

    signal r_tre       : std_ulogic := '1';
    signal r_tro       : std_ulogic := '1';

    -- Negative logic load tracking
    signal n_thrl_prev : std_ulogic := '1';


    -- Receiver Internal Signals (Shared declaration for Part 2)
    signal rx_clk_div  : unsigned(3 downto 0) := (others => '0');
    signal rx_busy     : std_ulogic := '0';
    signal rx_sample_en: std_ulogic := '0';
    signal rx_bit_cnt  : integer range 0 to 15 := 0;
    signal rx_shift_reg: std_ulogic_vector(7 downto 0) := (others => '0');

    signal r_dr        : std_ulogic := '0';
    signal r_pe        : std_ulogic := '0';
    signal r_fe        : std_ulogic := '0';
    signal r_oe        : std_ulogic := '0';
    signal rhr_reg     : std_ulogic_vector(7 downto 0) := (others => '0');

begin

    ---------------------------------------------------------------------------
    -- Control Register Latch (Asynchronous / Transparent Latch)
    ---------------------------------------------------------------------------
    process(crl_i, pi_i, sbs_i, wls_i, epe_i, mr_i)
    begin
        if mr_i = '1' then
            r_pi  <= '0';
            r_sbs <= '0';
            r_wls <= "00";
            r_epe <= '0';
        elsif crl_i = '1' then
            r_pi  <= pi_i;
            r_sbs <= sbs_i;
            r_wls <= wls_i;
            r_epe <= epe_i;
        end if;
    end process;
---------------------------------------------------------------------------
--- load Transmitter Holding Register
    process(n_thrl_i,mr_i,tr_i) 
    begin
      if mr_i = '1' then
        th_reg <= (others => '0');
      elsif falling_edge(n_thrl_i) then
            th_reg <= tr_i;
      end if;
    end process;
        
      
    process(n_thrl_i,mr_i)
    begin
      if mr_i = '1' then
        thr_flag_held <= not thr_flag;
      elsif rising_edge(n_thrl_i) then
        -- 1. Φόρτωση από το Bus στο th_reg (στην ανερχόμενη ακμή του n_thrl_i)
	    thr_flag_held  <= thr_flag; -- makes thr_empty false
      end if;
    end process;

    thr_empty <=  thr_flag xor thr_flag_held;


    -- Load TR on falling edge of TRC
    process(trc_i,mr_i,tr_empty,thr_empty)
    begin
      if mr_i = '1' then
        tx_reg      <= (others => '0');
	tr_flag_held   <= not tr_flag;
      elsif falling_edge(trc_i) and tr_empty = '1' and thr_empty = '0' then
        -- 2. Μεταφορά από th_reg σε tx_reg (Shift μέσα στο FIFO)
        -- Αν το tx_reg είναι άδειο (ή πρόκειται να αδειάσει επειδή ξεκινάει TX)
            tx_reg      <= th_reg;
	    thr_flag    <= not thr_flag;
	    tr_flag_held  <= tr_flag;
      end if;
    end process;


    tr_empty <= tr_flag xor tr_flag_held;


---------------------------------------------------------------------------
-- Transmitter Holding Register (THR) & FIFO Load Interface
---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Transmitter Baud Rate Generator & Shift Register Controller
    ---------------------------------------------------------------------------
    process(trc_i, mr_i)
        variable i          : integer range 0 to 7;
        variable wlen       : integer range 5 to 8;
        variable parity_bit : std_ulogic;
        variable total_bits : integer range 6 to 12;
        variable tx_frame   : std_ulogic_vector(12 downto 0);
    begin
        if mr_i = '1' then
            tx_clk_div   <= (others => '0');
            tx_shift_reg <= (others => '1');
            tx_bit_cnt   <= 0;
            tx_busy      <= '0';
            r_tre        <= '1';
            r_tro        <= '1';
        elsif rising_edge(trc_i) then
            wlen := get_word_length(r_wls);

            if tx_busy = '0' then
                r_tre <= tr_empty;

                -- Check if there is data pending in THR to start transmission
                if tr_empty = '0' then
                    tx_clk_div <= (others => '0');
                    tx_busy    <= '1';
                    r_tre      <= '0';

                    -- Frame Compilation
                    tx_frame := (others => '1');
                    tx_frame(0) := '0'; -- Start Bit

                    -- Load right-justified data bits
                    for j in 0 to 7 loop
			if j < wlen then
                           tx_frame(1 + j) := tx_reg(j);
		        end if;
                    end loop;

                    -- Handle Parity Insertion
                    if r_pi = '0' then
                        parity_bit := calc_parity(tx_reg, wlen, r_epe);
                        tx_frame(1 + wlen) := parity_bit;

                        -- Add Stop bits (High select 2 [or 1.5 if 5-bit word], Low selects 1)
                        if r_sbs = '1' then
                            tx_frame(2 + wlen) := '1';
                            tx_frame(3 + wlen) := '1';
                            total_bits := 4 + wlen;
                        else
                            tx_frame(2 + wlen) := '1';
                            total_bits := 3 + wlen;
                        end if;
                    else
                        -- No parity bit
                        if r_sbs = '1' then
                            tx_frame(1 + wlen) := '1';
                            tx_frame(2 + wlen) := '1';
                            total_bits := 3 + wlen;
                        else
                            tx_frame(1 + wlen) := '1';
                            total_bits := 2 + wlen;
                        end if;
                    end if;

                    tx_shift_reg <= tx_frame;
                    tx_bit_cnt   <= total_bits;
	            tr_flag <= not tr_flag;
                else
                    r_tro <= '1'; -- Idle state
                end if;

            else
                -- Shift Out Process driven by 16x baud clock tick
                tx_clk_div <= tx_clk_div + 1;

                if tx_clk_div = 15 then
                    r_tro <= tx_shift_reg(0);
                    tx_shift_reg <= '1' & tx_shift_reg(12 downto 1);

                    if tx_bit_cnt > 1 then
                        tx_bit_cnt <= tx_bit_cnt - 1;
                    else
                        tx_busy <= '0';
                        r_tre   <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Drive static status output lines for Transmitter
    tro_o  <= r_tro;
    ---------------------------------------------------------------------------
    -- Λογική Δέκτη (Receiver) & Δειγματοληψία 16x
    ---------------------------------------------------------------------------
    process(rrc_i, mr_i, n_drr_i)
        variable rx_wlen       : integer;
        variable rx_parity_bit : std_ulogic;
        variable rx_calc_p     : std_ulogic;
    begin
        if mr_i = '1' then
            rx_clk_div   <= (others => '0');
            rx_busy      <= '0';
            rx_bit_cnt   <= 0;
            rx_shift_reg <= (others => '0');
            r_dr         <= '0';
            r_pe         <= '0';
            r_fe         <= '0';
            r_oe         <= '0';
            rhr_reg      <= (others => '0');
        elsif n_drr_i = '0' then
            r_dr         <= '0'; -- Ασύγχρονος μηδενισμός του Data Received (DR)
        elsif rising_edge(rrc_i) then
            rx_wlen := get_word_length(r_wls);

            if rx_busy = '0' then
                -- Ανίχνευση Start Bit (Falling Edge στην είσοδο r_i)
                if r_i = '0' then
                    rx_busy    <= '1';
                    rx_clk_div <= (others => '0');
                    rx_bit_cnt <= 0;
                end if;
            else
                rx_clk_div <= rx_clk_div + 1;

                -- Δειγματοληψία στο μέσο κάθε bit (Tick 7 στον μετρητή διαιρέτη 16x)
                if rx_clk_div = 7 then
                    if rx_bit_cnt = 0 then
                        -- Επιβεβαίωση Start Bit
                        if r_i = '0' then
                            rx_bit_cnt <= rx_bit_cnt + 1;
                        else
                            rx_busy <= '0'; -- Ψευδές Start Bit
                        end if;
                    
                    elsif rx_bit_cnt <= rx_wlen then
                        -- Ολίσθηση και αποθήκευση των Data Bits
                        rx_shift_reg(rx_bit_cnt - 1) <= r_i;
                        rx_bit_cnt <= rx_bit_cnt + 1;
                    
                    elsif (r_pi = '0' and rx_bit_cnt = rx_wlen + 1) then
                        -- Λήψη Parity Bit
                        rx_parity_bit := r_i;
                        rx_calc_p := calc_parity(rx_shift_reg, rx_wlen, r_epe);
                        
                        if rx_parity_bit /= rx_calc_p then
                            r_pe <= '1';
                        else
                            r_pe <= '0';
                        end if;
                        
                        rx_bit_cnt <= rx_bit_cnt + 1;
                    else
                        -- Έλεγχος Stop Bit & Ολοκλήρωση Λήψης
                        if r_i = '0' then
                            r_fe <= '1'; -- Framing Error αν το Stop Bit είναι '0'
                        else
                            r_fe <= '0';
                        end if;

                        -- Έλεγχος Overrun Error (Αν το προηγούμενο DR δεν είχε γίνει reset)
                        if r_dr = '1' then
                            r_oe <= '1';
                        else
                            r_oe <= '0';
                        end if;

                        -- Μεταφορά των δεδομένων στον Receiver Holding Register (RHR)
                        -- Τα δεδομένα ευθυγραμμίζονται δεξιά (Right-Justified)
                        rhr_reg <= (others => '0');
                        rhr_reg(rx_wlen-1 downto 0) <= rx_shift_reg(rx_wlen-1 downto 0);
                        
                        r_dr    <= '1';  -- Ενεργοποίηση Data Received Flag
                        rx_busy <= '0'; -- Ο δέκτης είναι πλέον έτοιμος για την επόμενη λήψη
                    end if;
                end if;
            end if;
        end if;
    end process;

    ---------------------------------------------------------------------------
    -- Έλεγχος Τρισχιδών Εξόδων (Tri-state / Bus Connection Control)
    ---------------------------------------------------------------------------
    
    -- rrd_i: '0' -> Συνδέει τα περιεχόμενα του RHR στις εξόδους rr_o
    --        '1' -> Αποσυνδέει τις εξόδους (High-Impedance 'Z')
    rr_o <= rhr_reg when (rrd_i = '0') else (others => 'Z');

    -- sfd_i: '0' -> Επιτρέπει την έξοδο των PE, FE, OE, THRE στα pins
    --        '1' -> Αποσυνδέει τις εξόδους κατάστασης σε High-Impedance 'Z'
    pe_o   <= (r_pe and not r_pi) when (sfd_i = '0') else 'Z'; -- Αν r_pi='1', το PE είναι '0'
    fe_o   <= r_fe                when (sfd_i = '0') else 'Z';
    oe_o   <= r_oe                when (sfd_i = '0') else 'Z';
    thre_o <= thr_empty           when (sfd_i = '0') else 'Z';
    tre_o <= r_tre                when (sfd_i = '0') else 'Z';

    -- Μόνιμη οδήγηση των εξόδων που δεν επηρεάζονται από τα rrd_i / sfd_i
    dr_o  <= r_dr;

end architecture RTL;

