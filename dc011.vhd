library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity dc011 is
port (
  clk:    in  std_logic;
  n_rst:  in  std_logic;
  d0:  in  std_logic;
  d1:  in  std_logic;
  n_vid_wr:  in  std_logic;
  dw:  in  std_logic;
  hold_req:  in  std_logic;
  LBA:   out std_logic_vector (7 downto 0);
  dot_clock:   out std_logic;
  char_clk:   out std_logic;
  n_write_lb:   out std_logic;
  vsr_ld:   out std_logic;
  n_addr_ld:   out std_logic;
  n_hdrive: out  std_ulogic;
  hblank : out  std_ulogic;
  vrst : out  std_ulogic;
  vdrive: out  std_ulogic;
  n_vblank : out  std_ulogic
);
end entity;

architecture behaviour of dc011 is
  signal hcdiv_out: std_logic_vector (8 downto 0);
  signal vcdiv_out: std_logic_vector (9 downto 0);
  signal vtdiv_out: std_logic_vector (9 downto 0);
  signal cnt: std_logic_vector (7 downto 0);
  signal dot_div: std_logic_vector (3 downto 0);
  signal clk80: std_logic;
  signal clk132: std_logic;
  signal clk80_half: std_logic;
  signal clk132_half: std_logic;
  signal dot_clock_s: std_logic;
  signal dot_clock_d: std_logic;
  signal mode80: std_logic;
  signal double_width: std_logic := '0';
  signal interlaced: std_logic;
  signal hertz60: std_logic;
  signal reset_count: std_logic;
  signal n_Q_tmp: std_logic;
  signal dwh: std_logic;
  signal clk_hf: std_logic;
  signal clk_2hf: std_logic;
  signal char_clk_half: std_logic;
  signal vsr_ld_tmp: std_logic;
   component JK_FF is
   port( 
     J: in std_logic;
     K: in std_logic;
     C: in std_logic;
     S: in std_logic;
     CLOCK: in std_logic;
     Q: out std_ulogic;
     n_Q: out std_ulogic
   );
   end component;
   component D_FF is
   port( 
     D: in std_logic;
     CLOCK: in std_logic;
     Q: out std_ulogic
   );
   end component;
  component SR_FF is
    port( 
     S: in std_logic;
     R: in std_logic;
     CLOCK: in std_logic;
     Q: out std_ulogic;
     n_Q: out std_ulogic
    );
   end component;
    component static_clk_divider is
       generic (
          -- frequency divisor, <o_clk_freq>=<i_clk_freq>/g_FREQ_DIV
          g_FREQ_DIV : integer range 2 to integer'high := 5
       );
       port (
          i_clk : in  std_ulogic; -- input clock signal
          i_rst : in  std_ulogic; -- reset signal
          o_clk : out std_ulogic -- final output clock
       );
    end component;
    component onetoN_divider is
    generic (
        N           : integer
    );
    port (
        rst         : in std_logic;
        clk_i       : in std_logic;
        modulus_sel : in std_logic;
        clk_o       : out std_logic
    );
    end component;
     component dot_counter is
     port (
        dot_clk_s : in  std_ulogic; -- input clock signal
        mode80: in std_ulogic;
        i_rst : in  std_ulogic; -- reset signal
       
        write_lb : out std_ulogic;
        char_clk : out std_ulogic;
        clk80_half: out std_ulogic;
        dot_div : out std_ulogic_vector(0 to 3)
    );
    end component;
    component hor_counter is
    port (
        char_clk : in  std_ulogic; -- input clock signal
        mode80: in std_ulogic;
        i_rst : in  std_ulogic; -- reset signal
        clock_2hf: out std_ulogic; 
        clock_hf: out std_ulogic; 
        div_out : out std_ulogic_vector(0 to 8);
        LBA : out std_ulogic_vector(0 to 7)
    );
    end component;
    component ver_counter is
    port (
        clock_2hf: in  std_ulogic; -- input clock signal
        i_rst : in  std_ulogic; -- reset signal
        mode80: in  std_ulogic;
        interlaced: in  std_ulogic;
        hertz60: in  std_ulogic;
        n_vrst : out  std_ulogic;
        div_out : out std_ulogic_vector(0 to 9)
    );
    end component;
    component htiming is
    port (
        i_clk: in  std_ulogic; -- input clock signal
        extra_clk: in  std_ulogic; -- input clock signal
        i_rst : in  std_ulogic; -- reset signal
        div_in : in std_ulogic_vector(0 to 8);
        mode80 : in  std_ulogic; 
        addr_cnt_on : out  std_ulogic;
        n_hdrive: out  std_ulogic;
        hblank : out  std_ulogic
    );
    end component;
    component vtiming is
    port (
        i_clk: in  std_ulogic;
        i_rst: in  std_ulogic; 
        clk_2hf: in  std_ulogic; 
        hertz60: in  std_ulogic; 
        interlaced: in  std_ulogic; 
        vdrive: out  std_ulogic;
        n_vblank : out  std_ulogic;
        vrst : out  std_ulogic;
        div_out : out std_ulogic_vector(0 to 9)
    );
    end component;
begin
    clock_divider_80 :onetoN_divider
       generic map(
          N => 2
       )
       port map(
          clk_i => clk,
          rst => reset_count,
          modulus_sel => '1',
          clk_o => clk80
       );
     dot_counter_inst :dot_counter
     port map(
        dot_clk_s => dot_clock_s,
        mode80 => mode80,
        i_rst => reset_count,
        char_clk => char_clk,
        write_lb => n_write_lb,
        dot_div => dot_div,
        clk80_half => clk80_half
    );
    clock_divider_dot_half :static_clk_divider
       generic map(
          g_FREQ_DIV => 2
       )
       port map(
          i_clk => char_clk,
          i_rst => reset_count,
          o_clk => char_clk_half 
       );
    hor_counter_inst :hor_counter 
    port map (
        char_clk => char_clk,
        mode80 => mode80,
        i_rst  => reset_count,
        div_out => hcdiv_out,
        clock_hf => clk_hf,
        clock_2hf => clk_2hf,
        LBA => LBA
       
    );
    ver_counter_inst :ver_counter 
    port map (
        clock_2hf => clk_2hf,
        mode80 => mode80,
        interlaced => interlaced,
        hertz60 => hertz60,
        div_out => vcdiv_out,
        i_rst => reset_count,
        n_vrst => open
    );
    htiming_inst: htiming
    port map (
        i_clk => clk_hf,
        extra_clk => clk,
        i_rst => reset_count,
        div_in => hcdiv_out,
        mode80 => mode80,
        addr_cnt_on => open,
        n_hdrive => n_hdrive,
        hblank => hblank
    );
    vtiming_inst: vtiming
    port map (
        i_clk => clk_2hf,
        i_rst => reset_count,
        clk_2hf => clk_2hf,
        hertz60 => hertz60,
        interlaced => interlaced,
        vdrive => vdrive,
        n_vblank => n_vblank,
        vrst => vrst,
        div_out => vtdiv_out
    );
    clock_divider_132_half :static_clk_divider
       generic map(
          g_FREQ_DIV => 2
       )
       port map(
          i_clk => clk,
          i_rst => reset_count,
          o_clk => clk132_half
       );
    SR_FF_1: SR_FF
      port map(
       S => '1',
       R => '1',
       CLOCK => clk,
       Q => open,
       n_Q => n_Q_tmp
      );
    D_FF_1: D_FF
      port map(
       CLOCK => not hold_req,
       D => n_Q_tmp,
       Q => dwh
      );
    JK_FF_2: JK_FF
      port map(
       J => '1',
       K => '0',
       C => '1',
       S => '1',
       CLOCK => hold_req,
       Q => open,
       n_Q => n_addr_ld
      );
    -- clock_divider_80_half :static_clk_divider
    --   generic map(
    --      g_FREQ_DIV => 2
    --   )
    --   port map(
    --      i_clk => clk80,
    --      i_rst => not n_rst,
    --      o_clk => clk80_half
    --   );
  -- input decoder
  process (n_vid_wr)
  begin
     if n_vid_wr = '0' and falling_edge(n_vid_wr) then
       if d0 = '0' and d1 = '0'  then
          report "Set 80 column mode interlaced";
          mode80 <= '1';
          interlaced <= '1';
       elsif d0 = '1' and d1 = '0'  then
          report "Set 132 column mode interlaced";
          mode80 <= '0';
          interlaced <= '1';
       elsif d0 = '0' and d1 = '1'  then
          report "Set 60hz non interlaced";
          hertz60 <= '1';
          interlaced <= '0';
       else
          report "Set 50hz non interlaced";
          hertz60 <= '0';
          interlaced <= '0';
       end if;
     end if;
  end process;
  reset_count <= not n_vid_wr;
  dot_clock_s <=  clk80 when mode80 = '1' else clk;
  dot_clock_d <=  clk80_half when mode80 = '1' else clk132_half;
  dot_clock <= dot_clock_s when double_width = '0' else dot_clock_d;
  process(dot_clock,char_clk)
  begin
     if double_width = '0' then
       if rising_edge(dot_clock) then
         if char_clk = '1' then
             vsr_ld_tmp <= '0';
         else
             vsr_ld_tmp <= '1';
         end if;
       else
         vsr_ld_tmp <= vsr_ld_tmp;
       end if;
     else
       if falling_edge(dot_clock) then
         if char_clk = '1' then
             vsr_ld_tmp <= '0';
         else
             vsr_ld_tmp <= '1';
         end if;
       else
         vsr_ld_tmp <= vsr_ld_tmp;
       end if;
     end if;
  end process;
  vsr_ld <= vsr_ld_tmp and (not char_clk) when double_width = '0' else vsr_ld_tmp and (not char_clk) and char_clk_half;

end architecture;
