library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.dc0112_pkg.all;



architecture behaviour of dc011 is
  signal hcdiv_out: std_ulogic_vector (8 downto 0);
  signal vcdiv_out: std_ulogic_vector (9 downto 0);
  signal dot_div: std_ulogic_vector (3 downto 0);
  signal clk80: std_ulogic;
  signal comp_sync: std_ulogic := '0' ;
  signal addr_cnt_on: std_ulogic := '0' ;
  signal clk80_half: std_ulogic;
  signal clk132_half: std_ulogic := '0';
  signal dot_clock_s: std_ulogic;
  signal dot_clock_d: std_ulogic;
  signal mode80: std_ulogic := '1';
  signal double_width: std_ulogic := '0';
  signal interlaced: std_ulogic := '0';
  signal hertz60: std_ulogic := '1';
  signal reset_count: std_ulogic := '0';
  signal reset_count2: std_ulogic := '0';
  signal n_Q_tmp: std_ulogic;
  signal clk_hf: std_ulogic;
  signal clk_2hf: std_ulogic;
  signal char_clk_half: std_ulogic := '0';
  signal char_clk_delayed: std_ulogic;
  signal vsr_ld_tmp: std_ulogic;
  signal vsr_ld_tmp_l: std_ulogic := '0';
  signal vsr_ld_tmp_h: std_ulogic := '0';
  signal n_vrst: std_ulogic;
  signal dot_clock: std_ulogic := '0';
  signal char_clk: std_ulogic := '0';
  signal write_lb: std_ulogic;
  signal addr_ld: std_ulogic;
  signal clk_in: std_ulogic;
  signal hold_req: std_ulogic := '0';
  signal hblank : std_ulogic := '0';
begin
    clk_in <= clk24_i;
    dot_clock_o <= dot_clock;
    char_clk_o <= char_clk;
    hold_req <= hold_req_i;
    hblank_o <= hblank;
    clock_divider_80 :NtoM_divider
       generic map(
          N => 3,
          M => 2
       )
       port map(
          clk_i => clk_in,
          rst_i => reset_count,
          clk_f_i => clk_i,
          clk_o => clk80
       );
     dot_counter_inst :dot_counter
     port map(
        dot_clk_s_i => dot_clock_s,
        dot_clk_i => dot_clock,
        mode80_i => mode80,
        rst_i => reset_count,
        char_clk_o => char_clk,
        write_lb_o => write_lb,
        dot_div_o => dot_div,
        clk80_half_o => clk80_half
    );
    delay_inst: delay
    generic map(CYCLES => 1, 
            WIDTH => 1)
    port map(clk => dot_clock_s,
         rst => reset_count,
         en  => '1',
         input => ""&char_clk, 
         output(0) => char_clk_delayed
    );
    --------------------------------------------------------------
    clock_divider_dot_half : process(char_clk_delayed,reset_count)
    begin
        if(reset_count = '1') then
           char_clk_half <= '0';
	elsif(rising_edge(char_clk_delayed)) then
	   char_clk_half <= not char_clk_half;
	end if;
    end process clock_divider_dot_half;

    --------------------------------------------------------------
    clock_divider_132_half : process(clk_in,reset_count)
    begin
       if(reset_count = '1') then
       	       clk132_half<= '0';
       elsif(rising_edge(clk_in)) then
               clk132_half <= not clk132_half;
       end if;
    end process clock_divider_132_half;

    --------------------------------------------------------------
    hor_counter_inst :hor_counter 
    port map (
        char_clk_i => char_clk,
        clk_delay_i => dot_clock,
        mode80_i => mode80,
        rst_i  => reset_count,
        div_o => hcdiv_out,
        clock_hf_o => clk_hf,
        clock_2hf_o => clk_2hf,
        LBA_o => LBA_o
    );
    ver_counter_inst :ver_counter 
    port map (
        clock_2hf_i => clk_2hf,
        clock_h5_i => char_clk, --hcdiv_out(4),
        hcdiv_i => hcdiv_out,
        interlaced_i => interlaced,
        hertz60_i => hertz60,
        div_o => vcdiv_out,
        rst_i => reset_count,
        n_vrst_o => n_vrst
    );
    htiming_inst: htiming
    port map (
        clk_i => clk_hf,
        extra_clk_i => dot_clock_s,
        rst_i => reset_count,
        div_in => hcdiv_out,
        mode80_i => mode80,
        addr_cnt_on_o => addr_cnt_on,
        n_hdrive_o => n_hdrive_o,
        hblank_o => hblank
    );
    vtiming_inst: vtiming
    port map (
        clk_i => clk_2hf,
        rst_i => reset_count,
        n_vrst_i => n_vrst,
        clk_2hf_i => clk_2hf,
        vcdiv_i => vcdiv_out,
        hertz60_i => hertz60,
        interlaced_i => interlaced,
        vdrive_o => vdrive_o,
        n_vblank_o => n_vblank_o,
        vrst_o => vrst_o
    );

    comp_sync_gen_inst: comp_sync_gen
    port map(
       clk132_half_i => clk132_half,
       char_clk_i => char_clk,
       comp_sync_o => comp_sync,
       rst_i => reset_count,
       mode80_i => mode80,
       hblank_i => hblank,
       vblank_i => not n_vblank_o,
       vcdiv_i => vcdiv_out,
       dot_div_i => dot_div,
       hcdiv_i => hcdiv_out
    );
    SR_FF_1: SR_FF_n
      port map(
       D => not dw_i,
       S => addr_ld,
       R => '1',
       n_clk_i => n_vrst,
       Q => open,
       n_Q => n_Q_tmp
      );
    D_FF_1: D_FF_n
      port map(
       n_clk_i => not hold_req,
       D => n_Q_tmp,
       Q => double_width 
      );
    JK_FF_2: JK_FF_n
      port map(
       J => '1',
       K => '0',
       R => char_clk,
       S => '1',
       n_clk_i => hold_req,
       Q => addr_ld,
       n_Q => n_addr_ld_o
      );
  mode_decode: process (n_vid_wr_i) is
  begin
     if falling_edge(n_vid_wr_i) then
       if d0_i = '0' and d1_i = '0'  then
          report "Set 80 column mode interlaced";
          mode80 <= '1';
          interlaced <= '1';
       elsif d0_i = '1' and d1_i = '0'  then
          report "Set 132 column mode interlaced";
          mode80 <= '0';
          interlaced <= '1';
       elsif d0_i = '0' and d1_i = '1'  then
          report "Set 60hz non interlaced";
          hertz60 <= '1';
          interlaced <= '0';
       else
          report "Set 50hz non interlaced";
          hertz60 <= '0';
          interlaced <= '0';
       end if;
     end if;
  end process mode_decode;
  reset_count <= not n_vid_wr_i;
  dot_clock_s <=  clk80 when mode80 = '1' else clk_in;
  dot_clock_d <=  clk80_half when mode80 = '1' else clk132_half;
-- dot_clock MUX
  dot_clock <= dot_clock_s when double_width = '0' else dot_clock_d;
  n_write_lb_o <= write_lb nand hold_req;
-- vsr_ld MUX
  vsr_ld_tmp <= dot_div(0) and (not dot_div(1)) and (not dot_div(2)) and dot_div(3) when mode80 = '1' else (nor dot_div(3 downto 0));
  vsr_ld_o <= vsr_ld_tmp  when double_width = '0' else char_clk_half and not char_clk_delayed;
--------------------------------------------------------------  

  comp_sync_o <= comp_sync;
  --addr_count_o <= ( ( char_clk and not hblank and hold_req )  or (hblank and not addr_cnt_on) or vrst_o) ;
  addr_count_o <=   ((addr_cnt_on or  hold_req) and (char_clk  and   (not hblank))) when double_width = '0'
		    else  ((addr_cnt_on or  hold_req) and (char_clk  and   (not hblank) and char_clk_half));
  ----  TODO check timingsO
  
end architecture;
