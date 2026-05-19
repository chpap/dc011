library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dc0112_pkg.all;

entity BV2 is

   port( clk_i : in std_ulogic;
      clk24_i    : in  std_ulogic;
      DO_0_i     : in std_ulogic_vector(7 downto 0);
      DB_0_o     : out std_ulogic_vector(7 downto 0);
      LBA_i     : in std_ulogic_vector(7 downto 0);
      A0_H_i : in std_ulogic_vector(15 downto 0);
      BV6_RESET_L_i  : in std_ulogic;
      BV6_IO_RD_L_i : in std_ulogic;
      BV6_IO_WR_L_i : in std_ulogic;
      BV6_MEM_WR_L_i: in std_ulogic;
      BV6_MEM_RD_L_i: in std_ulogic;
      BV1_MEM_DISABLE_L_i: in std_ulogic;
      BV2_n_SPDS_o  : out  std_ulogic;
      BV2_NVR_DATA_H_o: out  std_ulogic;
      BV2_KBD_RD_L_o: out std_ulogic;
      BV2_KBD_WR_L_o: out std_ulogic;
      BV2_FLAG_RD_L_o: out std_ulogic;
      BV2_MODEM_RD_L_o: out std_ulogic;
      BV2_GRAPHIC_WR_L_o: out std_ulogic;
      BV2_VID_WR_1L_o: out std_ulogic;
      BV2_VID_WR_2L_o: out std_ulogic;
      BV2_DA_WR_L_o: out std_ulogic;
      BV2_WRITE_BAUD_H_o: out std_ulogic;
      BV2_SEL_8_12K_L_o: out std_ulogic;
      BV2_SEL_ATT_RAM_L_o: out std_ulogic);


end BV2;
architecture rtl of BV2 is
	signal iomux_in: std_ulogic_vector(3 downto 0);
	signal iomux_out: std_ulogic_vector(7 downto 0);
	signal nvr_latch: std_ulogic_vector(5 downto 0);
	signal n_mem_dec_en: std_ulogic;
	signal rom_select: std_ulogic;
	signal memmux_out: std_ulogic_vector(7 downto 0);
	signal memmux_in: std_ulogic_vector(5 downto 0);
	type D_mem_t is array (0 to 2) of std_ulogic_vector(7 downto 0);
	signal D_mem_o: D_mem_t;
	signal D_ROM: std_ulogic_vector(7 downto 0);
        signal BV2_NVR_WR_L: std_ulogic;
begin
-----  IO MEMORY DECODER -----
  iomux_in <= A0_H_i(7) & A0_H_i(6) & A0_H_i(5) & ((not A0_H_i(1)) or BV6_IO_WR_L_i) ; 
  with iomux_in select iomux_out <=
    "01111111" when "0000",
    "10111111" when "0010",
    "11011111" when "0100",
    "11101111" when "0110",
    "11110111" when "1000",
    "11111011" when "1010",
    "11111101" when "1100",
    "11111110" when "1110",
    "11111111" when others;
  BV2_GRAPHIC_WR_L_o <= iomux_out(7);
  BV2_VID_WR_1L_o <= iomux_out(6);
  BV2_VID_WR_2L_o <= iomux_out(5);
  BV2_KBD_WR_L_o <= iomux_out(4);
  BV2_NVR_WR_L <= iomux_out(3);
  BV2_DA_WR_L_o <= iomux_out(2);
  BV2_WRITE_BAUD_H_o <= not iomux_out(0);
-------------------------- 
----NVR LATCH ------------

  nvr_latch_proc: process (BV2_NVR_WR_L,BV6_RESET_L_i) is
    variable nvr_latch_next: std_ulogic_vector(5 downto 0) := (others => '0');
    begin
      if rising_edge(BV2_NVR_WR_L) then 
         if BV6_RESET_L_i = '1' then
             nvr_latch_next := DO_0_i(5 downto 0);
          else
             nvr_latch_next := (others => '0');
          end if;
      end if;
      if BV6_RESET_L_i = '0' then
             nvr_latch_next := (others => '0');
      end if;
      nvr_latch <= nvr_latch_next;
    end process nvr_latch_proc; 
  BV2_n_SPDS_o <= nvr_latch(5);

  -- BV2_NVR_DATA_H_o <= nvr_latch (0);
  ER1400_INST: er1400 port map(
       data_i => nvr_latch(0),
       data_o => BV2_NVR_DATA_H_o,
       clk_i => not LBA_i(7),
       c_i => nvr_latch(3 downto 1)
  );

-------------------------
  BV2_KBD_RD_L_o <= (not BV6_IO_RD_L_i) and A0_H_i(7);
  BV2_FLAG_RD_L_o <= (not BV6_IO_RD_L_i) and A0_H_i(6);
  BV2_MODEM_RD_L_o <= (not BV6_IO_RD_L_i) and A0_H_i(5);

-----  MEMORY DECODER -----
  n_mem_dec_en <= (BV6_MEM_RD_L_i and BV6_MEM_WR_L_i) or not BV1_MEM_DISABLE_L_i;

  memmux_in(5 downto 3) <= A0_H_i(13) & A0_H_i(12) & n_mem_dec_en;
  with memmux_in(5 downto 3) select memmux_out(7 downto 4) <=
    "1110" when "000",
    "1101" when "010",
    "1011" when "100",
    "0111" when "110",
    "1111" when others;

  memmux_in(2 downto 0) <= A0_H_i(11) & A0_H_i(10) & memmux_out(6);
  with memmux_in(2 downto 0) select memmux_out(3 downto 0) <=
    "1110" when "000",
    "1101" when "010",
    "1011" when "100",
    "0111" when "110",
    "1111" when others;

  BV2_SEL_8_12K_L_o <= memmux_out(6);
  BV2_SEL_ATT_RAM_L_o <= memmux_out(7);
  rom_select <= not (memmux_out(5) and memmux_out(4));

-------------------------
SRAM_INSTS: for i in 0 to 2 generate
  SRAM_INST: sram port map (
      addr_i => A0_H_i(9 downto 0),
      clk => clk24_i,
      data_i => DO_0_i,
      wren_i => BV6_MEM_WR_L_i,
      data_o => D_mem_o(i)
);
end generate;
ROM_INST: bootrom port map (
      addr_i => A0_H_i(12 downto 0),
      clk => clk24_i,
      data_o => D_ROM
);
-- rom_select  memmux_out(0-2)
DB_0_o <= D_ROM when rom_select = '1' else
          D_mem_o(0) when memmux_out(0) = '1' else
          D_mem_o(1) when memmux_out(1) = '1' else
          D_mem_o(2) when memmux_out(2) = '1' else
	  (others => '1');

end rtl;
