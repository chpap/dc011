library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i8251A is
    Port (
        -- System and CPU Bus Signals
        clk_i         : in    STD_LOGIC;                      -- Main logic clock
        reset_i       : in    STD_LOGIC;                      -- System Reset (Active High)
        D_i           : in STD_LOGIC_VECTOR(7 downto 0);   -- Bidirectional Data Bus
        D_o           : out STD_LOGIC_VECTOR(7 downto 0);   -- Bidirectional Data Bus
        n_cs_i        : in    STD_LOGIC;                      -- Chip Select (Active Low)
        c_d_i         : in    STD_LOGIC;                      -- Control/Status = 1, Data = 0
        rd_n_i        : in    STD_LOGIC;                      -- Read Enable (Active Low)
        wr_n_i        : in    STD_LOGIC;                      -- Write Enable (Active Low)

        -- Serial Transmitter Signals
        txd_i         : out   STD_LOGIC := '1';               -- Transmit Serial Data
        txc_n_i       : in    STD_LOGIC;                      -- Transmitter Clock (Active Low)
        txrdy_o       : out   STD_LOGIC;                      -- Transmitter Ready for Byte
        txempty_o     : out   STD_LOGIC;                      -- Transmitter Shift Register Empty

        -- Serial Receiver Signals
        rxd_i         : in    STD_LOGIC;                      -- Receive Serial Data
        rxc_n_i       : in    STD_LOGIC;                      -- Receiver Clock (Active Low)
        rxrdy_o       : out   STD_LOGIC;                      -- Receiver Has Data Ready

        -- Modem Control Signals
        n_dsr_i       : in    STD_LOGIC := '1';               -- Data Set Ready (Active Low)
        n_dtr_o       : out   STD_LOGIC := '1';               -- Data Terminal Ready (Active Low)
        n_rts_o       : out   STD_LOGIC := '1';               -- Request to Send (Active Low)
        n_cts_i       : in    STD_LOGIC := '0'                -- Clear to Send (Active Low)
    );
end i8251A;

architecture Behavioral of i8251A is
    -- Internal Registers
    signal mode_reg     : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal command_reg  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal rx_data_reg  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal tx_data_reg  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    -- Sequencer States for Initialization
    type seq_state_type is (SET_MODE, SET_COMMAND);
    signal init_state   : seq_state_type := SET_MODE;

    -- Status Flags
    signal flag_txrdy   : STD_LOGIC := '1';
    signal flag_rxrdy   : STD_LOGIC := '0';
    signal flag_txempty : STD_LOGIC := '1';
    signal flag_pe      : STD_LOGIC := '0';
    signal flag_oe      : STD_LOGIC := '0';
    signal flag_fe      : STD_LOGIC := '0';

    -- Internal CPU Bus Data Buffer
    signal data_to_cpu  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    -- Serial Clock Edge Detection Registers
    signal txc_delayed  : STD_LOGIC := '0';
    signal rxc_delayed  : STD_LOGIC := '0';
    signal txc_falling  : STD_LOGIC := '0';
    signal rxc_falling  : STD_LOGIC := '0';

    -- Transmitter State Variables
    type tx_state_type is (TX_IDLE, TX_START, TX_DATA, TX_PARITY, TX_STOP);
    signal tx_state     : tx_state_type := TX_IDLE;
    signal tx_sr        : STD_LOGIC_VECTOR(7 downto 0) := (others => '1');
    signal tx_bit_cnt   : integer range 0 to 7 := 0;
    signal tx_parity_bit: STD_LOGIC := '0';

    -- Receiver State Variables
    type rx_state_type is (RX_IDLE, RX_START, RX_DATA, RX_PARITY, RX_STOP);
    signal rx_state     : rx_state_type := RX_IDLE;
    signal rx_sr        : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal rx_bit_cnt   : integer range 0 to 7 := 0;
    signal rx_parity_bit: STD_LOGIC := '0';
    signal rxc_tick_cnt : integer range 0 to 63 := 0;

    -- Decoded Parameters from Mode Register
    signal baud_factor  : STD_LOGIC_VECTOR(1 downto 0);
    signal char_len     : STD_LOGIC_VECTOR(1 downto 0);
    signal parity_en    : STD_LOGIC;
    signal parity_odd   : STD_LOGIC;
    signal stop_bits    : STD_LOGIC_VECTOR(1 downto 0);

begin
    -- Decode configuration variables from the Mode register
    baud_factor <= mode_reg(1 downto 0);
    char_len    <= mode_reg(3 downto 2);
    parity_en   <= mode_reg(4);
    parity_odd  <= not mode_reg(5);
    stop_bits   <= mode_reg(7 downto 6);

    -- Hardware Output Mappings
    txrdy_o   <= flag_txrdy and (not n_cts_i) and command_reg(0);
    rxrdy_o   <= flag_rxrdy and command_reg(2);
    txempty_o <= flag_txempty;
    n_dtr_o   <= not command_reg(1);
    n_rts_o   <= not command_reg(5);

    -- CPU Data Bus Tristate Interface
    D_o <= data_to_cpu when (n_cs_i = '0' and rd_n_i = '0') else (others => 'Z');

    -------------------------------------------------------------------------
    -- CPU Microprocessor Read & Write Logic
    -------------------------------------------------------------------------
    process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            init_state   <= SET_MODE;
            mode_reg     <= (others => '0');
            command_reg  <= (others => '0');
            flag_txrdy   <= '1';
            flag_rxrdy   <= '0';
            flag_oe      <= '0';
            flag_fe      <= '0';
            flag_pe      <= '0';
            tx_data_reg  <= (others => '0');
            data_to_cpu  <= (others => '0');
        elsif rising_edge(clk_i) then
            if n_cs_i = '0' and rd_n_i = '0' then
                if c_d_i = '1' then
                    data_to_cpu(0) <= flag_txrdy and (not n_cts_i);
                    data_to_cpu(1) <= flag_rxrdy;
                    data_to_cpu(2) <= flag_txempty;
                    data_to_cpu(3) <= flag_pe;
                    data_to_cpu(4) <= flag_oe;
                    data_to_cpu(5) <= flag_fe;
                    data_to_cpu(6) <= '0';
                    data_to_cpu(7) <= not n_dsr_i;
                else
                    data_to_cpu <= rx_data_reg;
                    flag_rxrdy  <= '0';
                end if;
            end if;

            if n_cs_i = '0' and wr_n_i = '0' then
                if c_d_i = '1' then
                    if init_state = SET_MODE then
                        mode_reg   <= D_i;
                        init_state <= SET_COMMAND;
                    else
                        command_reg <= D_i;
                        if D_i(4) = '1' then
                            flag_pe <= '0'; flag_oe <= '0'; flag_fe <= '0';
                        end if;
                        if D_i(6) = '1' then
                            init_state <= SET_MODE;
                        end if;
                    end if;
                else
                    tx_data_reg <= D_i;
                    flag_txrdy  <= '0';
                end if;
            end if;
            
            if tx_state = TX_START then
                flag_txrdy <= '1';
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------
    -- Serial Clock Domain Synchronizer
    -------------------------------------------------------------------------
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            txc_delayed <= txc_n_i;
            rxc_delayed <= rxc_n_i;
            
            txc_falling <= '0';
            if txc_delayed = '1' and txc_n_i = '0' then
                txc_falling <= '1';
            end if;
            
            rxc_falling <= '0';
            if rxc_delayed = '1' and rxc_n_i = '0' then
                rxc_falling <= '1';
            end if;
        end if;
    end process;

    -------------------------------------------------------------------------
    -- Asynchronous Serial Transmitter Core
    -------------------------------------------------------------------------
    process(clk_i, reset_i)
        variable max_bits : integer;
    begin
        if reset_i = '1' then
            tx_state     <= TX_IDLE;
            txd_i          <= '1';
            flag_txempty <= '1';
        elsif rising_edge(clk_i) then
            case char_len is
                when "00"   => max_bits := 4; -- 5 Bits
                when "01"   => max_bits := 5; -- 6 Bits
                when "10"   => max_bits := 6; -- 7 Bits
                when others => max_bits := 7; -- 8 Bits
            end case;

            if txc_falling = '1' then
                case tx_state is
                    when TX_IDLE =>
                        txd_i <= '1';
                        if flag_txrdy = '0' and command_reg(0) = '1' then
                            tx_sr        <= tx_data_reg;
                            flag_txempty <= '0';
                            tx_state     <= TX_START;
                        else
                            flag_txempty <= '1';
                        end if;

                    when TX_START =>
                        txd_i           <= '0';
                        tx_bit_cnt    <= 0;
                        tx_parity_bit <= parity_odd;
                        tx_state      <= TX_DATA;

                    when TX_DATA =>
                        txd_i           <= tx_sr(0);
                        tx_parity_bit <= tx_parity_bit xor tx_sr(0);
                        tx_sr         <= '0' & tx_sr(7 downto 1);
                        
                        if tx_bit_cnt = max_bits then
                            if parity_en = '1' then
                                tx_state <= TX_PARITY;
                            else
                                tx_state <= TX_STOP;
                            end if;
                        else
                            tx_bit_cnt <= tx_bit_cnt + 1;
                        end if;

                    when TX_PARITY =>
                        txd_i      <= tx_parity_bit;
                        tx_state <= TX_STOP;

                    when TX_STOP =>
                        txd_i      <= '1';
                        tx_state <= TX_IDLE;
                end case;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------------
    -- Asynchronous Serial Receiver Core
    -------------------------------------------------------------------------
    process(clk_i, reset_i)
        variable max_bits   : integer;
        variable match_tick : integer;
    begin
        if reset_i = '1' then
            rx_state     <= RX_IDLE;
            flag_rxrdy   <= '0';
            rxc_tick_cnt <= 0;
        elsif rising_edge(clk_i) then
            case char_len is
                when "00"   => max_bits := 4;
                when "01"   => max_bits := 5;
                when "10"   => max_bits := 6;
                when others => max_bits := 7;
            end case;

            if baud_factor = "10" then 
                match_tick := 15; -- x16 mode
            else 
                match_tick := 0;  -- x1 mode
            end if;

            if rxc_falling = '1' then
                case rx_state is
                    when RX_IDLE =>
                        if rxd_i = '0' and command_reg(2) = '1' then
                            rxc_tick_cnt <= 0;
                            rx_state     <= RX_START;
                        end if;

                    when RX_START =>
                        if baud_factor = "10" then
                            if rxc_tick_cnt = 7 then
                                if rxd_i = '0' then
                                    rxc_tick_cnt <= 0;
                                    rx_bit_cnt   <= 0;
                                    rx_parity_bit<= parity_odd;
                                    rx_state     <= RX_DATA;
                                else
                                    rx_state     <= RX_IDLE;
                                end if;
                            else
                                rxc_tick_cnt <= rxc_tick_cnt + 1;
                            end if;
                        else
                            rx_bit_cnt    <= 0;
                            rx_parity_bit <= parity_odd;
                            rx_state      <= RX_DATA;
                        end if;

                    when RX_DATA =>
                        if rxc_tick_cnt = match_tick then
                            rxc_tick_cnt  <= 0;
                            rx_sr(rx_bit_cnt) <= rxd_i;
                            rx_parity_bit <= rx_parity_bit xor rxd_i;
                            
                            if rx_bit_cnt = max_bits then
                                if parity_en = '1' then
                                    rx_state <= RX_PARITY;
                                else
                                    rx_state <= RX_STOP;
                                end if;
                            else
                                rx_bit_cnt <= rx_bit_cnt + 1;
                            end if;
                        else
                            rxc_tick_cnt <= rxc_tick_cnt + 1;
                        end if;

                    when RX_PARITY =>
                        if rxc_tick_cnt = match_tick then
                            rxc_tick_cnt <= 0;
                            if rx_parity_bit /= rxd_i then
                                flag_pe  <= '1';
                            end if;
                            rx_state     <= RX_STOP;
                        else
                            rxc_tick_cnt <= rxc_tick_cnt + 1;
                        end if;

                    when RX_STOP =>
                        if rxc_tick_cnt = match_tick then
                            rxc_tick_cnt <= 0;
                            if rxd_i = '0' then
                                flag_fe  <= '1';
                            end if;
                            if flag_rxrdy = '1' then
                                flag_oe  <= '1';
                            end if;
                            
                            rx_data_reg <= rx_sr;
                            flag_rxrdy  <= '1';
                            rx_state    <= RX_IDLE;
                        else
                            rxc_tick_cnt <= rxc_tick_cnt + 1;
                        end if;
                end case;
            end if;
        end if;
    end process;

end Behavioral;

