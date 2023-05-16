-- Authors:
-- Lab Group 11:
-- Sahaj Singh Student#: 301437700
-- Bryce Leung Student#: 301421630 
-- Sukha Lee 	Student#: 301380632

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3_Task3 is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
end lab3_Task3;

architecture rtl of lab3_Task3 is

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
  
  -- State machine signal
  type stateMachine_types is (s0, s1, s2);
  signal CurState : stateMachine_types := s0;
  
  -- Gray function
	function Gray(input: integer) return std_logic_vector is
		begin
		case input is
			when 0 => return "000";
			when 1 => return "001";
			when 2 => return "011";
			when 3 => return "010";
			when 4 => return "110";
			when 5 => return "111";
			when 6 => return "101";
			when 7 => return "100";
			when others => return "000";
		end case;
	end function;
  
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
	process(CLOCK_50, KEY(3), CurState)
		variable e2, err : integer := 0;
		variable sx, sy : integer range -1 to 1 := 0;
		variable dx, dy, x0, y0, x1, y1 : integer range -160 to 160 := 0;
		variable iteration : integer range 0 to 14 := 1;
   begin
		-- linking the Bresenham Line Argorithm outputs to the x and y inputs 
		x<=std_logic_vector(to_unsigned(x0,x'length));
		y<=std_logic_vector(to_unsigned(y0,y'length));
		if(KEY(3) = '0') then
			-- Resetting variable registers to 0 and moving back to the screen clearing state
			dx := 0;
			dy := 0;				
			sx := 0;
			sy := 0;
			x0 := 0;
			y0 := 0;
			x1 := 0;
			y1 := 0;
			e2 := 0;
			err := 0;
			iteration := 1;
			CurState <= s0;
		elsif rising_edge(CLOCK_50) then
			case curState is
				when s0 => -- Clearing screen state operation
					plot <= '1'; -- start VGA plotting
					colour <=  std_logic_vector(to_unsigned(0, 3));
					if y0 = 119 then
						x0 := x0 + 1; -- increment x counter
						y0 := 0;
					else
						y0 := y0 + 1; -- increment y counter
					end if;
					if x0 > 159 then
						CurState <= s1;
					end if;
				when s1 => -- Calculating for the iteration of Bresenham Line Argorithm opertation
					plot <= '0'; -- stop VGA plotting
					if(iteration < 14) then
						colour <= Gray((iteration mod 8));
						x0 := 0;
						x1 := 159;
						y0 := iteration * 8;
						y1 := 120 - iteration * 8;
						dx := abs(x1-x0);
						dy := abs(y1-y0);
						iteration := iteration + 1;
						if(x0 < x1) then
							sx := 1;
						else
							sx := -1;
						end if;
						if(y0 < y1) then
							sy := 1;
						else
							sy := -1;
						end if;
						err := dx - dy;
						CurState <= s2;
					end if;
				when s2 => -- Drawing to screen state operation
					plot <= '1'; -- start VGA plotting
					if((x0 = x1) and (y0 = y1)) then
						CurState <= s1;
					else
						e2 := 2 * err;
						if(e2 > -dy) then
							err := err - dy;
							x0 := x0 +sx;
						end if;
						if(e2 < dx) then
							err := err + dx;
							y0 := y0 + sy;
						end if;
					end if;
			end case;
		end if;
   end process;
	 
end RTL;