library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
package dc0112_pkg is

  function reverse_vector (a: in std_ulogic_vector) return std_ulogic_vector;
  function test_equal(a: in std_ulogic_vector;b: in std_ulogic_vector) return boolean;
  --function getMatSize (dim: integer) return integer;
  --attribute foreign of getMatSize : function is "VHPIDIRECT getMatSize";

  --type matrix_t is array (0 to getMatSize(0)-1, 0 to getMatSize(1)-1) of real;
  --type matrix_acc_t is access matrix_t;

  --impure function getMatPointer return matrix_acc_t;
  --attribute foreign of getMatPointer : function is "VHPIDIRECT getMatPointer";

  -- shared variable matrix: matrix_acc_t := getMatPointer;
  component D_FF is
   port( 
     D: in std_ulogic;
     n_clk_i: in std_ulogic;
     Q: out std_ulogic
   );
  end component;
  component JK_FF is
  port( 
    J: in std_ulogic;
    K: in std_ulogic;
    R: in std_ulogic;
    S: in std_ulogic;
    n_clk_i: in std_ulogic;
    Q: out std_ulogic;
    n_Q: out std_ulogic
  );
  end component;
  component SR_FF is
  port( 
    D: in std_ulogic;
    S: in std_ulogic;
    R: in std_ulogic;
    n_clk_i: in std_ulogic;
    Q: out std_ulogic;
    n_Q: out std_ulogic
  );
  end component;
  component delay is
  generic(CYCLES : natural := 8;
          WIDTH  : positive := 16);
  port(clk    : in  std_ulogic;
       rst    : in  std_ulogic;
       en     : in  std_ulogic;
       input  : in  std_ulogic_vector(WIDTH-1 downto 0);
       output : out std_ulogic_vector(WIDTH-1 downto 0));
  end component;
  component static_clk_divider is
     generic (
        -- frequency divisor, <o_clk_freq>=<i_clk_freq>/g_FREQ_DIV
        g_FREQ_DIV : integer range 2 to integer'high := 5
     );
     port (
        n_clk_i : in  std_ulogic; -- input clock signal
        i_rst : in  std_ulogic; -- reset signal
        o_clk : out std_ulogic -- final output clock
     );
  end component;
  component clk_divider is
  generic (
      g_FREQ_DIV_MAX : integer := 10; --  maximum available frequency divisor value
      BIT_WIDTH : integer       := integer(ceil(log2(real(g_FREQ_DIV_MAX  + 1))))
  ) ;
  port (
      i_clk : in std_ulogic; -- input clock signal
      i_rst : in std_ulogic; -- reset signal
      -- i_clk frequency is divided by value of this number, <o_clk_freq>=<i_clk_freq>/i_freq_div
      i_freq_div : in  positive range 1 to g_FREQ_DIV_MAX;
      o_counter    : out std_ulogic_vector(BIT_WIDTH -1 downto 0);
      o_clk      : out std_ulogic -- final output clock
  );
  end component;
  component onetoN_divider is
  generic (
      N           : integer
  );
  port (
      rst_i         : in std_ulogic;
      clk_i       : in std_ulogic;
      modulus_sel : in std_ulogic;
      clk_o       : out std_ulogic
  );
  end component;
  component counter10b_ripple is
   generic (
       COUNTBITS: positive; -- maximum available frequency divisor value
       g_MAX_COUNT: positive
   );
   port (
       i_clk : in std_ulogic; -- input clock signal
       i_rst : in std_ulogic; -- reset signal
       o_counter    : out std_ulogic_vector(COUNTBITS - 1 downto 0)
   );
  end component;
  component counter10b_fast is
   generic (
       COUNTBITS: positive; -- maximum available frequency divisor value
       g_MAX_COUNT: positive
   );
   port (
       i_clk : in std_ulogic; -- input clock signal
       i_rst : in std_ulogic; -- reset signal
       o_counter    : out std_ulogic_vector(COUNTBITS - 1 downto 0)
   );
  end component;
  component dot_counter is
    port (
       dot_clk_s : in  std_ulogic; -- input clock signal
       dot_clk : in  std_ulogic; -- input clock signal
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
       clk_extra: in std_ulogic;
       mode80: in std_ulogic;
       i_rst : in  std_ulogic; -- reset signal
       clock_2hf: out std_ulogic; 
       clock_hf: out std_ulogic; 
       div_out : out std_ulogic_vector(0 to 8);
       LBA : out std_ulogic_vector(7 downto 0)
  );
  end component;
  component ver_counter is
  port (
       clock_2hf: in  std_ulogic; -- input clock signal
       clock_h5: in  std_ulogic; -- input clock signal
       hcdiv_in : in std_ulogic_vector(0 to 8);
       i_rst : in  std_ulogic; -- reset signal
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
       div_in : in std_ulogic_vector(8 downto 0);
       mode80 : in  std_ulogic; 
       addr_cnt_on : out  std_ulogic;
       n_hdrive: out  std_ulogic;
       hblank : out  std_ulogic
  );
  end component;
  component sram is
  GENERIC(
   DATAWIDTH : positive := 10
  );
  port (
      addr_i : in std_logic_vector (DATAWIDTH - 1  downto 0);
      clk   : in std_logic  := '1';
      data_i   : in std_logic_vector (7 downto 0);
      wren_i   : in std_logic ;
      data_o   : out std_logic_vector (7 downto 0)
	);
  end component;
  component bootrom is
  GENERIC(
   DATAWIDTH : positive := 13
  );
  port (
      addr_i : in std_logic_vector (DATAWIDTH - 1  downto 0);
      clk   : in std_logic  := '1';
      data_o   : out std_logic_vector (7 downto 0)
	);
  end component;
  component vtiming is
  port (
       i_clk: in  std_ulogic;
       i_rst: in  std_ulogic; 
       n_vrst: in  std_ulogic; 
       clk_2hf: in  std_ulogic; 
       vcdiv_in : in std_ulogic_vector(0 to 9);
       hertz60: in  std_ulogic; 
       interlaced: in  std_ulogic; 
       vdrive: out  std_ulogic;
       n_vblank : out  std_ulogic;
       vrst : out  std_ulogic
  );
  end component;
  component er1400 is
   port (
      data_i	: in std_logic;
      clk	: in std_logic  := '1';
      c_i     : in std_logic_vector (2 downto 0)
   );
  end component;
  component dc011
    port(
     clk24:    in  std_ulogic;
     n_rst:  in  std_ulogic;
     d0:  in  std_ulogic;
     d1:  in  std_ulogic;
     n_vid_wr:  in  std_ulogic;
     dw:  in  std_ulogic;
     hold_req:  in  std_ulogic;
     LBA:   out std_ulogic_vector (7 downto 0);
     dot_clock:   out std_ulogic;
     char_clk:   out std_ulogic;
     n_write_lb:   out std_ulogic;
     vsr_ld:   out std_ulogic;
     n_addr_ld: out std_ulogic;
     n_hdrive: out  std_ulogic;
     hblank : out  std_ulogic;
     vrst : out  std_ulogic;
     vdrive: out  std_ulogic;
     n_vblank : out  std_ulogic;
     comp_sync: out  std_ulogic;
     addr_count: out  std_ulogic
    );
  end component;
  component dc012 is
    port (
     dot_clock: in std_ulogic;
     n_rst:  in  std_ulogic;
     data:  in  std_ulogic_vector(3 downto 0);
     n_vid_w2:  in  std_ulogic;
     vrst:  in  std_ulogic;
     vf_intr:   out std_ulogic;
     revvid:  in  std_ulogic;
     d_h:   in std_ulogic;
     d_l:   in std_ulogic;
     n_addr_ld:   in std_ulogic;
     hold_req:   out std_ulogic;
     vsr_ld:   out std_ulogic;
     char_clk:   in std_ulogic;
     hblank:   in std_ulogic;
     scan_cnt:  out  std_ulogic_vector(3 downto 0);
     vid1out:   out std_ulogic;
     vid2out:   out std_ulogic;
     term: in  std_ulogic;
     n_underline: in  std_ulogic;
     n_blink: in  std_ulogic;
     n_bold: in  std_ulogic;
     vid_in: in std_ulogic
    );
  end component;
  component vt100 is
    port(clk24_i: in std_logic;
     clk100_i: in std_logic;
     reset_i: in std_logic;
     TXD0: out std_logic;
     RXD0: in std_logic;
     videoR: out  std_logic_vector(3 downto 0);
     videoG: out  std_logic_vector(3 downto 0);
     videoB: out  std_logic_vector(3 downto 0);
     hSync: out  std_logic;
     vSync: out  std_logic;
     LED: out  std_logic_vector(7 downto 0)
    );
  end component;

end package dc0112_pkg;
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity D_FF is
    port( 
      D: in std_ulogic;
      n_clk_i: in std_ulogic;
      Q: out std_ulogic
    );
end entity D_FF;
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity JK_FF is
    port( 
      J: in std_ulogic;
      K: in std_ulogic;
      S: in std_ulogic;
      R: in std_ulogic;
      n_clk_i: in std_ulogic;
      Q: out std_ulogic;
      n_Q: out std_ulogic
    );
end entity JK_FF;
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity SR_FF is
    port( 
      D: in std_ulogic;
      S: in std_ulogic;
      R: in std_ulogic;
      n_clk_i: in std_ulogic;
      Q: out std_ulogic;
      n_Q: out std_ulogic
    );
end entity SR_FF;
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
entity onetoN_divider is
    generic (
        N           : integer; -- Base divide
        BIT_WIDTH : integer := integer(ceil(log2(real(N + 1))))
    );
    port (
        rst_i         : in std_ulogic;
        clk_i       : in std_ulogic;
        modulus_sel : in std_ulogic; -- 1 divide by N.5
        clk_o       : out std_ulogic
    );
end onetoN_divider;
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
entity clk_divider is
    generic (
        g_FREQ_DIV_MAX : integer := 10; -- maximum available frequency divisor value
        BIT_WIDTH : integer := integer(ceil(log2(real(g_FREQ_DIV_MAX + 1))))
    );
    port (
        i_clk : in std_ulogic; -- input clock signal
        i_rst : in std_ulogic; -- reset signal
        
        -- i_clk frequency is divided by value of this number, <o_clk_freq>=<i_clk_freq>/i_freq_div
        --i_freq_div : in  integer range 1 to g_FREQ_DIV_MAX;
        i_freq_div : positive  range 1 to g_FREQ_DIV_MAX;
        o_counter    : out std_ulogic_vector(BIT_WIDTH - 1 downto 0);
        o_clk      : out std_ulogic -- final output clock;
    );
end entity clk_divider;

------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity reg is
    generic(WIDTH : positive);
    port(clk    : in  std_ulogic;
         rst    : in  std_ulogic;
         en     : in  std_ulogic;
         input  : in  std_ulogic_vector(WIDTH-1 downto 0);
         output : out std_ulogic_vector(WIDTH-1 downto 0));
end reg;

------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity delay is
    generic(CYCLES : natural := 8;
            WIDTH  : positive := 16);
    port(clk    : in  std_ulogic;
         rst    : in  std_ulogic;
         en     : in  std_ulogic;
         input  : in  std_ulogic_vector(WIDTH-1 downto 0);
         output : out std_ulogic_vector(WIDTH-1 downto 0));
end delay;

------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity dot_counter is
    port (
        dot_clk_s : in  std_ulogic; -- input clock signal
        dot_clk : in  std_ulogic; -- input clock signal
        mode80: in std_ulogic;
        i_rst : in  std_ulogic; -- reset signal
       
        char_clk : out std_ulogic;
        write_lb : out std_ulogic;
        clk80_half: out std_ulogic;
        dot_div : out std_ulogic_vector(0 to 3)
    );
end entity dot_counter;
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity dc011 is
port (
  clk24:    in  std_ulogic;
  n_rst:  in  std_ulogic;
  d0:  in  std_ulogic;
  d1:  in  std_ulogic;
  n_vid_wr:  in  std_ulogic;
  dw:  in  std_ulogic;
  hold_req:  in  std_ulogic;
  LBA:   out std_ulogic_vector (7 downto 0);
  dot_clock:   out std_ulogic;
  char_clk:   out std_ulogic;
  n_write_lb:   out std_ulogic;
  vsr_ld:   out std_ulogic;
  n_addr_ld:   out std_ulogic;
  n_hdrive: out  std_ulogic;
  hblank : out  std_ulogic;
  vrst : out  std_ulogic;
  vdrive: out  std_ulogic;
  n_vblank : out  std_ulogic;
  comp_sync : out  std_ulogic;
  addr_count: out  std_ulogic
);
end entity;
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity vtiming is
    port (
        i_clk: in  std_ulogic;
        i_rst: in  std_ulogic; 
        n_vrst: in  std_ulogic; 
        clk_2hf: in  std_ulogic; 
        vcdiv_in: in std_ulogic_vector(9 downto 0);
        hertz60: in  std_ulogic; 
        interlaced: in  std_ulogic; 
        vdrive: out  std_ulogic;
        n_vblank : out  std_ulogic;
        vrst : out  std_ulogic
    );
end entity vtiming;
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity static_clk_divider is
    generic (
        -- frequency divisor, <o_clk_freq>=<i_clk_freq>/g_FREQ_DIV
        g_FREQ_DIV : integer range 2 to integer'high := 5
    );
    port (
        n_clk_i : in  std_ulogic; -- input clock signal
        i_rst : in  std_ulogic; -- reset signal
        o_clk : out std_ulogic -- final output clock
    );
end entity static_clk_divider;
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity vt100 is
	port(clk24_i: in std_logic;
	     clk100_i: in std_logic;
	     reset_i: in std_logic;
	     TXD0: out std_logic;
	     RXD0: in std_logic;
	     videoR: out  std_logic_vector(3 downto 0);
	     videoG: out  std_logic_vector(3 downto 0);
	     videoB: out  std_logic_vector(3 downto 0);
	     hSync: out  std_logic;
	     vSync: out  std_logic;
	     LED: out  std_logic_vector(7 downto 0)
     );
end entity;

------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
package body dc0112_pkg is

------------------------------------------------------------------------
  --function getMatSize (dim: integer) return integer is
  --begin report "VHPIDIRECT getMatSize" severity failure; end;

  --impure function getMatPointer return matrix_acc_t is
  --begin report "VHPIDIRECT getMatPointer" severity failure; end;

  function test_equal(a: in std_ulogic_vector;b: in std_ulogic_vector)
  return boolean is
    variable result: boolean := false;
    variable tmp_result: std_ulogic := '0';
    alias aa: std_ulogic_vector(a'REVERSE_RANGE) is a;
  begin
    for i in a'RANGE loop
      tmp_result := tmp_result and (a(i) xor b(i));
    end loop;
    if tmp_result = '1' then
       result := true;
    end if;
  return result;
  end; -- convert string to list of gates

  function reverse_vector (a: in std_ulogic_vector)
  return std_ulogic_vector is
    variable result: std_ulogic_vector(a'RANGE);
    alias aa: std_ulogic_vector(a'REVERSE_RANGE) is a;
  begin
    for i in aa'RANGE loop
      result(i) := aa(i);
    end loop;
    return result;
  end; -- function reverse_any_vector
end package body dc0112_pkg;
