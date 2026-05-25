library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
entity fb is
  generic (
    WIDTH  : natural := 1024;
    HEIGHT : natural := 768;
    VIS_WIDTH  : natural := 800;
    VIS_HEIGHT : natural := 600
  );
  port(
    pixel_clock_i : in std_ulogic;
    rgb_i :in std_ulogic_vector(11 downto 0);
    hsync_i: in std_ulogic;
    vsync_i: in std_ulogic;
    debug: out std_ulogic_vector(31 downto 0)
      );
  package fb_pkg is new work.x11_pkg
    generic map (
      G_WIDTH  => WIDTH,
      G_HEIGHT => HEIGHT
    );
  use fb_pkg.all;
end fb;

architecture behavioural of fb is
  constant c_width  : integer := screen'length(2);
  constant c_height : integer := screen'length(1);
  signal counter : integer range 0 to WIDTH * HEIGHT := 0;
  signal x : integer range 0 to WIDTH-1 := 0;
  signal y : integer range 0 to HEIGHT-1 := 0;
  signal rgb24 : std_logic_vector(23 downto 0);
  signal pcounter : integer range 0 to 10000000:=0;
  signal maxx,maxy :integer range 0 to 1000000 := 0;
begin
  process(pixel_clock_i,hsync_i,vsync_i)
  begin
    if rising_edge(pixel_clock_i) then
       screen(y,x) := conv_integer(rgb24);
       if(hsync_i = '1' or vsync_i = '1') then
         x <= (x + 1) mod VIS_WIDTH;
         if (x = 0) then 
             y <= (y + 1) mod VIS_HEIGHT;
	     if ( x > maxx) then
		     maxx <= x;
	     end if;
	     if ( y > maxy) then
		     maxy <= y;
	     end if;
         end if;   
	 

	 if (pcounter > 1000000) then
pcounter <= 0;
    report "max size: " & to_string(c_width) & "x" & to_string(c_height) severity note;
    else
	    pcounter <= pcounter + 1;
    end if;
    end if;   
   rgb24 <= (
      23 downto 16 => std_logic_vector(rgb_i(11 downto 8) & "0000"),
      15 downto 8  => std_logic_vector(rgb_i(7 downto 4) & "0000"),
      7  downto 0  => std_logic_vector(rgb_i(3 downto 0) & "0000"),
         others    => '0'
    );
   end if;
  end process;

  process
    variable h, i, j, d_x, d_y: integer;
  begin
    sim_init(WIDTH, HEIGHT); -- X11 window size
    report "screen size: " & to_string(c_width) & "x" & to_string(c_height) severity note;
    report "pattern: test" severity note;

    for h in 0 to 1000 loop
    report "frame " & integer'image(h) severity note;
    -- wait until counter = 0;
    --wait for 100000 ns;
    wait for 10 ms;
      save_screenshot(
        screen,
        c_width,
        c_height,
        h
      );
    end loop;
    wait;

    sim_cleanup;
--    wait;
  end process;
end architecture;
