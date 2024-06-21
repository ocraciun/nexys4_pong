----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2023 06:34:55 PM
-- Design Name: 
-- Module Name: object_generator - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_color is
    Generic (
        -- VGA 1280x1024@60Hz sync parameters
        FRAME_WIDTH : natural := 1280;
        FRAME_HEIGHT : natural := 1024;
        PADDLE_WIDTH : natural := 10;
        PADDLE_HEIGHT : natural := 100;
        BALL_SIZE : natural := 16
    );
    Port (
           CLK : in STD_LOGIC;
           RST: in STD_LOGIC;
           PADDLE_1_X: in natural range 0 to FRAME_WIDTH;
           PADDLE_1_Y: in natural range 0 to FRAME_WIDTH;
           PADDLE_2_X: in natural range 0 to FRAME_WIDTH;
           PADDLE_2_Y: in natural range 0 to FRAME_WIDTH;
           BALL_X: in natural range 0 to FRAME_WIDTH;
           BALL_Y: in natural range 0 to FRAME_WIDTH;
           VIDEO_ON : in STD_LOGIC;
           PIXEL_X : in natural range 0 to FRAME_WIDTH;
           PIXEL_Y : in natural range 0 to FRAME_HEIGHT;
           RGB_O : out STD_LOGIC_VECTOR (11 downto 0)
    );
end vga_color;

architecture Behavioral of vga_color is
    signal paddle_1_rgb, paddle_2_rgb : std_logic_vector(11 downto 0);
    signal paddle_1_on, paddle_2_on : std_logic;
    signal ball_rgb : std_logic_vector(11 downto 0);
    signal ball_on : std_logic;
begin
    
paddle_1: entity work.paddle
    generic map (
        FRAME_WIDTH=>FRAME_WIDTH,
        FRAME_HEIGHT=>FRAME_HEIGHT,
        PADDLE_WIDTH=>PADDLE_WIDTH,
        PADDLE_HEIGHT=> PADDLE_HEIGHT
    )
    port map(
        PADDLE_X=>PADDLE_1_X,
        PADDLE_Y=>PADDLE_1_Y,
        PIXEL_X => PIXEL_X,
        PIXEL_Y => PIXEL_Y,
        PADDLE_RGB_O => paddle_1_rgb,
        PADDLE_EN => paddle_1_on
    );
 
paddle_2: entity work.paddle
    generic map (
        FRAME_WIDTH=>FRAME_WIDTH,
        FRAME_HEIGHT=>FRAME_HEIGHT,
        PADDLE_WIDTH=>PADDLE_WIDTH,
        PADDLE_HEIGHT=> PADDLE_HEIGHT
    )
    port map(
        PADDLE_X=>PADDLE_2_X,
        PADDLE_Y=>PADDLE_2_Y,
        PIXEL_X => PIXEL_X,
        PIXEL_Y => PIXEL_Y,
        PADDLE_RGB_O => paddle_2_rgb,
        PADDLE_EN => paddle_2_on
    );
    
ball: entity work.ball
    generic map (
        FRAME_WIDTH=>FRAME_WIDTH,
        FRAME_HEIGHT=>FRAME_HEIGHT,
        BALL_SIZE=>BALL_SIZE
    )
    port map(
        CLK=>CLK,
        BALL_X => BALL_X,
        BALL_Y => BALL_Y,
        PIXEL_X => PIXEL_X,
        PIXEL_Y => PIXEL_Y,
        BALL_RGB_O => ball_rgb,
        BALL_EN => ball_on
    );
            
object_multiplexing: process(RST, VIDEO_ON, PIXEL_X, PIXEL_Y, paddle_1_on, paddle_1_rgb, paddle_2_on, paddle_2_rgb, ball_on, ball_rgb)
    begin
        if (RST = '0') then
            RGB_O <= x"000";
        else
            if (VIDEO_ON = '0') then
                RGB_O <= x"000";
            else
                if PIXEL_X = FRAME_WIDTH / 2 and PIXEL_Y = FRAME_HEIGHT/2 then
                    RGB_O <= x"fff";
                elsif (ball_on = '1') then
                    RGB_O <= ball_rgb;
                elsif (paddle_1_on = '1') then
                    RGB_O <= paddle_1_rgb;
                elsif (paddle_2_on = '1') then
                    RGB_O <= paddle_2_rgb;
                else
                    RGB_O <= x"000"; -- black backround
                end if;
            end if;
        end if;
    end process;
end Behavioral;
