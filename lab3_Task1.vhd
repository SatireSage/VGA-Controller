-- Authors:
-- Lab Group 11:
-- Sahaj Singh Student#: 301437700
-- Bryce Leung Student#: 301421630 
-- Sukha Lee 	Student#: 301380632

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3_Task2 is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
end lab3_Task2;

architecture rtl of lab3_Task2 is

 --Component from the Verilog file: vga_adapter.v

  component vga_adapter
    generic(RESOLUTION : string);
    port (resetn                                       : in  std_logic;
          clock                                        : in  std_logic;
          colour                                       : in  std_logic_vector(2 downto 0);
          x                                            : in  std_logic_vector(7 downto 0);
          y                                            : in  std_logic_vector(6 downto 0);
          plot                                         : in  std_logic;
          VGA_R, VGA_G, VGA_B                          : out std_logic_vector(9 downto 0);
          VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic);
  end component;

  signal x      : std_logic_vector(7 downto 0);
  signal y      : std_logic_vector(6 downto 0);
  signal colour : std_logic_vector(2 downto 0);
  signal plot   : std_logic;
  
begin
 
  -- includes the vga adapter, which should be in your project 
  vga_u0 : vga_adapter
    generic map(RESOLUTION => "160x120") 
    port map(resetn    => KEY(3),
             clock     => CLOCK_50,
             colour    => colour,
             x         => x,
             y         => y,
             plot      => plot,
             VGA_R     => VGA_R,
             VGA_G     => VGA_G,
             VGA_B     => VGA_B,
             VGA_HS    => VGA_HS,
             VGA_VS    => VGA_VS,
             VGA_BLANK => VGA_BLANK,
             VGA_SYNC  => VGA_SYNC,
             VGA_CLK   => VGA_CLK);
				 
  -- rest of your code goes here, as well as possibly additional files
	process (CLOCK_50, KEY(3))
			variable x_counter : integer range 0 to 160 := 0;
			variable y_counter : integer range 0 to 120 := 0;
	begin
		x <= std_logic_vector(to_unsigned(x_counter, 8)); -- set x-coordinate
		y <= std_logic_vector(to_unsigned(y_counter, 7)); -- set y-coordinate
		colour <= std_logic_vector(to_unsigned((x_counter mod 8), 3)); -- set colour value
		if KEY(3) = '0' then
			x_counter := 0;
			y_counter := 0;
		elsif rising_edge(CLOCK_50) then
			if x_counter <= 159 then
				plot <= '1'; -- start VGA plotting
			else
				plot <= '0'; -- stop VGA plotting
			end if;
			if y_counter = 119 then
				x_counter := x_counter + 1; -- increment x counter
				y_counter := 0;
			else
				y_counter := y_counter + 1; -- increment y counter
			end if;
		end if;
	end process;
	
end RTL;