-- Authors:
-- Lab Group 11:
-- Sahaj Singh Student#: 301437700
-- Bryce Leung Student#: 301421630 
-- Sukha Lee 	Student#: 301380632

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3_Challenge is
  port(CLOCK_50            : in  std_logic;
       LEDR                : out std_logic_vector(7 downto 0);
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
end lab3_Challenge;

architecture rtl of lab3_Challenge is

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
  type stateMachine_types is (s0, s1, s2, s3);
  signal CurState : stateMachine_types := s0;
  
  -- Gray function
  function Gray(moddedVal : in integer range 0 to 7)
		return std_logic_vector is
			variable grayCode : std_logic_vector(2 downto 0);
		begin
			-- Outputs the specified gray code bsaed on the input value
			case moddedVal is 
				when 0 => grayCode := "000";
				when 1 => grayCode := "001";
				when 2 => grayCode := "011";
				when 3 => grayCode := "010";
				when 4 => grayCode := "110";
				when 5 => grayCode := "111";
				when 6 => grayCode := "101";
				when 7 => grayCode := "100";
			end case;
		return grayCode;
  end function Gray;
  
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
	LEDR <= SW(7 DOWNTO 0);
	process(CurState, CLOCK_50, KEY, SW)
		variable e2, err : integer := 0;
		variable sx, sy : integer range -1 to 1 := 0;
		variable done_drawings, side_Switch: std_logic := '0';
		variable calc_Iteration : integer range 0 to 3 := 0;
		variable wait_counter : integer range 0 to 49999999 := 0;
      variable base_register : std_logic_vector(7 downto 0) := "00000000";
		variable base_length : integer range 0 to 80 := 0;
		variable dx, dy, x0, y0, x1, y1, y0_origin, y1_origin, x0_origin, x1_origin : integer range -160 to 160 := 0;
		variable iteration : integer range 0 to 15 := 0;
	begin
		-- linking the Bresenham Line Argorithm outputs to the x and y inputs 
		x<=std_logic_vector(to_unsigned(x0,x'length));
		y<=std_logic_vector(to_unsigned(y0,y'length));
		if(KEY(3) = '0') then
			side_Switch := '0';
			base_register := (others => '0');
			base_length := 0;
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
			iteration := 0;
			CurState <= s0;
		elsif rising_edge(CLOCK_50) then
			if KEY(0) = '0' then
				base_register := SW(7 DOWNTO 0);
			end if;
			case curState is
				when s0 => -- screen clearing state
					plot <= '1';
					colour <=  std_logic_vector(to_unsigned(0, 3));
					if y0 = 119 then
						x0 := x0 + 1; -- increment x counter
						y0 := 0;
					else
						y0 := y0 + 1; -- increment y counter
					end if;
					if x0 > 159 then
						base_length := 0;
						for i in base_register'range loop
							 if base_register(i) = '1' then
								  base_length := base_length + 9;
							 end if;
						end loop;
						calc_Iteration := 1;
						CurState <= s1;
					end if;
				when s1 => -- calculate iteration state
					plot <= '0';
					if(iteration < 14) then
						colour <= Gray(iteration mod 8);
						x0 := 0;
						x1 := 159;
						y0 := iteration * 8;
						y1 := 120 - iteration * 8;

						if calc_Iteration = 1 then
							 y0_origin := y0;
							 y1_origin := y1;
						elsif calc_Iteration = 2 then
							 if side_Switch = '0' then
								  x1 := 79;
								  if base_length > 0 then
										x0 := x1 - base_length;
								  end if;
							 else
								  x0 := 80;
								  if base_length > 0 then
										x1 := x0 + base_length;
								  end if;
							 end if;
							 x0_origin := x0;
							 x1_origin := x1;
							 y0 := 60;
							 y1 := 60;
						elsif calc_Iteration = 3 then
							 if side_Switch = '0' then
								  x0 := x0_origin;
								  x1 := x0_origin;
								  if (y0_origin - 59) < 0 then
										y0 := 60 - (60 - y0_origin) - 1;
										y1 := 60;
								  else
										y0 := 59;
										y1 := y0_origin;
								  end if;
							 else
								  x0 := x1_origin;
								  x1 := x1_origin;
								  if (y1_origin - 59) < 0 then
										y0 := 59 + (y1_origin - 59) - 1;
										y1 := 59;
								  else
										y0 := 59;
										y1 := y1_origin;
								  end if;
							 end if;
							 done_drawings := '1';
						end if;
						dx := abs(x1-x0);
						dy := abs(y1-y0);
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
					else
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
						iteration := 0;
						CurState <= s0;
					end if;
				when s2 => -- drawing iteration state
					plot <= '1';
					
					if base_length > 0 then 
						if calc_Iteration = 1 then
							 if side_Switch = '0' then -- left half
								  if (x0 >= 79 or x0 < (79 - base_length)) then
										colour <= (others => '0');
								  else
										colour <= Gray(iteration mod 8);
										if x0 = x0_origin then
											 y0_origin := y0;
										end if;
								  end if;
							 elsif side_Switch = '1' then -- right half
								  if (x0 < 79 or x0 >= (79 + base_length)) then
										colour <= (others => '0');
								  else
										colour <= Gray(iteration mod 8);
										if not (x0 < 79 or x0 >= (79 + base_length)) then
											 y1_origin := y0;
										end if;
								  end if;
							 end if;
						end if;
					else -- When the Switches are not unmanipulated
						if calc_Iteration = 1 then
						  if side_Switch = '0' then -- left half
							 if (iteration <= 7 and y0 >= 59) or (iteration > 7 and y0 <= 60) or (x0 >= 79) then
								colour <= (others => '0');
							 end if;
						  elsif side_Switch = '1' then -- right half
							 if (iteration <= 7 and y0 <= 59) or (iteration > 7 and y0 >= 61) or (x0 < 79) then
								colour <= (others => '0');
							 else
								colour <= Gray((iteration mod 8));
							 end if;
						  end if;
						end if;
					end if;

					if((x0 = x1) and (y0 = y1)) then
						if (done_drawings = '1') then
							calc_Iteration := 0;
							done_drawings := '0';
							iteration := iteration + 1;
							if(iteration = 14) then
								side_Switch := NOT side_Switch;
							end if;
							CurState <= s3;
						else
							calc_Iteration := calc_Iteration + 1;
							CurState <= s1;
						end if;
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
				when s3 =>  -- waiting state
					plot <= '0';
					wait_counter := wait_counter + 1;
					if(wait_counter = 49999999) then
						wait_counter := 0;
						x0 := 0;
						y0 := 0;
						CurState <= s0;
					end if;
			end case;
		end if;
	end process;
  
end RTL;