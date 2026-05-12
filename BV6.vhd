library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BV6 is
   port( clk_i : in std_ulogic;
      clk24_i    : in  std_ulogic;
      n_reset_i : in std_ulogic;
      A0_H_o     : out std_ulogic_vector(15 downto 0);
      DB_0_i     : in std_ulogic_vector(7 downto 0);
      DO_0_o  : out std_ulogic_vector(7 downto 0);
      BV6_HLDA_H_o  : out std_ulogic;
      BV6_RESET_H_o : out std_ulogic;
      BV6_INTR_H_i : in std_ulogic;
      BV4_T_HOLD_REQ_H_i : in std_ulogic;
      BV6_INTA_L_o: out std_ulogic;
      BV6_IO_WR_L_o: out std_ulogic;
      BV6_IO_RD_L_o: out std_ulogic;
      BV6_MEM_WR_L_o: out std_ulogic;
      BV6_MEM_RD_L_o: out std_ulogic;
      inte_o  : out std_ulogic;
      dbin_o  : out std_ulogic;
      n_wr_o  : out std_ulogic);
end BV6;

architecture rtl of BV6 is
   signal BV6_RESET_H : std_ulogic;
   signal BV6_INTR_H : std_ulogic;
   signal ready : std_ulogic := '1';
   signal wait80 : std_ulogic;
   signal n_stsb : std_ulogic;

   component i8xxx is
   port( clk_i : in std_logic;
      clk24_i    : in  std_logic;
      n_reset_i : in std_logic;
      a_o     : out std_logic_vector(15 downto 0);
      d_i     : in std_logic_vector(7 downto 0);
      d_o     : out std_logic_vector(7 downto 0);
      hold_i  : in  std_logic;
      hlda_o  : out std_logic;
      ready_i : in  std_logic;
      wait_o  : out std_logic;
      int_i   : in  std_logic;
      inte_o  : out std_logic;
      dbin_o  : out std_logic;
      n_wr_o  : out std_logic;
      reset_o : out std_logic;
      n_stsb_o: out std_logic;
      n_memr_o: out std_logic;
      n_memw_o: out std_logic;
      n_ior_o : out std_logic;
      n_iow_o : out std_logic;
      n_inta_o: out std_logic);
   end component;

begin
   i8xxx_inst: i8xxx port map( clk_i => clk_i,
   clk24_i => clk24_i,
   n_reset_i => n_reset_i,
   a_o => A0_H_o,
   d_i => DB_0_i,
   d_o => DO_0_o,
   hold_i => BV4_T_HOLD_REQ_H_i,
   hlda_o => BV6_HLDA_H_o,
   ready_i => ready,
   wait_o => wait80,
   int_i => BV6_INTR_H,
   inte_o => inte_o, 
   dbin_o => dbin_o,
   n_wr_o => n_wr_o,
   reset_o => BV6_RESET_H,
   n_stsb_o => n_stsb);

   BV6_RESET_H_o <= BV6_RESET_H;
   BV6_INTR_H <= BV6_INTR_H_i;

end rtl;
