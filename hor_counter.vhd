library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.dc0112_pkg.all;


entity hor_counter is
    port (
        char_clk_i : in  std_ulogic; -- input clock signal
        mode80_i: in std_ulogic;
        rst_i : in  std_ulogic; -- reset signal
        clk_delay_i: in  std_ulogic;
        clock_2hf_o: out std_ulogic;
        clock_hf_o: out std_ulogic;
        div_o : out std_ulogic_vector(8 downto 0);
        LBA_o : out std_ulogic_vector(7 downto 0)
    );
end entity hor_counter;


architecture rtl of hor_counter is
    signal div1: std_ulogic_vector(2 downto 0) := (others => '0');
    signal div2: std_ulogic_vector(4 downto 0) := (others => '0');
    signal div3: std_ulogic_vector(1 downto 0) := (others => '0');
    signal div1_out: std_ulogic := '0';
    signal div2_out: std_ulogic := '0';
    signal div3_out: std_ulogic := '0';
begin
    
    div1_proc: process(char_clk_i)
    begin
      if(rising_edge(char_clk_i)) then
        --if(div2_tmp = std_ulogic_vector(to_unsigned(17-1,4))) then
        if (mode80_i = '1' and div1(1) = '1') or (mode80_i = '0' and div1(2) = '1') then -- when div1 gets to 3 or 5
           div1 <= (others => '0');
           div1_out <= '1';
        else
           div1 <= div1 + 1;
	   div1_out <= '0';
        end if;
      end if;
    end process;

    div2_proc: process(div1_out)
    begin
      if(rising_edge(div1_out)) then
        --if(div2 = std_ulogic_vector(to_unsigned(17-1,4))) then
        if(div2(4) = '1') then -- when div2 gets to 16
           div2 <= (others => '0');
           div2_out <= '1';
        else
           div2 <= div2 + 1;
	   div2_out <= '0';
        end if;
      end if;
    end process;

    div3_proc: process(div2_out)
    begin
      if(rising_edge(div2_out)) then
        if(div3(0) = '1') then -- when div3 gets to 2
           div3 <= (others => '0');
           div3_out <= '1';
        else
           div3 <= div3 + 1;
	   div3_out <= '0';
        end if;
      end if;
    end process;

    delay_inst: delay
    generic map(CYCLES => 4,
            WIDTH => 9)
    port map(clk => clk_delay_i,
         rst => rst_i,
         en  => '1',
         --input => ""&char_clk_tmp, 
         input => div3(0) & div2 & div1,
         output => div_o
    );
   
    clock_2hf_o <= div2_out;
    clock_hf_o <= div3_out;
    LBA_o(7) <= div_o(8) xor div_o(7);
    LBA_o(6) <= div_o(6);
    LBA_o(5) <= div_o(5) or (div_o(7) and div_o(1));
    LBA_o(4) <= not div_o(4);
    LBA_o(3) <= div_o(3);
    LBA_o(2) <= div_o(7);
    LBA_o(1) <= (div_o(0) nor div_o(1)) or (div_o(7) and div_o(1));
    LBA_o(0) <= div_o(0) or (div_o(7) and div_o(1)); 
    
end architecture rtl;
