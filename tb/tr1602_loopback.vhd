-- ============================================================================
-- Τμήμα: Βιβλιοθήκες (VHDL-2008 Standard)
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ============================================================================
-- Δήλωση της Οντότητας του Testbench (Δεν έχει Ports)
-- ============================================================================
entity tb_TR1602 is
end entity tb_TR1602;

-- ============================================================================
-- Αρχιτεκτονική του Testbench
-- ============================================================================
architecture sim of tb_TR1602 is

    -- Σταθερές Χρονισμού (Προσομοίωση στα 115200 bps με 16x Ρολόι)
    -- 115200 * 16 = 1.8432 MHz -> Περίοδος Ρολογιού ~542.535 ns
    constant CLK_PERIOD : time := 542.535 ns;

    -- Σήματα Διασύνδεσης με το UUT
    signal rrd_s      : std_ulogic := '1';
    signal rr_s       : std_ulogic_vector(7 downto 0);
    signal pe_s       : std_ulogic;
    signal fe_s       : std_ulogic;
    signal oe_s       : std_ulogic;
    signal sfd_s      : std_ulogic := '0';
    signal rrc_s      : std_ulogic := '0';
    signal n_drr_s    : std_ulogic := '1';
    signal dr_s       : std_ulogic;
    signal r_s        : std_ulogic := '1';
    signal mr_s       : std_ulogic := '0';
    signal thre_s     : std_ulogic;
    signal n_thrl_s   : std_ulogic := '1';
    signal tre_s      : std_ulogic;
    signal tro_s      : std_ulogic;
    signal tr_s       : std_ulogic_vector(7 downto 0) := (others => '0');
    signal crl_s      : std_ulogic := '0';
    signal pi_s       : std_ulogic := '0';
    signal sbs_s      : std_ulogic := '0';
    signal wls_s      : std_ulogic_vector(1 downto 0) := "11"; -- Προεπιλογή: 8 bits
    signal epe_s      : std_ulogic := '1'; -- Προεπιλογή: Even parity
    signal trc_s      : std_ulogic := '0';

    -- Βοηθητικό σήμα για τον τερματισμό της προσομοίωσης
    signal sim_done   : boolean := false;

begin

    -- ============================================================================
    -- Διασύνδεση της Υπό Δοκιμή Συσκευής (Unit Under Test - UUT)
    -- ============================================================================
    uut: entity work.TR1602
        port map (
            rrd_i    => rrd_s,
            rr_o     => rr_s,
            pe_o     => pe_s,
            fe_o     => fe_s,
            oe_o     => oe_s,
            sfd_i    => sfd_s,
            rrc_i    => rrc_s,
            n_drr_i  => n_drr_s,
            dr_o     => dr_s,
            r_i      => r_s,
            mr_i     => mr_s,
            thre_o   => thre_s,
            n_thrl_i => n_thrl_s,
            tre_o    => tre_s,
            tro_o    => tro_s,
            tr_i     => tr_s,
            crl_i    => crl_s,
            pi_i     => pi_s,
            sbs_i    => sbs_s,
            wls_i    => wls_s,
            epe_i    => epe_s,
            trc_i    => trc_s
        );

    -- ============================================================================
    -- Γεννήτριες Ρολογιού (16x Baud Rate Clock)
    -- ============================================================================
    
    -- Ρολόι Πομπού (Transmitter Clock)
    tx_clk_gen : process
    begin
        while not sim_done loop
            trc_s <= '0';
            wait for CLK_PERIOD / 2;
            trc_s <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process tx_clk_gen;

    -- Ρολόι Δέκτη (Receiver Clock)
    rx_clk_gen : process
    begin
        while not sim_done loop
            rrc_s <= '0';
            wait for CLK_PERIOD / 2;
            rrc_s <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process rx_clk_gen;

        -- ============================================================================
    -- Σύνδεση Loopback: Σύνδεση του Πομπού απευθείας στον Δέκτη για τη δοκιμή
    -- ============================================================================
    r_s <= tro_s;

    -- ============================================================================
    -- Κύρια Διεργασία Δοκιμών (Stimulus Process)
    -- ============================================================================
    stim_process : process
    begin
        -- ------------------------------------------------------------------------
        -- Βήμα 1: Αρχικοποίηση και Master Reset (MR)
        -- ------------------------------------------------------------------------
        report "Starting TR1602 Testbench Simulation..." severity note;
        mr_s <= '1';
        wait for CLK_PERIOD * 5;
        mr_s <= '0';
        wait for CLK_PERIOD * 5;

        -- Έλεγχος αν οι έξοδοι πήγαν στις σωστές αρχικές τιμές
        assert (thre_s = '1' or sfd_s = '1') report "Error: THRE should be high after reset" severity error;
        assert (tre_s = '1') report "Error: TRE should be high after reset" severity error;
        assert (tro_s = '1') report "Error: TRO should be high (Idle) after reset" severity error;

        -- ------------------------------------------------------------------------
        -- Βήμα 2: Διαμόρφωση Control Register (8 Data Bits, Even Parity, 1 Stop Bit)
        -- ------------------------------------------------------------------------
        wls_s <= "11"; -- 8 Bits
        pi_s  <= '0';  -- Enable Parity
        epe_s <= '1';  -- Even Parity
        sbs_s <= '0';  -- 1 Stop Bit

        crl_s <= '1';  -- Strobe Control Register Load
        wait for CLK_PERIOD * 2;
        crl_s <= '0';
        wait for CLK_PERIOD * 2;

        -- ------------------------------------------------------------------------
        -- Βήμα 3: Φόρτωση Δεδομένων στον Πομπό (THR Load)
        -- ------------------------------------------------------------------------
        report "Loading data X'A5' into Transmitter..." severity note;
        tr_s     <= X"A5"; -- Δεδομένα προς αποστολή: 10100101
        n_thrl_s <= '0';   -- Ενεργοποίηση strobe φόρτωσης
        wait for CLK_PERIOD * 3;
        n_thrl_s <= '1';   -- Απενεργοποίηση strobe (Η μεταφορά ξεκινά)

        -- Αναμονή για τη μεταφορά από το THR στο TR
        wait for CLK_PERIOD * 5;
        assert (thre_s = '1' or sfd_s = '1') report "Error: THRE should return high after transfer to TR" severity error;
        assert (tre_s = '0') report "Error: TRE should be low during transmission" severity error;

        -- ------------------------------------------------------------------------
        -- Βήμα 4: Αναμονή Ολοκλήρωσης της Μετάδοσης / Λήψης (Loopback)
        -- ------------------------------------------------------------------------
        report "Waiting for transmission and reception to complete..." severity note;

        -- Αναμονή μέχρι ο δέκτης να υψώσει το σήμα Data Received (dr_o)
        -- Ένα πλήρες frame χρειάζεται: 1 start + 8 data + 1 parity + 1 stop = 11 bits.
        -- Κάθε bit διαρκεί 16 κύκλους ρολογιού. Συνολικά ~176 κύκλοι.
        wait until dr_s = '1' for CLK_PERIOD * 200;

        assert (dr_s = '1') report "Error: Timeout! Data Received flag (DR) not set" severity failure;
        report "Data successfully received by the digital logic!" severity note;

        -- ------------------------------------------------------------------------
        -- Βήμα 5: Έλεγχος Αναγνώρισης Δεδομένων και Τρισχιδών Εξόδων (Tri-state)
        -- ------------------------------------------------------------------------
        -- Έλεγχος ότι η έξοδος rr_o είναι σε High-Impedance όταν rrd_i = '1'
        assert (rr_s = "ZZZZZZZZ") report "Error: rr_o must be Z when rrd_i is high" severity error;

        -- Ενεργοποίηση της εξόδου του δέκτη (Read Enable)
        rrd_s <= '0';
        wait for CLK_PERIOD * 2;

        -- Έλεγχος αν τα δεδομένα εξόδου ταιριάζουν με αυτά που στείλαμε (X"A5")
        assert (rr_s = X"A5") report "Error: Received data mismatch! Expected X'A5'" severity error;

        -- Έλεγχος σφαλμάτων (Δεν πρέπει να υπάρχει κανένα σφάλμα)
        assert (pe_s = '0' or sfd_s = '1') report "Error: Unexpected Parity Error" severity error;
        assert (fe_s = '0' or sfd_s = '1') report "Error: Unexpected Framing Error" severity error;
        assert (oe_s = '0' or sfd_s = '1') report "Error: Unexpected Overrun Error" severity error;

        -- ------------------------------------------------------------------------
        -- Βήμα 6: Μηδενισμός του Flag Λήψης (Data Receiver Reset)
        -- ------------------------------------------------------------------------
        n_drr_s <= '0'; -- Ασύγχρονο reset του DR flag
        wait for CLK_PERIOD * 3;
        n_drr_s <= '1';
        wait for CLK_PERIOD * 2;

        assert (dr_s = '0') report "Error: DR flag did not reset after n_drr_i" severity error;

        -- Αποσύνδεση του διαύλου δεδομένων ξανά
        rrd_s <= '1';
        wait for CLK_PERIOD * 2;

        -- ------------------------------------------------------------------------
        -- Τερματισμός Προσομοίωσης
        -- ------------------------------------------------------------------------
        report "Simulation finished successfully without critical errors!" severity note;
        sim_done <= true;
        wait;
    end process stim_process;

end architecture sim;

